import SwiftUI

// MARK: - Chapter 1: See First
/// Teaches the difference between a snapshot and a photograph
/// Enhanced: Draggable viewfinder, ProceduralScene, Progressive Reveal, CelebrationEffect
struct Chapter1View: View {
    @State private var showFeedback = false
    @State private var celebrate = false

    // Viewfinder state
    @State private var viewfinderPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var viewfinderLocked = false
    @State private var nearHotspot = false
    @State private var discoveredHotspot: Int? = nil

    // Hotspot positions (normalized 0-1) — strong compositions
    private let hotspots: [(CGPoint, String)] = [
        (CGPoint(x: 0.3, y: 0.35), "Strong diagonal, subject at thirds"),
        (CGPoint(x: 0.72, y: 0.4), "Leading lines toward subject"),
        (CGPoint(x: 0.5, y: 0.7), "Low angle, dramatic perspective")
    ]

    private let viewfinderSize: CGFloat = 0.35 // 35% of container

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Section 1: Interactive Viewfinder Exercise
            RevealSection(title: "Find the Photograph") {
                // Interactive viewfinder over procedural scene
                viewfinderExercise
            } detail: {
                Text("A snapshot captures what's in front of you. A photograph communicates what you **saw** — the feeling, the moment, the meaning.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Section 2: Seeing vs Looking
            SimpleRevealSection(
                title: "Seeing vs. Looking",
                explanation: "Looking scans everything equally. Seeing pauses, finds meaning, and frames it with intention."
            ) {
                ProceduralScene(preset: .seeingVsLooking, height: 180, expandWidth: true)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Section 3: Photography as Language
            SimpleRevealSection(
                title: "Photography is a Language",
                explanation: "Composition is your sentence structure. Light is your tone. Subject is your subject. Every photo **says** something."
            ) {
                ProceduralScene(preset: .photographyLanguage, height: 160, expandWidth: true)
            }

            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.md)
    }

    // MARK: - Viewfinder Exercise
    private var viewfinderExercise: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                // Procedural scene as background
                Canvas { context, canvasSize in
                    drawViewfinderScene(context: context, size: canvasSize)
                }

                // Dark overlay with viewfinder cutout
                Rectangle()
                    .fill(Color.black.opacity(viewfinderLocked ? 0.3 : 0.55))
                    .mask(
                        Rectangle()
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(
                                        width: size.width * viewfinderSize,
                                        height: size.width * viewfinderSize * 0.75
                                    )
                                    .position(
                                        x: viewfinderPosition.x * size.width,
                                        y: viewfinderPosition.y * size.height
                                    )
                                    .blendMode(.destinationOut)
                            )
                    )
                    .compositingGroup()

                // Viewfinder border
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        viewfinderLocked ? Color.green :
                            (nearHotspot ? Color.green.opacity(0.8) : Color.white.opacity(0.8)),
                        lineWidth: nearHotspot ? 3 : 2
                    )
                    .frame(
                        width: size.width * viewfinderSize,
                        height: size.width * viewfinderSize * 0.75
                    )
                    .position(
                        x: viewfinderPosition.x * size.width,
                        y: viewfinderPosition.y * size.height
                    )
                    .shadow(color: nearHotspot ? .green.opacity(0.5) : .clear, radius: 8)

                // Rule of thirds grid inside viewfinder
                if !viewfinderLocked {
                    RuleOfThirdsGrid(lineColor: .white.opacity(0.3), lineWidth: 0.5)
                        .frame(
                            width: size.width * viewfinderSize,
                            height: size.width * viewfinderSize * 0.75
                        )
                        .position(
                            x: viewfinderPosition.x * size.width,
                            y: viewfinderPosition.y * size.height
                        )
                }

                // Feedback overlay
                if let hotspotIdx = discoveredHotspot {
                    VStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.green)

                        Text(hotspots[hotspotIdx].1)
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                    }
                    .padding(Theme.Spacing.sm)
                    .background(.black.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                    .position(
                        x: size.width * 0.5,
                        y: size.height * 0.88
                    )
                    .transition(.opacity)
                }

                // Drag instruction
                if !viewfinderLocked && discoveredHotspot == nil {
                    VStack {
                        Spacer()
                        HStack(spacing: Theme.Spacing.xxs) {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 12))
                            Text("Drag to find a strong composition")
                                .font(Theme.Typography.caption)
                        }
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(Theme.Spacing.xs)
                        .background(.black.opacity(0.3))
                        .clipShape(Capsule())
                        .padding(Theme.Spacing.sm)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            .gesture(
                viewfinderLocked ? nil :
                DragGesture()
                    .onChanged { value in
                        let newX = max(viewfinderSize / 2, min(1 - viewfinderSize / 2, value.location.x / size.width))
                        let newY = max(viewfinderSize * 0.375, min(1 - viewfinderSize * 0.375, value.location.y / size.height))
                        viewfinderPosition = CGPoint(x: newX, y: newY)

                        // Check proximity to hotspots
                        let wasNear = nearHotspot
                        nearHotspot = false
                        for (i, (hotspot, _)) in hotspots.enumerated() {
                            let dist = hypot(viewfinderPosition.x - hotspot.x, viewfinderPosition.y - hotspot.y)
                            if dist < 0.1 {
                                nearHotspot = true
                                if !wasNear {
                                    HapticManager.snap()
                                }
                                // Snap closer
                                if dist < 0.06 && discoveredHotspot == nil {
                                    withAnimation(Theme.Animation.spring) {
                                        viewfinderPosition = hotspot
                                        discoveredHotspot = i
                                        viewfinderLocked = true
                                    }
                                    HapticManager.success()
                                    celebrate = true
                                }
                                break
                            }
                        }
                    }
            )
            .celebrationEffect(trigger: $celebrate)
        }
        .frame(height: 260)
        .overlay(alignment: .topTrailing) {
            // Reset button when locked
            if viewfinderLocked {
                Button {
                    withAnimation(Theme.Animation.standard) {
                        viewfinderLocked = false
                        discoveredHotspot = nil
                        nearHotspot = false
                        viewfinderPosition = CGPoint(x: 0.5, y: 0.5)
                    }
                    HapticManager.lightImpact()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white)
                        .padding(Theme.Spacing.xs)
                        .background(.black.opacity(0.5))
                        .clipShape(Circle())
                }
                .padding(Theme.Spacing.sm)
            }
        }
        .animation(Theme.Animation.quick, value: nearHotspot)
        .animation(Theme.Animation.standard, value: viewfinderLocked)
    }

    // MARK: - Scene Drawing
    private func drawViewfinderScene(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Sky gradient
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [Color.blue.opacity(0.5), Color.cyan.opacity(0.2), Color.orange.opacity(0.15)]),
                startPoint: CGPoint(x: w * 0.5, y: 0),
                endPoint: CGPoint(x: w * 0.5, y: h)
            )
        )

        // Mountains (background)
        var bgMountain = Path()
        bgMountain.move(to: CGPoint(x: 0, y: h * 0.65))
        bgMountain.addLine(to: CGPoint(x: w * 0.15, y: h * 0.3))
        bgMountain.addLine(to: CGPoint(x: w * 0.35, y: h * 0.45))
        bgMountain.addLine(to: CGPoint(x: w * 0.55, y: h * 0.2))
        bgMountain.addLine(to: CGPoint(x: w * 0.75, y: h * 0.4))
        bgMountain.addLine(to: CGPoint(x: w, y: h * 0.3))
        bgMountain.addLine(to: CGPoint(x: w, y: h * 0.65))
        bgMountain.closeSubpath()
        context.fill(bgMountain, with: .color(.indigo.opacity(0.3)))

        // Ground with path
        context.fill(
            Path(CGRect(x: 0, y: h * 0.6, width: w, height: h * 0.4)),
            with: .color(.green.opacity(0.25))
        )

        // Winding path (leading line)
        context.stroke(
            Path { p in
                p.move(to: CGPoint(x: w * 0.5, y: h))
                p.addCurve(
                    to: CGPoint(x: w * 0.55, y: h * 0.4),
                    control1: CGPoint(x: w * 0.3, y: h * 0.8),
                    control2: CGPoint(x: w * 0.7, y: h * 0.6)
                )
            },
            with: .color(.brown.opacity(0.4)),
            lineWidth: 8
        )

        // Tree (left)
        context.fill(
            Path(roundedRect: CGRect(x: w * 0.18, y: h * 0.42, width: 6, height: 30), cornerRadius: 2),
            with: .color(.brown.opacity(0.5))
        )
        context.fill(
            Path(ellipseIn: CGRect(x: w * 0.13, y: h * 0.25, width: 40, height: 35)),
            with: .color(.green.opacity(0.5))
        )

        // Person (right-center, at rule of thirds)
        let personX = w * 0.72
        let personY = h * 0.38
        context.fill(
            Path(ellipseIn: CGRect(x: personX - 8, y: personY - 8, width: 16, height: 16)),
            with: .color(.white.opacity(0.8))
        )
        context.fill(
            Path(roundedRect: CGRect(x: personX - 10, y: personY + 10, width: 20, height: 28), cornerRadius: 4),
            with: .color(.white.opacity(0.8))
        )

        // Flowers (foreground left)
        for i in 0..<4 {
            let fx = w * 0.08 + CGFloat(i) * 18
            let fy = h * 0.78 - CGFloat(i % 2) * 8
            context.fill(
                Path(ellipseIn: CGRect(x: fx - 4, y: fy - 4, width: 8, height: 8)),
                with: .color([Color.pink, .yellow, .red, .orange][i].opacity(0.6))
            )
        }

        // Sun (top-right)
        let sunCenter = CGPoint(x: w * 0.82, y: h * 0.12)
        context.fill(
            Path(ellipseIn: CGRect(x: sunCenter.x - 16, y: sunCenter.y - 16, width: 32, height: 32)),
            with: .color(.yellow.opacity(0.5))
        )
    }
}

// MARK: - Supporting Components

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(Theme.Typography.title2)
    }
}

struct FeedbackCard: View {
    let isCorrect: Bool

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                .font(.system(size: 24))
                .foregroundStyle(isCorrect ? .green : .orange)

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(isCorrect ? "Great eye!" : "Good observation!")
                    .font(Theme.Typography.headline)

                Text(isCorrect
                     ? "You noticed how the tighter crop focuses attention and creates a stronger emotional connection."
                     : "Both crops have merit, but the other option draws the eye more directly to the subject, creating a stronger sense of intention.")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(isCorrect ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            Chapter1View()
        }
        .navigationTitle("See First")
    }
}
