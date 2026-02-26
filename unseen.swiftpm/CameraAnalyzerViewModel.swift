import AVFoundation
import CoreHaptics
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
            statusText = "모드: \(mode.rawValue)"
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
    @Published var statusText: String = "카메라 준비 중..."
    @Published var permissionDenied = false
    @Published var useSampleFallback = false
    @Published var isFrozen = false
    @Published var inspection: ColorInspection?

    private let simulationEngine: SimulationEngine
    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "unseen.camera.processing", qos: .userInitiated)
    private let visionQueue = DispatchQueue(label: "unseen.vision.processing", qos: .utility)
    private let analysisStateQueue = DispatchQueue(label: "unseen.vision.state")
    private let context = CIContext(options: nil)

    private var configured = false
    private var frameCounter = 0
    private var lastCIImage: CIImage?
    private var hapticEngine: CHHapticEngine?
    private var isAnalyzingFrame = false

    init(simulationEngine: SimulationEngine = CISimulationEngine()) {
        self.simulationEngine = simulationEngine
        super.init()
        prepareHaptics()
    }

    deinit {
        stop()
    }

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
                        self.activateSampleFallback(reason: "카메라 권한 없음 — 샘플 모드")
                    }
                }
            }
        default:
            permissionDenied = true
            activateSampleFallback(reason: "카메라 접근 제한 — 샘플 모드")
        }
    }

    func stop() {
        if session.isRunning {
            session.stopRunning()
        }
    }

    func activateSampleFallback(reason: String = "샘플 모드") {
        useSampleFallback = true
        statusText = reason
        renderSampleFrame()
    }

    func inspect(at location: CGPoint, in viewSize: CGSize) {
        guard let image = lastCIImage else { return }
        let imgSize = image.extent.size
        guard let imagePoint = mapViewPointToImagePoint(location, viewSize: viewSize, imageSize: imgSize) else { return }

        if let tappedFinding = finding(at: location, in: viewSize), !tappedFinding.pass {
            triggerFailHaptic()
        }

        let sampleHalf = AnalysisConstants.tapSampleSize / 2
        let sampleRect = CGRect(
            x: imagePoint.x - sampleHalf,
            y: imagePoint.y - sampleHalf,
            width: AnalysisConstants.tapSampleSize,
            height: AnalysisConstants.tapSampleSize
        )
        guard let sampled = averageColor(in: image, rect: sampleRect) else { return }

        let pickedHex = hexString(sampled)
        let pickedRGB = rgbString(sampled)

        var modeSamples: [(VisionMode, String)] = []
        for mode in VisionMode.allCases {
            let transformed = simulationEngine.transformColor(sampled, mode: mode)
            modeSamples.append((mode, hexString(transformed)))
        }

        let suggestions = suggestedAlternatives(for: sampled, mode: mode)
        inspection = ColorInspection(
            pickedHex: pickedHex,
            pickedRGB: pickedRGB,
            modeSamples: modeSamples,
            suggestions: suggestions
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

    private func finding(at point: CGPoint, in viewSize: CGSize) -> ContrastFinding? {
        findings.first { finding in
            overlayRect(for: finding.normalizedBox, in: viewSize).contains(point)
        }
    }

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
            activateSampleFallback(reason: "카메라 장치 없음 — 샘플 모드")
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
        } catch {
            session.commitConfiguration()
            activateSampleFallback(reason: "카메라 초기화 실패 — 샘플 모드")
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
        statusText = "실시간 카메라 분석 중"

        processingQueue.async { [weak self] in
            self?.session.startRunning()
        }
    }

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
            NSString(string: "오답").draw(at: CGPoint(x: 280, y: 283), withAttributes: textAttrs)
            NSString(string: "정답").draw(at: CGPoint(x: 740, y: 283), withAttributes: textAttrs)

            let bodyAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 34, weight: .medium),
                .foregroundColor: UIColor(white: 0.88, alpha: 1)
            ]
            NSString(string: "공지: 2월 28일 제출 마감").draw(at: CGPoint(x: 120, y: 430), withAttributes: bodyAttrs)
            NSString(string: "접근성 대비 확인 필요").draw(at: CGPoint(x: 120, y: 485), withAttributes: bodyAttrs)
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

            let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
            let trimmed = observations.prefix(AnalysisConstants.maxFindings)

            let output: [ContrastFinding] = trimmed.compactMap { obs in
                guard let candidate = obs.topCandidates(1).first else { return nil }
                guard let estimate = estimateContrast(for: obs.boundingBox, in: sourceImage) else { return nil }

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
                guard let self else { return }
                guard self.analyzeText else { return }

                self.findings = output.sorted(by: { $0.ratio < $1.ratio })
                if let firstFail = self.findings.first(where: { !$0.pass }) {
                    self.statusText = "\(self.mode.rawValue) · FAIL \(String(format: "%.2f", firstFail.ratio)) 발견"
                } else if self.findings.isEmpty {
                    self.statusText = "텍스트를 인식하지 못했습니다"
                } else {
                    self.statusText = "\(self.mode.rawValue) · 모든 텍스트 PASS"
                }
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.statusText = "텍스트 분석 오류"
            }
        }
    }

    private func estimateContrast(for normalizedBox: CGRect, in image: CIImage) -> (ratio: Double, foregroundHex: String, backgroundHex: String)? {
        let imgRect = CGRect(
            x: normalizedBox.minX * image.extent.width,
            y: normalizedBox.minY * image.extent.height,
            width: normalizedBox.width * image.extent.width,
            height: normalizedBox.height * image.extent.height
        )
        guard !imgRect.isEmpty else { return nil }

        let fgRect = imgRect.insetBy(
            dx: max(1, imgRect.width * AnalysisConstants.fgInsetXRatio),
            dy: max(1, imgRect.height * AnalysisConstants.fgInsetYRatio)
        )
        let bgRect = imgRect.insetBy(
            dx: -max(4, imgRect.width * AnalysisConstants.bgInsetXRatio),
            dy: -max(4, imgRect.height * AnalysisConstants.bgInsetYRatio)
        )

        guard let fg = averageColor(in: image, rect: fgRect),
              let bg = averageColor(in: image, rect: bgRect) else { return nil }

        let ratio = contrastRatio(fg, bg)
        return (ratio, hexString(fg), hexString(bg))
    }

    private func averageColor(in image: CIImage, rect: CGRect) -> SIMD3<Double>? {
        let safeRect = rect.intersection(image.extent)
        guard !safeRect.isEmpty else { return nil }

        let filter = CIFilter.areaAverage()
        filter.inputImage = image.cropped(to: safeRect)
        filter.extent = safeRect

        guard let output = filter.outputImage else { return nil }

        var bitmap = [UInt8](repeating: 0, count: 4)
        context.render(
            output,
            toBitmap: &bitmap,
            rowBytes: 4,
            bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
            format: .RGBA8,
            colorSpace: CGColorSpaceCreateDeviceRGB()
        )

        return SIMD3(
            Double(bitmap[0]) / 255.0,
            Double(bitmap[1]) / 255.0,
            Double(bitmap[2]) / 255.0
        )
    }

    private func contrastRatio(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
        let l1 = relativeLuminance(a)
        let l2 = relativeLuminance(b)
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }

    private func relativeLuminance(_ c: SIMD3<Double>) -> Double {
        func f(_ v: Double) -> Double {
            if v <= 0.03928 { return v / 12.92 }
            return pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * f(c.x) + 0.7152 * f(c.y) + 0.0722 * f(c.z)
    }

    private func hexString(_ c: SIMD3<Double>) -> String {
        let r = Int(max(0, min(255, round(c.x * 255.0))))
        let g = Int(max(0, min(255, round(c.y * 255.0))))
        let b = Int(max(0, min(255, round(c.z * 255.0))))
        return String(format: "#%02X%02X%02X", r, g, b)
    }

    private func rgbString(_ c: SIMD3<Double>) -> String {
        let r = Int(max(0, min(255, round(c.x * 255.0))))
        let g = Int(max(0, min(255, round(c.y * 255.0))))
        let b = Int(max(0, min(255, round(c.z * 255.0))))
        return "\(r), \(g), \(b)"
    }

    private func suggestedAlternatives(for color: SIMD3<Double>, mode: VisionMode) -> [ColorSuggestion] {
        switch mode {
        case .deuteranopia, .protanopia:
            return [
                ColorSuggestion(role: "오답/주의", hex: "#D26A00"),
                ColorSuggestion(role: "정답/완료", hex: "#2F6EE2"),
                ColorSuggestion(role: "보조", hex: "#6C7280")
            ]
        case .tritanopia:
            return [
                ColorSuggestion(role: "강조 A", hex: "#BD5A4F"),
                ColorSuggestion(role: "강조 B", hex: "#2A6FB2"),
                ColorSuggestion(role: "보조", hex: "#57606D")
            ]
        case .normal:
            let luminance = relativeLuminance(color)
            if luminance < 0.4 {
                return [
                    ColorSuggestion(role: "대비용 밝은 텍스트", hex: "#F5F7FA"),
                    ColorSuggestion(role: "강조", hex: "#C44100")
                ]
            } else {
                return [
                    ColorSuggestion(role: "대비용 어두운 텍스트", hex: "#1A1A1A"),
                    ColorSuggestion(role: "보조", hex: "#1D5FA0")
                ]
            }
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

    private func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            hapticEngine = nil
        }
    }

    private func triggerFailHaptic() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.75)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.55)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensity, sharpness], relativeTime: 0)

        do {
            try hapticEngine?.start()
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine?.makePlayer(with: pattern)
            try player?.start(atTime: 0)
        } catch {
            // Do not fail the interaction when haptics are unavailable.
        }
    }

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
