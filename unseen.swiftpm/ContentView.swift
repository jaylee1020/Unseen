import SwiftUI
import AVFoundation
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

// MARK: - Theme
private enum UnseenTheme {
    static let bg = Color(red: 250.0/255.0, green: 250.0/255.0, blue: 248.0/255.0)
    static let surface = Color.white
    static let surface2 = Color(red: 244.0/255.0, green: 244.0/255.0, blue: 240.0/255.0)
    static let border = Color(red: 226.0/255.0, green: 226.0/255.0, blue: 220.0/255.0)
    static let text = Color(red: 24.0/255.0, green: 24.0/255.0, blue: 15.0/255.0)
    static let dim = Color(red: 113.0/255.0, green: 113.0/255.0, blue: 106.0/255.0)
    static let accent = Color(red: 196.0/255.0, green: 65.0/255.0, blue: 0.0/255.0)
    static let accentBackground = Color(red: 1.0, green: 244.0/255.0, blue: 237.0/255.0)
    static let green = Color(red: 26.0/255.0, green: 122.0/255.0, blue: 76.0/255.0)
    static let greenBackground = Color(red: 238.0/255.0, green: 248.0/255.0, blue: 241.0/255.0)
    static let red = Color(red: 196.0/255.0, green: 51.0/255.0, blue: 51.0/255.0)
    static let redBackground = Color(red: 253.0/255.0, green: 240.0/255.0, blue: 240.0/255.0)
    static let blue = Color(red: 29.0/255.0, green: 95.0/255.0, blue: 160.0/255.0)
    static let blueBackground = Color(red: 238.0/255.0, green: 244.0/255.0, blue: 251.0/255.0)
}

// MARK: - Models
enum VisionMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case deuteranopia = "Deuteranopia"
    case protanopia = "Protanopia"
    case tritanopia = "Tritanopia"

    var id: Self { self }

    var shortLabel: String {
        switch self {
        case .normal: return "정상"
        case .deuteranopia: return "적-녹"
        case .protanopia: return "적색약"
        case .tritanopia: return "청색약"
        }
    }
}

struct ContrastFinding: Identifiable {
    let id = UUID()
    let text: String
    let normalizedBox: CGRect // Vision normalized (origin: bottom-left)
    let ratio: Double
    let pass: Bool
    let foregroundHex: String
    let backgroundHex: String
}

struct ColorSuggestion: Identifiable {
    let id = UUID()
    let role: String
    let hex: String
}

struct ColorInspection: Identifiable {
    let id = UUID()
    let pickedHex: String
    let pickedRGB: String
    let modeSamples: [(VisionMode, String)]
    let suggestions: [ColorSuggestion]
}

// MARK: - Camera / Analysis Engine
final class UnseenViewModel: NSObject, ObservableObject {
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
    @Published var inspection: ColorInspection?

    private let session = AVCaptureSession()
    private let output = AVCaptureVideoDataOutput()
    private let processingQueue = DispatchQueue(label: "unseen.camera.processing", qos: .userInitiated)
    private let visionQueue = DispatchQueue(label: "unseen.vision.processing", qos: .utility)
    private let context = CIContext(options: nil)

    private var configured = false
    private var frameCounter = 0
    private var lastCIImage: CIImage?

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

        let sampleRect = CGRect(x: imagePoint.x - 6, y: imagePoint.y - 6, width: 12, height: 12)
        guard let sampled = averageColor(in: image, rect: sampleRect) else { return }

        let pickedHex = hexString(sampled)
        let pickedRGB = rgbString(sampled)

        var modeSamples: [(VisionMode, String)] = []
        for mode in VisionMode.allCases {
            let transformed = transformColor(sampled, mode: mode)
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
        let simulated = applySimulation(to: sampleImage, mode: mode)
        publishFrame(simulated)

        if analyzeText, let cg = context.createCGImage(simulated, from: simulated.extent) {
            runTextAnalysis(cgImage: cg, sourceImage: simulated)
        }
    }

    private func generateSampleCIImage() -> CIImage? {
        let size = CGSize(width: 1280, height: 720)
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { ctx in
            UIColor(red: 18/255, green: 20/255, blue: 24/255, alpha: 1).setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            let cardRect = CGRect(x: 80, y: 110, width: 1120, height: 500)
            UIColor(red: 30/255, green: 32/255, blue: 38/255, alpha: 1).setFill()
            UIBezierPath(roundedRect: cardRect, cornerRadius: 28).fill()

            let titleAttrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 56),
                .foregroundColor: UIColor.white
            ]
            NSString(string: "Unseen Demo").draw(at: CGPoint(x: 120, y: 145), withAttributes: titleAttrs)

            let leftTag = CGRect(x: 120, y: 250, width: 420, height: 120)
            UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1).setFill()
            UIBezierPath(roundedRect: leftTag, cornerRadius: 20).fill()

            let rightTag = CGRect(x: 580, y: 250, width: 420, height: 120)
            UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1).setFill()
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
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .fast
        request.usesLanguageCorrection = false
        request.minimumTextHeight = 0.03
        request.recognitionLanguages = ["ko-KR", "en-US"]

        do {
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            let observations = (request.results as? [VNRecognizedTextObservation]) ?? []
            let trimmed = observations.prefix(10)

            let output: [ContrastFinding] = trimmed.compactMap { obs in
                guard let candidate = obs.topCandidates(1).first else { return nil }
                guard let estimate = estimateContrast(for: obs.boundingBox, in: sourceImage) else { return nil }

                return ContrastFinding(
                    text: candidate.string,
                    normalizedBox: obs.boundingBox,
                    ratio: estimate.ratio,
                    pass: estimate.ratio >= 4.5,
                    foregroundHex: estimate.foregroundHex,
                    backgroundHex: estimate.backgroundHex
                )
            }

            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if self.analyzeText {
                    self.findings = output.sorted(by: { $0.ratio < $1.ratio })
                    if let firstFail = self.findings.first(where: { !$0.pass }) {
                        self.statusText = "\(self.mode.rawValue) · FAIL \(String(format: "%.2f", firstFail.ratio)) 발견"
                    } else if self.findings.isEmpty {
                        self.statusText = "텍스트를 인식하지 못했습니다"
                    } else {
                        self.statusText = "\(self.mode.rawValue) · 모든 텍스트 PASS"
                    }
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

        let fgRect = imgRect.insetBy(dx: max(1, imgRect.width * 0.25), dy: max(1, imgRect.height * 0.28))
        let bgRect = imgRect.insetBy(dx: -max(3, imgRect.width * 0.2), dy: -max(3, imgRect.height * 0.35))

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

    private func transformColor(_ c: SIMD3<Double>, mode: VisionMode) -> SIMD3<Double> {
        let m = modeMatrix(for: mode)
        let r = m[0][0] * c.x + m[0][1] * c.y + m[0][2] * c.z
        let g = m[1][0] * c.x + m[1][1] * c.y + m[1][2] * c.z
        let b = m[2][0] * c.x + m[2][1] * c.y + m[2][2] * c.z
        return SIMD3(max(0, min(1, r)), max(0, min(1, g)), max(0, min(1, b)))
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

    private func applySimulation(to image: CIImage, mode: VisionMode) -> CIImage {
        guard mode != .normal else { return image }
        let m = modeMatrix(for: mode)

        let filter = CIFilter.colorMatrix()
        filter.inputImage = image
        filter.rVector = CIVector(x: m[0][0], y: m[0][1], z: m[0][2], w: 0)
        filter.gVector = CIVector(x: m[1][0], y: m[1][1], z: m[1][2], w: 0)
        filter.bVector = CIVector(x: m[2][0], y: m[2][1], z: m[2][2], w: 0)
        filter.aVector = CIVector(x: 0, y: 0, z: 0, w: 1)
        return filter.outputImage ?? image
    }

    private func modeMatrix(for mode: VisionMode) -> [[Double]] {
        switch mode {
        case .normal:
            return [
                [1, 0, 0],
                [0, 1, 0],
                [0, 0, 1]
            ]
        case .protanopia:
            return [
                [0.56667, 0.43333, 0.0],
                [0.55833, 0.44167, 0.0],
                [0.0,     0.24167, 0.75833]
            ]
        case .deuteranopia:
            return [
                [0.625, 0.375, 0.0],
                [0.70,  0.30,  0.0],
                [0.0,   0.30,  0.70]
            ]
        case .tritanopia:
            return [
                [0.95, 0.05, 0.0],
                [0.0, 0.43333, 0.56667],
                [0.0, 0.475,   0.525]
            ]
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

    func overlayRect(for normalizedBox: CGRect, in viewSize: CGSize) -> CGRect {
        guard imageSize.width > 0, imageSize.height > 0 else { return .zero }

        let fitted = fittedRect(for: imageSize, in: viewSize)

        let x = fitted.minX + normalizedBox.minX * fitted.width
        let width = normalizedBox.width * fitted.width

        // Vision origin: bottom-left / SwiftUI: top-left
        let yFromBottom = normalizedBox.minY * fitted.height
        let height = normalizedBox.height * fitted.height
        let y = fitted.maxY - yFromBottom - height

        return CGRect(x: x, y: y, width: width, height: height)
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
}

extension UnseenViewModel: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !useSampleFallback else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }

        autoreleasepool {
            var ci = CIImage(cvPixelBuffer: pixelBuffer)
            ci = ci.oriented(.right)
            let simulated = applySimulation(to: ci, mode: mode)
            publishFrame(simulated)

            frameCounter += 1
            guard analyzeText, frameCounter % 12 == 0 else { return }
            guard let cg = context.createCGImage(simulated, from: simulated.extent) else { return }

            visionQueue.async { [weak self] in
                self?.runTextAnalysis(cgImage: cg, sourceImage: simulated)
            }
        }
    }
}

// MARK: - UI
struct ContentView: View {
    @StateObject private var vm = UnseenViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                hero
                cameraSection
                controlsSection
                findingsSection
                whyAppSection
                demoFlowSection
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 80)
        }
        .background(UnseenTheme.bg.ignoresSafeArea())
        .task {
            vm.start()
        }
        .onDisappear {
            vm.stop()
        }
        .sheet(item: $vm.inspection) { inspection in
            ColorInspectionSheet(inspection: inspection)
        }
    }

    private var hero: some View {
        VStack(spacing: 10) {
            Text("SSC 2026 — Refined Idea")
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .tracking(2.2)
                .textCase(.uppercase)
                .foregroundStyle(UnseenTheme.accent)
                .padding(.vertical, 5)
                .padding(.horizontal, 14)
                .background(UnseenTheme.accentBackground)
                .clipShape(Capsule())

            Text("Unseen")
                .font(.system(size: 54, weight: .regular, design: .serif))
                .foregroundStyle(UnseenTheme.text)

            Text("See what 300 million people can't.")
                .font(.system(size: 18, weight: .regular, design: .serif))
                .italic()
                .foregroundStyle(UnseenTheme.accent)

            Text("카메라가 없으면 존재할 수 없는 앱. 실물(포스터·간판·교재·UI)을 비추면 색각이상 시야 + WCAG 대비 진단을 실시간으로 보여줍니다.")
                .font(.system(size: 14))
                .foregroundStyle(UnseenTheme.dim)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 520)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var cameraSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("카메라 뷰파인더")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                    .foregroundStyle(UnseenTheme.accent)
                Spacer()
                if vm.useSampleFallback {
                    Text("DEMO SAMPLE")
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundStyle(UnseenTheme.blue)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(UnseenTheme.blueBackground)
                        .clipShape(Capsule())
                }
            }

            GeometryReader { geo in
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.85))

                    if let frame = vm.frame {
                        Image(decorative: frame, scale: 1.0, orientation: .up)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        Text("카메라 프레임 대기 중...")
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.7))
                    }

                    ForEach(vm.findings) { finding in
                        let rect = vm.overlayRect(for: finding.normalizedBox, in: geo.size)
                        if rect.width > 10, rect.height > 10 {
                            ZStack(alignment: .topLeading) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .stroke(finding.pass ? UnseenTheme.green : UnseenTheme.red, lineWidth: 1.6)

                                Text("\(finding.pass ? "PASS" : "FAIL") \(String(format: "%.2f", finding.ratio))")
                                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(finding.pass ? UnseenTheme.green : UnseenTheme.red)
                                    .clipShape(Capsule())
                                    .offset(x: 4, y: 4)
                            }
                            .frame(width: rect.width, height: rect.height)
                            .position(x: rect.midX, y: rect.midY)
                        }
                    }
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            vm.inspect(at: value.location, in: geo.size)
                        }
                )
            }
            .frame(height: 280)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(UnseenTheme.border, lineWidth: 1)
            }

            Text("화면을 탭하면 색상 상세/대체 색상이 뜹니다.")
                .font(.system(size: 12))
                .foregroundStyle(UnseenTheme.dim)
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var controlsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("실시간 진단 설정")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            Picker("색각 모드", selection: $vm.mode) {
                ForEach(VisionMode.allCases) { mode in
                    Text(mode.shortLabel).tag(mode)
                }
            }
            .pickerStyle(.segmented)

            Toggle("텍스트 인식 + WCAG 대비 분석", isOn: $vm.analyzeText)
                .tint(UnseenTheme.accent)

            HStack(spacing: 10) {
                Text(vm.statusText)
                    .font(.system(size: 12))
                    .foregroundStyle(UnseenTheme.dim)

                Spacer()

                Button("샘플 모드") {
                    vm.activateSampleFallback(reason: "샘플 모드 수동 전환")
                }
                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.blue)
            }

            if vm.permissionDenied {
                Button("설정에서 카메라 권한 열기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.system(size: 12, weight: .semibold))
                .padding(.top, 2)
            }
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var findingsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("진단 결과")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            if vm.findings.isEmpty {
                Text("텍스트를 인식하면 PASS/FAIL 결과가 여기에 표시됩니다.")
                    .font(.system(size: 13))
                    .foregroundStyle(UnseenTheme.dim)
            } else {
                ForEach(vm.findings.prefix(5)) { finding in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(finding.text)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(UnseenTheme.text)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            Text(finding.pass ? "PASS" : "FAIL")
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 3)
                                .background(finding.pass ? UnseenTheme.green : UnseenTheme.red)
                                .clipShape(Capsule())

                            Text("contrast \(String(format: "%.2f", finding.ratio))")
                                .font(.system(size: 11, weight: .semibold, design: .monospaced))
                                .foregroundStyle(UnseenTheme.dim)

                            Spacer()

                            Text("fg \(finding.foregroundHex)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(UnseenTheme.dim)
                            Text("bg \(finding.backgroundHex)")
                                .font(.system(size: 10, design: .monospaced))
                                .foregroundStyle(UnseenTheme.dim)
                        }
                    }
                    .padding(10)
                    .background(UnseenTheme.surface2)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var whyAppSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Why this must be an app")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            Text("카메라가 없으면 존재할 수 없는 앱")
                .font(.system(size: 24, weight: .regular, design: .serif))
                .foregroundStyle(UnseenTheme.text)

            Text("실물(포스터·간판·출력물)을 비추는 즉시 진단해야 하므로 웹 문서/포토샵 필터로 대체할 수 없습니다. 디자이너·교사가 반복적으로 사용하는 검수 도구라는 점이 핵심입니다.")
                .font(.system(size: 14))
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(3)

            HStack(spacing: 10) {
                SmallCard(title: "실물 검사", body: "디지털 파일이 아닌 현실 세계 접근성 진단")
                SmallCard(title: "실시간", body: "비추는 즉시 결과")
                SmallCard(title: "반복 사용", body: "디자인 검수 루틴화")
            }
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }

    private var demoFlowSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("3-min demo flow")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)

            DemoStep(time: "0:00-0:15", title: "앱 오픈", detail: "한 줄 설명 후 즉시 카메라 진입")
            DemoStep(time: "0:15-0:50", title: "색각이상 시뮬레이션", detail: "토글 전환으로 빨강-초록 충돌 체감")
            DemoStep(time: "0:50-1:40", title: "PASS/FAIL 진단", detail: "텍스트 자동 인식 + WCAG 대비 계산")
            DemoStep(time: "1:40-2:20", title: "탭 상세 분석", detail: "HEX/RGB + 모드별 변환 + 대체 색 제안")
            DemoStep(time: "2:20-3:00", title: "반복 사용 가치", detail: "디자인 검수 도구로 실제 워크플로우 연결")
        }
        .padding(16)
        .background(UnseenTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(UnseenTheme.border, lineWidth: 1)
        }
    }
}

private struct SmallCard: View {
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(UnseenTheme.text)
            Text(body)
                .font(.system(size: 12))
                .foregroundStyle(UnseenTheme.dim)
                .lineSpacing(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct DemoStep: View {
    let time: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(time)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(UnseenTheme.accent)
                .frame(width: 74, alignment: .leading)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(UnseenTheme.text)
                Text(detail)
                    .font(.system(size: 12))
                    .foregroundStyle(UnseenTheme.dim)
            }

            Spacer(minLength: 0)
        }
        .padding(10)
        .background(UnseenTheme.surface2)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

private struct ColorInspectionSheet: View {
    let inspection: ColorInspection
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("선택 색상")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(UnseenTheme.accent)

                        HStack(spacing: 12) {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color(hex: inspection.pickedHex) ?? .clear)
                                .frame(width: 54, height: 54)
                                .overlay {
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(UnseenTheme.border, lineWidth: 1)
                                }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(inspection.pickedHex)
                                    .font(.system(size: 18, weight: .semibold, design: .monospaced))
                                Text("RGB \(inspection.pickedRGB)")
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(UnseenTheme.dim)
                            }
                        }
                    }

                    Divider().overlay(UnseenTheme.border)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("모드별 변환")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(UnseenTheme.accent)

                        ForEach(inspection.modeSamples, id: \.0) { mode, hex in
                            HStack {
                                Text(mode.rawValue)
                                    .font(.system(size: 12, weight: .medium))
                                Spacer()
                                Text(hex)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(UnseenTheme.dim)
                            }
                            .padding(.vertical, 4)
                        }
                    }

                    Divider().overlay(UnseenTheme.border)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("권장 대체 색상")
                            .font(.system(size: 12, weight: .semibold, design: .monospaced))
                            .foregroundStyle(UnseenTheme.accent)

                        ForEach(inspection.suggestions) { suggestion in
                            HStack(spacing: 10) {
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .fill(Color(hex: suggestion.hex) ?? .clear)
                                    .frame(width: 26, height: 26)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                                            .stroke(UnseenTheme.border, lineWidth: 1)
                                    }

                                Text(suggestion.role)
                                    .font(.system(size: 13, weight: .medium))

                                Spacer()

                                Text(suggestion.hex)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(UnseenTheme.dim)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .padding(20)
            }
            .background(UnseenTheme.bg.ignoresSafeArea())
            .navigationTitle("색상 상세 분석")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Helpers
private extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard hex.count == 6, let int = Int(hex, radix: 16) else { return nil }

        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ContentView()
}
