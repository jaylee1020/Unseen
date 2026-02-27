import CoreImage
import CoreImage.CIFilterBuiltins

struct ContrastEstimate {
    let ratio: Double
    let foregroundHex: String
    let backgroundHex: String
}

final class ContrastAnalyzer {
    private let context: CIContext
    private let colorSpace = CGColorSpaceCreateDeviceRGB()

    init(context: CIContext) {
        self.context = context
    }

    func estimateContrast(for normalizedBox: CGRect, in image: CIImage) -> ContrastEstimate? {
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
        return ContrastEstimate(ratio: ratio, foregroundHex: fg.hexString, backgroundHex: bg.hexString)
    }

    func averageColor(in image: CIImage, rect: CGRect) -> SIMD3<Double>? {
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
            colorSpace: colorSpace
        )

        return SIMD3(
            Double(bitmap[0]) / 255.0,
            Double(bitmap[1]) / 255.0,
            Double(bitmap[2]) / 255.0
        )
    }

    func contrastRatio(_ a: SIMD3<Double>, _ b: SIMD3<Double>) -> Double {
        let l1 = relativeLuminance(a)
        let l2 = relativeLuminance(b)
        return (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
    }

    func relativeLuminance(_ c: SIMD3<Double>) -> Double {
        func f(_ v: Double) -> Double {
            if v <= 0.03928 { return v / 12.92 }
            return pow((v + 0.055) / 1.055, 2.4)
        }
        return 0.2126 * f(c.x) + 0.7152 * f(c.y) + 0.0722 * f(c.z)
    }
}
