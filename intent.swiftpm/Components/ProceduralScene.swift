import SwiftUI

// MARK: - Procedural Scene
/// Canvas-based illustrated scenes replacing IllustrationPlaceholder
/// Generates stylized landscapes with configurable elements

enum ScenePreset {
    case seeingVsLooking     // Ch1: Eye with focus visualization
    case photographyLanguage // Ch1: Visual sentence elements
    case focalTrap           // Ch2: 1x trap scene
    case cameraInterface     // Ch2: iPhone camera UI
    case multipleFrames      // Ch4: Multiple crops in one image
    case goShoot             // Ch5: Camera + landscape celebration

    // Computed colors for each scene
    var skyColors: [Color] {
        switch self {
        case .seeingVsLooking: return [.blue.opacity(0.5), .indigo.opacity(0.3)]
        case .photographyLanguage: return [.purple.opacity(0.4), .pink.opacity(0.2)]
        case .focalTrap: return [.orange.opacity(0.4), .yellow.opacity(0.2)]
        case .cameraInterface: return [.gray.opacity(0.3), .gray.opacity(0.1)]
        case .multipleFrames: return [.teal.opacity(0.4), .blue.opacity(0.2)]
        case .goShoot: return [.orange.opacity(0.5), .pink.opacity(0.3)]
        }
    }
}

struct ProceduralScene: View {
    let preset: ScenePreset
    var height: CGFloat = 200
    var expandWidth: Bool = false

    var body: some View {
        Canvas { context, size in
            drawScene(context: context, size: size)
        }
        .frame(maxWidth: expandWidth ? .infinity : nil)
        .frame(width: expandWidth ? nil : 280, height: height)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
    }

    private func drawScene(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Sky gradient background
        let skyGradient = Gradient(colors: preset.skyColors)
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                skyGradient,
                startPoint: CGPoint(x: w * 0.5, y: 0),
                endPoint: CGPoint(x: w * 0.5, y: h)
            )
        )

        switch preset {
        case .seeingVsLooking:
            drawSeeingVsLooking(context: context, size: size)
        case .photographyLanguage:
            drawPhotographyLanguage(context: context, size: size)
        case .focalTrap:
            drawFocalTrap(context: context, size: size)
        case .cameraInterface:
            drawCameraInterface(context: context, size: size)
        case .multipleFrames:
            drawMultipleFrames(context: context, size: size)
        case .goShoot:
            drawGoShoot(context: context, size: size)
        }
    }

    // MARK: - Scene Renderers

    private func drawSeeingVsLooking(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Dividing line
        context.stroke(
            Path { p in
                p.move(to: CGPoint(x: w * 0.5, y: h * 0.1))
                p.addLine(to: CGPoint(x: w * 0.5, y: h * 0.9))
            },
            with: .color(.white.opacity(0.3)),
            lineWidth: 1
        )

        // Left side: "Looking" — scattered shapes
        let scatterPositions: [(CGFloat, CGFloat, CGFloat)] = [
            (0.1, 0.3, 12), (0.3, 0.2, 8), (0.15, 0.7, 10),
            (0.35, 0.6, 14), (0.25, 0.45, 9), (0.08, 0.5, 11),
            (0.4, 0.35, 7), (0.2, 0.8, 13)
        ]
        for (px, py, r) in scatterPositions {
            let rect = CGRect(x: w * px - r/2, y: h * py - r/2, width: r, height: r)
            context.fill(Path(ellipseIn: rect), with: .color(.white.opacity(0.25)))
        }

        // "Looking" eye — wide open, darting
        let leftEyeCenter = CGPoint(x: w * 0.25, y: h * 0.5)
        drawEye(context: context, center: leftEyeCenter, size: 40, pupilOffset: CGPoint(x: 8, y: -3), wide: true)

        // Right side: "Seeing" — one prominent shape with focus ring
        let focusCenter = CGPoint(x: w * 0.75, y: h * 0.45)
        // Focus rings
        for i in 0..<3 {
            let radius = CGFloat(20 + i * 12)
            let opacity = 0.3 - Double(i) * 0.1
            context.stroke(
                Path(ellipseIn: CGRect(
                    x: focusCenter.x - radius,
                    y: focusCenter.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )),
                with: .color(.white.opacity(opacity)),
                lineWidth: 1.5
            )
        }
        // Main subject
        context.fill(
            Path(ellipseIn: CGRect(x: focusCenter.x - 14, y: focusCenter.y - 14, width: 28, height: 28)),
            with: .color(.white.opacity(0.8))
        )

        // "Seeing" eye — focused
        let rightEyeCenter = CGPoint(x: w * 0.75, y: h * 0.8)
        drawEye(context: context, center: rightEyeCenter, size: 36, pupilOffset: CGPoint(x: 0, y: -6), wide: false)

        // Labels
        context.draw(Text("Looking").font(.caption).foregroundColor(.white.opacity(0.6)),
                     at: CGPoint(x: w * 0.25, y: h * 0.12))
        context.draw(Text("Seeing").font(.caption).foregroundColor(.white.opacity(0.6)),
                     at: CGPoint(x: w * 0.75, y: h * 0.12))
    }

    private func drawEye(context: GraphicsContext, center: CGPoint, size: CGFloat, pupilOffset: CGPoint, wide: Bool) {
        // Eye shape
        var eyePath = Path()
        let eyeW = size
        let eyeH = wide ? size * 0.5 : size * 0.35
        eyePath.move(to: CGPoint(x: center.x - eyeW/2, y: center.y))
        eyePath.addQuadCurve(
            to: CGPoint(x: center.x + eyeW/2, y: center.y),
            control: CGPoint(x: center.x, y: center.y - eyeH)
        )
        eyePath.addQuadCurve(
            to: CGPoint(x: center.x - eyeW/2, y: center.y),
            control: CGPoint(x: center.x, y: center.y + eyeH)
        )
        context.fill(eyePath, with: .color(.white.opacity(0.9)))

        // Iris
        let irisR: CGFloat = size * 0.18
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x + pupilOffset.x - irisR,
                y: center.y + pupilOffset.y - irisR,
                width: irisR * 2, height: irisR * 2
            )),
            with: .color(.blue.opacity(0.7))
        )
        // Pupil
        let pupilR: CGFloat = size * 0.08
        context.fill(
            Path(ellipseIn: CGRect(
                x: center.x + pupilOffset.x - pupilR,
                y: center.y + pupilOffset.y - pupilR,
                width: pupilR * 2, height: pupilR * 2
            )),
            with: .color(.black.opacity(0.9))
        )
    }

    private func drawPhotographyLanguage(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Three visual "words" arranged as blocks
        let elements: [(String, CGFloat, Color)] = [
            ("Subject", 0.2, .blue.opacity(0.6)),
            ("Light", 0.5, .yellow.opacity(0.6)),
            ("Composition", 0.8, .green.opacity(0.6))
        ]

        for (label, xRatio, color) in elements {
            let cx = w * xRatio
            let boxW: CGFloat = w * 0.22
            let boxH: CGFloat = h * 0.35

            // Card shape
            let rect = CGRect(x: cx - boxW/2, y: h * 0.25, width: boxW, height: boxH)
            let roundedPath = Path(roundedRect: rect, cornerRadius: 8)
            context.fill(roundedPath, with: .color(color))
            context.stroke(roundedPath, with: .color(.white.opacity(0.4)), lineWidth: 1)

            // Icon circle inside
            let iconR: CGFloat = 14
            context.fill(
                Path(ellipseIn: CGRect(x: cx - iconR, y: h * 0.35 - iconR, width: iconR * 2, height: iconR * 2)),
                with: .color(.white.opacity(0.7))
            )

            // Label
            context.draw(Text(label).font(.system(size: 10, weight: .medium)).foregroundColor(.white.opacity(0.9)),
                         at: CGPoint(x: cx, y: h * 0.55))
        }

        // Connecting arrows
        for xRatio in [0.35, 0.65] as [CGFloat] {
            context.draw(Text("→").font(.system(size: 16)).foregroundColor(.white.opacity(0.5)),
                         at: CGPoint(x: w * xRatio, y: h * 0.42))
        }

        // "= Your Photo" text
        context.draw(Text("= Your Photo").font(.system(size: 12, weight: .semibold)).foregroundColor(.white.opacity(0.7)),
                     at: CGPoint(x: w * 0.5, y: h * 0.82))
    }

    private func drawFocalTrap(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Ground
        context.fill(
            Path(CGRect(x: 0, y: h * 0.6, width: w, height: h * 0.4)),
            with: .color(.brown.opacity(0.2))
        )

        // Centered "1x" tunnel vision circle
        let circleR: CGFloat = min(w, h) * 0.3
        let center = CGPoint(x: w * 0.5, y: h * 0.45)

        // Dimmed outer area
        var outerPath = Path(CGRect(origin: .zero, size: size))
        outerPath.addPath(Path(ellipseIn: CGRect(
            x: center.x - circleR, y: center.y - circleR,
            width: circleR * 2, height: circleR * 2
        )))
        context.fill(outerPath, with: .color(.black.opacity(0.4)))
        // Use clip won't work well here, so just draw a circle of clarity

        // Scene elements hidden in corners
        let elements: [(CGFloat, CGFloat, CGFloat, Color)] = [
            (0.12, 0.25, 18, .green.opacity(0.5)), // Tree
            (0.88, 0.3, 15, .orange.opacity(0.5)),  // Sun detail
            (0.1, 0.75, 20, .blue.opacity(0.5)),    // Water
            (0.9, 0.8, 16, .purple.opacity(0.5))    // Flower
        ]
        for (px, py, r, color) in elements {
            context.fill(
                Path(ellipseIn: CGRect(x: w * px - r, y: h * py - r, width: r * 2, height: r * 2)),
                with: .color(color)
            )
        }

        // Circle outline
        context.stroke(
            Path(ellipseIn: CGRect(x: center.x - circleR, y: center.y - circleR, width: circleR * 2, height: circleR * 2)),
            with: .color(.white.opacity(0.6)),
            lineWidth: 2
        )

        // "1x" label
        context.draw(Text("1x").font(.system(size: 24, weight: .bold, design: .rounded)).foregroundColor(.white.opacity(0.7)),
                     at: center)

        // Small labels for missed subjects
        context.draw(Text("Missed").font(.system(size: 8)).foregroundColor(.white.opacity(0.5)),
                     at: CGPoint(x: w * 0.12, y: h * 0.25 + 26))
        context.draw(Text("Missed").font(.system(size: 8)).foregroundColor(.white.opacity(0.5)),
                     at: CGPoint(x: w * 0.88, y: h * 0.3 + 24))
    }

    private func drawCameraInterface(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Dark phone-like background
        context.fill(
            Path(roundedRect: CGRect(x: w * 0.1, y: h * 0.05, width: w * 0.8, height: h * 0.9), cornerRadius: 16),
            with: .color(.black.opacity(0.8))
        )

        // Viewfinder area
        context.fill(
            Path(roundedRect: CGRect(x: w * 0.14, y: h * 0.1, width: w * 0.72, height: h * 0.5), cornerRadius: 8),
            with: .linearGradient(
                Gradient(colors: [.blue.opacity(0.3), .cyan.opacity(0.2)]),
                startPoint: CGPoint(x: w * 0.5, y: h * 0.1),
                endPoint: CGPoint(x: w * 0.5, y: h * 0.6)
            )
        )

        // Mountain silhouette
        var mountainPath = Path()
        mountainPath.move(to: CGPoint(x: w * 0.14, y: h * 0.55))
        mountainPath.addLine(to: CGPoint(x: w * 0.35, y: h * 0.3))
        mountainPath.addLine(to: CGPoint(x: w * 0.5, y: h * 0.4))
        mountainPath.addLine(to: CGPoint(x: w * 0.7, y: h * 0.25))
        mountainPath.addLine(to: CGPoint(x: w * 0.86, y: h * 0.55))
        mountainPath.closeSubpath()
        context.fill(mountainPath, with: .color(.white.opacity(0.15)))

        // Lens buttons bar
        let lensY = h * 0.7
        let lenses = ["0.5", "1", "2", "3"]
        let barW = w * 0.6
        let startX = w * 0.2
        let spacing = barW / CGFloat(lenses.count)

        // Bar background
        context.fill(
            Path(roundedRect: CGRect(x: startX, y: lensY - 14, width: barW, height: 28), cornerRadius: 14),
            with: .color(.white.opacity(0.15))
        )

        for (i, lens) in lenses.enumerated() {
            let cx = startX + spacing * (CGFloat(i) + 0.5)
            let isSelected = lens == "1"

            if isSelected {
                context.fill(
                    Path(ellipseIn: CGRect(x: cx - 12, y: lensY - 12, width: 24, height: 24)),
                    with: .color(.yellow.opacity(0.8))
                )
            }

            context.draw(
                Text(lens).font(.system(size: 10, weight: isSelected ? .bold : .regular))
                    .foregroundColor(isSelected ? .black : .white.opacity(0.7)),
                at: CGPoint(x: cx, y: lensY)
            )
        }

        // Shutter button
        let shutterY = h * 0.87
        context.stroke(
            Path(ellipseIn: CGRect(x: w * 0.5 - 18, y: shutterY - 18, width: 36, height: 36)),
            with: .color(.white.opacity(0.8)),
            lineWidth: 3
        )
        context.fill(
            Path(ellipseIn: CGRect(x: w * 0.5 - 14, y: shutterY - 14, width: 28, height: 28)),
            with: .color(.white.opacity(0.9))
        )
    }

    private func drawMultipleFrames(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Ground
        context.fill(
            Path(CGRect(x: 0, y: h * 0.55, width: w, height: h * 0.45)),
            with: .color(.green.opacity(0.15))
        )

        // Scene elements
        // Person left
        context.fill(
            Path(ellipseIn: CGRect(x: w * 0.18, y: h * 0.3, width: 20, height: 20)),
            with: .color(.white.opacity(0.7))
        )
        context.fill(
            Path(roundedRect: CGRect(x: w * 0.165, y: h * 0.42, width: 26, height: 36), cornerRadius: 4),
            with: .color(.white.opacity(0.7))
        )

        // Tree center-right
        context.fill(
            Path(roundedRect: CGRect(x: w * 0.58, y: h * 0.4, width: 8, height: 40), cornerRadius: 2),
            with: .color(.brown.opacity(0.5))
        )
        context.fill(
            Path(ellipseIn: CGRect(x: w * 0.5, y: h * 0.15, width: 50, height: 45)),
            with: .color(.green.opacity(0.4))
        )

        // Building right
        context.fill(
            Path(roundedRect: CGRect(x: w * 0.78, y: h * 0.2, width: 30, height: 55), cornerRadius: 2),
            with: .color(.white.opacity(0.4))
        )
        // Windows
        for row in 0..<3 {
            for col in 0..<2 {
                context.fill(
                    Path(CGRect(x: w * 0.785 + CGFloat(col) * 12, y: h * 0.24 + CGFloat(row) * 16, width: 6, height: 8)),
                    with: .color(.yellow.opacity(0.3))
                )
            }
        }

        // Crop frames with dashed lines
        let frames: [(CGRect, Color)] = [
            (CGRect(x: w * 0.08, y: h * 0.2, width: w * 0.32, height: h * 0.65), .white),
            (CGRect(x: w * 0.42, y: h * 0.08, width: w * 0.3, height: h * 0.55), .yellow),
            (CGRect(x: w * 0.7, y: h * 0.12, width: w * 0.25, height: h * 0.7), .green),
        ]

        for (rect, color) in frames {
            context.stroke(
                Path(roundedRect: rect, cornerRadius: 4),
                with: .color(color.opacity(0.7)),
                style: StrokeStyle(lineWidth: 1.5, dash: [6, 3])
            )
        }
    }

    private func drawGoShoot(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Landscape with warm colors
        // Mountains
        var mountain1 = Path()
        mountain1.move(to: CGPoint(x: 0, y: h * 0.7))
        mountain1.addLine(to: CGPoint(x: w * 0.3, y: h * 0.25))
        mountain1.addLine(to: CGPoint(x: w * 0.6, y: h * 0.7))
        mountain1.closeSubpath()
        context.fill(mountain1, with: .color(.purple.opacity(0.3)))

        var mountain2 = Path()
        mountain2.move(to: CGPoint(x: w * 0.3, y: h * 0.7))
        mountain2.addLine(to: CGPoint(x: w * 0.65, y: h * 0.2))
        mountain2.addLine(to: CGPoint(x: w, y: h * 0.7))
        mountain2.closeSubpath()
        context.fill(mountain2, with: .color(.indigo.opacity(0.3)))

        // Ground
        context.fill(
            Path(CGRect(x: 0, y: h * 0.7, width: w, height: h * 0.3)),
            with: .color(.green.opacity(0.2))
        )

        // Sun
        let sunCenter = CGPoint(x: w * 0.75, y: h * 0.2)
        context.fill(
            Path(ellipseIn: CGRect(x: sunCenter.x - 20, y: sunCenter.y - 20, width: 40, height: 40)),
            with: .color(.yellow.opacity(0.6))
        )
        // Sun rays
        for i in 0..<8 {
            let angle = Double(i) * .pi / 4
            let innerR: CGFloat = 24
            let outerR: CGFloat = 34
            context.stroke(
                Path { p in
                    p.move(to: CGPoint(x: sunCenter.x + innerR * cos(angle), y: sunCenter.y + innerR * sin(angle)))
                    p.addLine(to: CGPoint(x: sunCenter.x + outerR * cos(angle), y: sunCenter.y + outerR * sin(angle)))
                },
                with: .color(.yellow.opacity(0.4)),
                lineWidth: 2
            )
        }

        // Camera icon in center
        let camX = w * 0.5
        let camY = h * 0.55
        // Body
        context.fill(
            Path(roundedRect: CGRect(x: camX - 22, y: camY - 14, width: 44, height: 28), cornerRadius: 6),
            with: .color(.white.opacity(0.8))
        )
        // Lens
        context.stroke(
            Path(ellipseIn: CGRect(x: camX - 10, y: camY - 8, width: 20, height: 20)),
            with: .color(.gray.opacity(0.6)),
            lineWidth: 3
        )
        context.fill(
            Path(ellipseIn: CGRect(x: camX - 6, y: camY - 4, width: 12, height: 12)),
            with: .color(.blue.opacity(0.4))
        )
        // Flash hump
        var humpPath = Path()
        humpPath.move(to: CGPoint(x: camX - 8, y: camY - 14))
        humpPath.addLine(to: CGPoint(x: camX - 4, y: camY - 20))
        humpPath.addLine(to: CGPoint(x: camX + 6, y: camY - 20))
        humpPath.addLine(to: CGPoint(x: camX + 10, y: camY - 14))
        context.fill(humpPath, with: .color(.white.opacity(0.8)))
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ProceduralScene(preset: .seeingVsLooking, expandWidth: true)
            ProceduralScene(preset: .photographyLanguage, expandWidth: true)
            ProceduralScene(preset: .focalTrap, height: 140, expandWidth: true)
            ProceduralScene(preset: .cameraInterface, height: 200, expandWidth: true)
            ProceduralScene(preset: .multipleFrames, height: 160, expandWidth: true)
            ProceduralScene(preset: .goShoot, height: 200)
        }
        .padding()
    }
}
