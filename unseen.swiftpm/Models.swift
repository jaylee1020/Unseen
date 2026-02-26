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

enum AnalysisConstants {
    static let ocrFrameInterval = 10
    static let maxFindings = 12
    static let minTextHeight: Float = 0.03
    static let passThreshold: Double = 4.5
    static let minOverlayEdge: CGFloat = 10
    static let tapSampleSize: CGFloat = 12
}
