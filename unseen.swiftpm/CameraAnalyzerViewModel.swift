import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit
import Vision

final class CameraAnalyzerViewModel: NSObject, ObservableObject {
    @Published var frame: CGImage?
    @Published var imageSize: CGSize = .zero
    @Published var findings: [ContrastFinding] = []
    @Published var mode: VisionMode = .deuteranopia {
        didSet {
            statusText = "Mode: \(mode.rawValue)"
            if useSampleFallback {
                renderSampleFrame()
            }
        }
    }
    @Published var analyzeText = true {
        didSet {
            if !analyzeText {
                findings = []
            }
        }
    }
    @Published var statusText: String = "Preparing camera..."
    @Published var permissionDenied = false
    @Published var useSampleFallback = false
    @Published var isFrozen = false
    @Published var inspection: ColorInspection?

    private let simulationEngine: SimulationEngine
    private let contrastAnalyzer: ContrastAnalyzer
    private let haptics = HapticService()

    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "unseen.camera.processing", qos: .userInitiated)
    private let visionQueue = DispatchQueue(label: "unseen.vision.processing", qos: .utility)
    private let analysisStateQueue = DispatchQueue(label: "unseen.vision.state")
    private let context = CIContext(options: nil)

    private var configured = false
    /// Accessed only on `processingQueue` — no additional synchronization needed.
    private var frameCounter = 0
    private var lastCIImage: CIImage?
    private var isAnalyzingFrame = false

    init(simulationEngine: SimulationEngine = CISimulationEngine()) {
        self.simulationEngine = simulationEngine
        self.contrastAnalyzer = ContrastAnalyzer(context: CIContext(options: nil))
        super.init()
    }

    deinit {
        stop()
    }

    // MARK: - Public API

    func start() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            configureAndRunSessionIfNeeded()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    guard let self else { return }
                    if granted {
                        self.configureAndRunSessionIfNeeded()
                    } else {
                        self.permissionDenied = true
                        self.activateSampleFallback(reason: "No camera permission — Sample mode")
                    }
                }
            }
        default:
            permissionDenied = true
            activateSampleFallback(reason: "Camera access restricted — Sample mode")
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func activateSampleFallback(reason: String = "Sample mode") {
        useSampleFallback = true
        statusText = reason
        renderSampleFrame()
    }

    func inspect(at location: CGPoint, in viewSize: CGSize) {
        guard let image = lastCIImage else { return }
        let imgSize = image.extent.size
        guard let imagePoint = mapViewPointToImagePoint(location, viewSize: viewSize, imageSize: imgSize) else { return }

        if let tappedFinding = finding(at: location, in: viewSize), !tappedFinding.pass {
            haptics.triggerFail()
        }

        let sampleHalf = AnalysisConstants.tapSampleSize / 2
        let sampleRect = CGRect(
            x: imagePoint.x - sampleHalf,
            y: imagePoint.y - sampleHalf,
            width: AnalysisConstants.tapSampleSize,
            height: AnalysisConstants.tapSampleSize
        )
        guard let sampled = contrastAnalyzer.averageColor(in: image, rect: sampleRect) else { return }

        let modeSamples: [(VisionMode, String)] = VisionMode.allCases.map { mode in
            (mode, simulationEngine.transformColor(sampled, mode: mode).hexString)
        }

        inspection = ColorInspection(
            pickedHex: sampled.hexString,
            pickedRGB: sampled.rgbString,
            modeSamples: modeSamples,
            suggestions: suggestedAlternatives(for: sampled, mode: mode)
        )
    }

    func overlayRect(for normalizedBox: CGRect, in viewSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let fitted = fittedRect(for: imageSize, in: viewSize)
        let x = fitted.minX + normalizedBox.minX * fitted.width
        let width = normalizedBox.width * fitted.width

        let yFromBottom = normalizedBox.minY * fitted.height
        let height = normalizedBox.height * fitted.height
        let y = fitted.maxY - yFromBottom - height

        return CGRect(x: x, y: y, width: width, height: height)
    }

    // MARK: - Camera Session

    private func configureAndRunSessionIfNeeded() {
        guard !configured else {
            if !session.isRunning {
                session.startRunning()
            }
            return
        }

        session.beginConfiguration()
        session.sessionPreset = .high

        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            session.commitConfiguration()
            activateSampleFallback(reason: "No camera device — Sample mode")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            session.commitConfiguration()
            activateSampleFallback(reason: "Camera init failed — Sample mode")
            return
        }

        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)
        ]
        output.alwaysDiscardsLateVideoFrames = true
        output.setSampleBufferDelegate(self, queue: processingQueue)

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        session.commitConfiguration()
        configured = true
        useSampleFallback = false
        statusText = "Live camera analysis"

        processingQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

    // MARK: - Frame Processing

    private func renderSampleFrame() {
        guard let sampleImage = generateSampleCIImage() else { return }
        let simulated = simulationEngine.simulate(sampleImage, mode: mode)
        publishFrame(simulated)

        guard analyzeText else { return }
        guard claimAnalysisSlot() else { return }
        guard let cg = context.createCGImage(simulated, from: simulated.extent) else {
            releaseAnalysisSlot()
            return
        }

        visionQueue.async { [weak self] in
            self?.runTextAnalysis(cgImage: cg, sourceImage: simulated)
        }
    }

    private func generateSampleCIImage() -> CIImage? {
        let size = CGSize(width: 1280, height: 720)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in
            UIColor(red: 18 / 255, green: 20 / 255, blue: 24 / 255, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let cardRect = CGRect(x: 80, y: 110, width: 1120, height: 500)
            UIColor(red: 30 / 255, green: 32 / 255, blue: 38 / 255, alpha: 1).setFill()
            UIBezierPath(roundedRect: cardRect, cornerRadius: 28).fill()

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 56),
                .foregroundColor: UIColor.white
            ]
            NSString(string: "Unseen Demo").draw(at: CGPoint(x: 120, y: 145), withAttributes: titleAttrs)

            let leftTag = CGRect(x: 120, y: 250, width: 420, height: 120)
            UIColor(red: 231 / 255, green: 76 / 255, blue: 60 / 255, alpha: 1).setFill()
            UIBezierPath(roundedRect: leftTag, cornerRadius: 20).fill()

            let rightTag = CGRect(x: 580, y: 250, width: 420, height: 120)
            UIColor(red: 46 / 255, green: 204 / 255, blue: 113 / 255, alpha: 1).setFill()
            UIBezierPath(roundedRect: rightTag, cornerRadius: 20).fill()

            let textAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 44),
                .foregroundColor: UIColor.white
            ]
            NSString(string: "Wrong").draw(at: CGPoint(x: 260, y: 283), withAttributes: textAttrs)
            NSString(string: "Correct").draw(at: CGPoint(x: 710, y: 283), withAttributes: textAttrs)

            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34, weight: .medium),
                .foregroundColor: UIColor(white: 0.88, alpha: 1)
            ]
            NSString(string: "Notice: Deadline Feb 28").draw(at: CGPoint(x: 120, y: 430), withAttributes: bodyAttrs)
            NSString(string: "Accessibility contrast check needed").draw(at: CGPoint(x: 120, y: 485), withAttributes: bodyAttrs)
        }

        return CIImage(image: image)
    }

    private func publishFrame(_ image: CIImage) {
        guard let cg = context.createCGImage(image, from: image.extent) else { return }
        lastCIImage = image

        DispatchQueue.main.async { [weak self] in
            self?.frame = cg
            self?.imageSize = CGSize(width: cg.width, height: cg.height)
        }
    }

    // MARK: - Text Analysis

    private func runTextAnalysis(cgImage: CGImage, sourceImage: CIImage) {
        defer { releaseAnalysisSlot() }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.minimumTextHeight = AnalysisConstants.minTextHeight
        request.recognitionLanguages = ["ko-KR", "en-US"]

        do {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            let observations = request.results ?? []
            let trimmed = observations.prefix(AnalysisConstants.maxFindings)

            let output: [ContrastFinding] = trimmed.compactMap { obs in
                guard let candidate = obs.topCandidates(1).first else { return nil }
                guard let estimate = contrastAnalyzer.estimateContrast(for: obs.boundingBox, in: sourceImage) else { return nil }

                return ContrastFinding(
                    text: candidate.string,
                    normalizedBox: obs.boundingBox,
                    ratio: estimate.ratio,
                    pass: estimate.ratio >= AnalysisConstants.passThreshold,
                    foregroundHex: estimate.foregroundHex,
                    backgroundHex: estimate.backgroundHex
                )
            }

            DispatchQueue.main.async { [weak self] in
                guard let self, self.analyzeText else { return }

                self.findings = output.sorted(by: { $0.ratio < $1.ratio })
                if let firstFail = self.findings.first(where: { !$0.pass }) {
                    self.statusText = "\(self.mode.rawValue) · FAIL \(String(format: "%.2f", firstFail.ratio)) found"
                } else if self.findings.isEmpty {
                    self.statusText = "No text detected"
                } else {
                    self.statusText = "\(self.mode.rawValue) · All text PASS"
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.statusText = "Text analysis error: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Color Suggestions

    private func suggestedAlternatives(for color: SIMD3<Double>, mode: VisionMode) -> [ColorSuggestion] {
        switch mode {
        case .deuteranopia, .protanopia:
            return [
                ColorSuggestion(role: "Error/Warning", hex: "#D26A00"),
                ColorSuggestion(role: "Success/Done", hex: "#2F6EE2"),
                ColorSuggestion(role: "Secondary", hex: "#6C7280")
            ]
        case .tritanopia:
            return [
                ColorSuggestion(role: "Accent A", hex: "#BD5A4F"),
                ColorSuggestion(role: "Accent B", hex: "#2A6FB2"),
                ColorSuggestion(role: "Secondary", hex: "#57606D")
            ]
        case .normal:
            let luminance = contrastAnalyzer.relativeLuminance(color)
            if luminance < 0.4 {
                return [
                    ColorSuggestion(role: "Light text for contrast", hex: "#F5F7FA"),
                    ColorSuggestion(role: "Accent", hex: "#C44100")
                ]
            } else {
                return [
                    ColorSuggestion(role: "Dark text for contrast", hex: "#1A1A1A"),
                    ColorSuggestion(role: "Secondary", hex: "#1D5FA0")
                ]
            }
        }
    }

    // MARK: - Coordinate Mapping

    private func finding(at point: CGPoint, in viewSize: CGSize) -> ContrastFinding? {
        findings.first { finding in
            overlayRect(for: finding.normalizedBox, in: viewSize).contains(point)
        }
    }

    private func mapViewPointToImagePoint(_ point: CGPoint, viewSize: CGSize, imageSize: CGSize) -> CGPoint? {
        let fitted = fittedRect(for: imageSize, in: viewSize)
        guard fitted.contains(point), fitted.width > 0, fitted.height > 0 else { return nil }

        let normalizedX = (point.x - fitted.minX) / fitted.width
        let normalizedY = (point.y - fitted.minY) / fitted.height

        let imageX = normalizedX * imageSize.width
        let imageY = (1.0 - normalizedY) * imageSize.height
        return CGPoint(x: imageX, y: imageY)
    }

    private func fittedRect(for imageSize: CGSize, in viewSize: CGSize) -> CGRect {
        let imageAspect = imageSize.width / imageSize.height
        let viewAspect = viewSize.width / viewSize.height

        if imageAspect > viewAspect {
            let width = viewSize.width
            let height = width / imageAspect
            return CGRect(x: 0, y: (viewSize.height - height) / 2, width: width, height: height)
        } else {
            let height = viewSize.height
            let width = height * imageAspect
            return CGRect(x: (viewSize.width - width) / 2, y: 0, width: width, height: height)
        }
    }

    // MARK: - Analysis Slot

    private func claimAnalysisSlot() -> Bool {
        analysisStateQueue.sync {
            if isAnalyzingFrame {
                return false
            }
            isAnalyzingFrame = true
            return true
        }
    }

    private func releaseAnalysisSlot() {
        analysisStateQueue.async { [weak self] in
            self?.isAnalyzingFrame = false
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraAnalyzerViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !useSampleFallback, !isFrozen else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        autoreleasepool {
            var ci = CIImage(cvPixelBuffer: pixelBuffer)
            ci = ci.oriented(.right)
            let simulated = simulationEngine.simulate(ci, mode: mode)
            publishFrame(simulated)

            frameCounter += 1
            guard analyzeText, frameCounter % AnalysisConstants.ocrFrameInterval == 0 else { return }
            guard claimAnalysisSlot() else { return }
            guard let cg = context.createCGImage(simulated, from: simulated.extent) else {
                releaseAnalysisSlot()
                return
            }

            visionQueue.async { [weak self] in
                self?.runTextAnalysis(cgImage: cg, sourceImage: simulated)
            }
        }
    }
}
