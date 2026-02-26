import CoreGraphics
import Foundation

enum VisionMode: String, CaseIterable, Identifiable {
    case normal = "Normal"
    case deuteranopia = "Deuteranopia"
    case protanopia = "Protanopia"
    case tritanopia = "Tritanopia"

    var id: Self { self }

    var shortLabel: String {
        switch self {
        case .normal: return "Normal"
        case .deuteranopia: return "Red-Green"
        case .protanopia: return "Red-Weak"
        case .tritanopia: return "Blue-Weak"
        }
    }
}

struct ContrastFinding: Identifiable {
    let id = UUID()
    let text: String
    let normalizedBox: CGRect
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

extension SIMD3 where Scalar == Double {
    var rgb255: (r: Int, g: Int, b: Int) {
        (
            Int(max(0, min(255, (x * 255).rounded()))),
            Int(max(0, min(255, (y * 255).rounded()))),
            Int(max(0, min(255, (z * 255).rounded()))))
    }

    var hexString: String {
        let c = rgb255
        return String(format: "#%02X%02X%02X", c.r, c.g, c.b)
    }

    var rgbString: String {
        let c = rgb255
        return "\(c.r), \(c.g), \(c.b)"
    }
}

enum AnalysisConstants {
    static let ocrFrameInterval = 10
    static let maxFindings = 12
    static let minTextHeight: Float = 0.03
    static let passThreshold: Double = 4.5
    static let minOverlayEdge: CGFloat = 10
    static let tapSampleSize: CGFloat = 12
    static let fgInsetXRatio: CGFloat = 0.22
    static let fgInsetYRatio: CGFloat = 0.25
    static let bgInsetXRatio: CGFloat = 0.26
    static let bgInsetYRatio: CGFloat = 0.38
}
