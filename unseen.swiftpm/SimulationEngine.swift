import CoreImage
import CoreImage.CIFilterBuiltins
import Foundation
import simd

protocol SimulationEngine {
    func simulate(_ image: CIImage, mode: VisionMode) -> CIImage
    func transformColor(_ color: SIMD3<Double>, mode: VisionMode) -> SIMD3<Double>
}

final class CISimulationEngine: SimulationEngine {
    func simulate(_ image: CIImage, mode: VisionMode) -> CIImage {
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

    func transformColor(_ color: SIMD3<Double>, mode: VisionMode) -> SIMD3<Double> {
        let m = modeMatrix(for: mode)
        let r = m[0][0] * color.x + m[0][1] * color.y + m[0][2] * color.z
        let g = m[1][0] * color.x + m[1][1] * color.y + m[1][2] * color.z
        let b = m[2][0] * color.x + m[2][1] * color.y + m[2][2] * color.z
        return SIMD3(max(0, min(1, r)), max(0, min(1, g)), max(0, min(1, b)))
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
                [0.0, 0.24167, 0.75833]
            ]
        case .deuteranopia:
            return [
                [0.625, 0.375, 0.0],
                [0.70, 0.30, 0.0],
                [0.0, 0.30, 0.70]
            ]
        case .tritanopia:
            return [
                [0.95, 0.05, 0.0],
                [0.0, 0.43333, 0.56667],
                [0.0, 0.475, 0.525]
            ]
        }
    }
}
