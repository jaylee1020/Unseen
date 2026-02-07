import SwiftUI

// MARK: - Chapter 3: Compose
/// Teaches composition fundamentals
/// Enhanced: Draggable RuleOfThirds subject with snap, draggable vanishing point, Progressive Reveal
struct Chapter3View: View {
    @State private var showRuleOfThirds = true
    @State private var horizonOffset: CGFloat = 0
    @State private var negativeSpaceRatio: CGFloat = 0.7

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Horizon Line — demo first, text behind "Why?"
            SimpleRevealSection(
                title: "The Horizon Line",
                explanation: "A level horizon feels stable and calm. A tilted horizon creates tension — sometimes intentionally, sometimes by accident."
            ) {
                VStack(spacing: Theme.Spacing.xs) {
                    HorizonDemo(offset: $horizonOffset)

                    Text(horizonMessage)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .padding(Theme.Spacing.xs)
                        .frame(maxWidth: .infinity)
                        .background(Theme.Colors.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                }
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Rule of Thirds — now with draggable subject + magnetic snap
            SimpleRevealSection(
                title: "Rule of Thirds",
                explanation: "Place important elements along the lines or at the intersections. Off-center placement creates visual interest and leaves room for the eye to wander."
            ) {
                VStack(spacing: Theme.Spacing.xs) {
                    RuleOfThirdsDemoEnhanced(showGrid: $showRuleOfThirds)

                    Toggle("Show Grid", isOn: $showRuleOfThirds)
                        .font(Theme.Typography.caption)
                        .tint(Color.accentColor)
                        .onChange(of: showRuleOfThirds) { _, _ in
                            HapticManager.lightImpact()
                        }
                }
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Leading Lines — now with draggable vanishing point
            SimpleRevealSection(
                title: "Leading Lines",
                explanation: "Lines in your scene — roads, fences, shadows — guide the viewer's eye toward your subject."
            ) {
                LeadingLinesDemoEnhanced()
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Negative Space
            SimpleRevealSection(
                title: "Negative Space",
                explanation: "Empty space gives your subject room to breathe. When in doubt, include more space — you can always crop later."
            ) {
                NegativeSpaceDemo(negativeSpaceRatio: $negativeSpaceRatio)
            }

            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.md)
    }

    private var horizonMessage: String {
        if abs(horizonOffset) < 3 {
            return "Level horizon: Feels stable and intentional"
        } else if abs(horizonOffset) < 10 {
            return "Slightly tilted: Might look like a mistake"
        } else {
            return "Dramatic tilt: Bold and intentional"
        }
    }
}

// MARK: - Horizon Demo
struct HorizonDemo: View {
    @Binding var offset: CGFloat

    var body: some View {
        ZStack {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .blue.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.green.opacity(0.5), .green.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 100)
                .offset(y: 50)

            Rectangle()
                .fill(.white.opacity(0.8))
                .frame(height: 2)
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        .rotationEffect(.degrees(Double(offset)))
        .gesture(
            DragGesture()
                .onChanged { value in
                    let rotation = value.translation.width / 10
                    offset = max(-20, min(20, rotation))
                }
                .onEnded { _ in
                    withAnimation(Theme.Animation.spring) {
                        if abs(offset) < 5 {
                            HapticManager.snap()
                            offset = 0
                        }
                    }
                }
        )
        .overlay {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: "arrow.left.and.right")
                        .font(.system(size: 12))
                    Text("Drag to tilt")
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
}

// MARK: - Enhanced Rule of Thirds Demo (Draggable + Magnetic Snap)
struct RuleOfThirdsDemoEnhanced: View {
    @Binding var showGrid: Bool
    @State private var subjectPosition: CGPoint = CGPoint(x: 0.67, y: 0.33)
    @State private var isDragging = false
    @State private var isOnPowerPoint = false
    @State private var feedbackText = ""

    // Power points (intersections of thirds)
    private let powerPoints: [CGPoint] = [
        CGPoint(x: 1.0/3.0, y: 1.0/3.0),
        CGPoint(x: 2.0/3.0, y: 1.0/3.0),
        CGPoint(x: 1.0/3.0, y: 2.0/3.0),
        CGPoint(x: 2.0/3.0, y: 2.0/3.0)
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    // Background scene
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Draggable subject
                    Circle()
                        .fill(isOnPowerPoint ? Color.accentColor : Color.primary.opacity(0.7))
                        .frame(width: isDragging ? 55 : 50, height: isDragging ? 55 : 50)
                        .shadow(color: isOnPowerPoint ? .green.opacity(0.5) : .black.opacity(0.2), radius: isOnPowerPoint ? 12 : 4)
                        .position(
                            x: subjectPosition.x * size.width,
                            y: subjectPosition.y * size.height
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isDragging {
                                        HapticManager.lightImpact()
                                    }
                                    isDragging = true

                                    var newX = max(0.1, min(0.9, value.location.x / size.width))
                                    var newY = max(0.1, min(0.9, value.location.y / size.height))

                                    // Magnetic snap to power points
                                    let snapRadius: CGFloat = 0.06
                                    var snapped = false
                                    for pp in powerPoints {
                                        let dist = hypot(newX - pp.x, newY - pp.y)
                                        if dist < snapRadius {
                                            newX = pp.x
                                            newY = pp.y
                                            if !isOnPowerPoint {
                                                HapticManager.snap()
                                                isOnPowerPoint = true
                                            }
                                            snapped = true
                                            break
                                        }
                                    }
                                    if !snapped {
                                        isOnPowerPoint = false
                                    }

                                    subjectPosition = CGPoint(x: newX, y: newY)
                                    updateFeedback()
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    HapticManager.lightImpact()
                                }
                        )
                        .animation(Theme.Animation.snappy, value: isDragging)

                    // Grid overlay
                    if showGrid {
                        RuleOfThirdsGrid(lineColor: .white.opacity(0.8), lineWidth: 1)
                            .transition(.opacity)
                    }

                    // Power point indicators
                    if showGrid {
                        ForEach(0..<4, id: \.self) { index in
                            let pp = powerPoints[index]
                            Circle()
                                .fill(.yellow.opacity(isOnPowerPoint && nearPoint(pp) ? 1.0 : 0.5))
                                .frame(width: isOnPowerPoint && nearPoint(pp) ? 12 : 8,
                                       height: isOnPowerPoint && nearPoint(pp) ? 12 : 8)
                                .position(x: pp.x * size.width, y: pp.y * size.height)
                        }
                        .transition(.opacity)
                    }

                    // Instruction
                    VStack {
                        Spacer()
                        HStack {
                            Image(systemName: "hand.draw")
                                .font(.system(size: 12))
                            Text("Drag the subject to a power point")
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
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            .animation(Theme.Animation.quick, value: showGrid)

            // Dynamic feedback
            if !feedbackText.isEmpty {
                Text(feedbackText)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(isOnPowerPoint ? Color.green : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(Theme.Spacing.xs)
                    .background(isOnPowerPoint ? Color.green.opacity(0.1) : Theme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                    .animation(Theme.Animation.quick, value: feedbackText)
            }
        }
    }

    private func nearPoint(_ pp: CGPoint) -> Bool {
        hypot(subjectPosition.x - pp.x, subjectPosition.y - pp.y) < 0.06
    }

    private func updateFeedback() {
        let centerDist = hypot(subjectPosition.x - 0.5, subjectPosition.y - 0.5)

        if isOnPowerPoint {
            feedbackText = "Power point — strong, intentional placement"
        } else if centerDist < 0.08 {
            feedbackText = "Dead center — static, less dynamic"
        } else {
            feedbackText = "Keep exploring — try the intersection points"
        }
    }
}

// MARK: - Enhanced Leading Lines Demo (Draggable Vanishing Point)
struct LeadingLinesDemoEnhanced: View {
    @State private var subjectPosition: CGPoint = CGPoint(x: 0.7, y: 0.3)
    @State private var vanishingPoint: CGPoint = CGPoint(x: 0.5, y: 0.4)
    @State private var isDraggingSubject = false
    @State private var isDraggingVanishing = false

    private var alignmentScore: CGFloat {
        let dist = hypot(subjectPosition.x - vanishingPoint.x, subjectPosition.y - vanishingPoint.y)
        return max(0, 1 - dist / 0.5)
    }

    private var feedbackText: String {
        if alignmentScore > 0.8 {
            return "Lines lead directly to the subject — strong pull"
        } else if alignmentScore > 0.5 {
            return "Lines suggest the subject — moderate guidance"
        } else {
            return "Lines and subject diverge — visual tension"
        }
    }

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    // Background with dynamic leading lines
                    Canvas { context, canvasSize in
                        let w = canvasSize.width
                        let h = canvasSize.height

                        // Sky
                        context.fill(
                            Path(CGRect(x: 0, y: 0, width: w, height: h * 0.5)),
                            with: .linearGradient(
                                Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)]),
                                startPoint: CGPoint(x: w * 0.5, y: 0),
                                endPoint: CGPoint(x: w * 0.5, y: h * 0.5)
                            )
                        )

                        // Ground
                        context.fill(
                            Path(CGRect(x: 0, y: h * 0.5, width: w, height: h * 0.5)),
                            with: .color(Color.green.opacity(0.3))
                        )

                        // Dynamic road converging to draggable vanishing point
                        let vp = CGPoint(x: vanishingPoint.x * w, y: vanishingPoint.y * h)

                        var roadPath = Path()
                        roadPath.move(to: CGPoint(x: 0, y: h))
                        roadPath.addLine(to: vp)
                        roadPath.addLine(to: CGPoint(x: w, y: h))
                        roadPath.closeSubpath()
                        context.fill(roadPath, with: .color(Color.gray.opacity(0.5)))

                        // Road lines
                        for xRatio in [0.3, 0.7] as [CGFloat] {
                            context.stroke(
                                Path { p in
                                    p.move(to: CGPoint(x: w * xRatio, y: h))
                                    p.addLine(to: vp)
                                },
                                with: .color(Color.yellow.opacity(0.7)),
                                lineWidth: 2
                            )
                        }

                        // Alignment indicator line
                        let subjectPt = CGPoint(x: subjectPosition.x * w, y: subjectPosition.y * h)
                        context.stroke(
                            Path { p in
                                p.move(to: vp)
                                p.addLine(to: subjectPt)
                            },
                            with: .color(Color.green.opacity(Double(alignmentScore) * 0.5)),
                            style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                        )
                    }

                    // Draggable vanishing point
                    ZStack {
                        Circle()
                            .stroke(.white.opacity(0.6), lineWidth: 1)
                            .frame(width: isDraggingVanishing ? 26 : 20, height: isDraggingVanishing ? 26 : 20)
                        Image(systemName: "plus")
                            .font(.system(size: 8, weight: .bold))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .position(
                        x: vanishingPoint.x * size.width,
                        y: vanishingPoint.y * size.height
                    )
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isDraggingVanishing { HapticManager.lightImpact() }
                                isDraggingVanishing = true
                                vanishingPoint = CGPoint(
                                    x: max(0.1, min(0.9, value.location.x / size.width)),
                                    y: max(0.1, min(0.7, value.location.y / size.height))
                                )
                            }
                            .onEnded { _ in
                                isDraggingVanishing = false
                                HapticManager.lightImpact()
                            }
                    )

                    // Draggable subject
                    Circle()
                        .fill(isDraggingSubject ? Color.accentColor : Color.primary.opacity(0.8))
                        .frame(width: 40, height: 40)
                        .shadow(radius: isDraggingSubject ? 8 : 4)
                        .position(
                            x: subjectPosition.x * size.width,
                            y: subjectPosition.y * size.height
                        )
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    if !isDraggingSubject { HapticManager.lightImpact() }
                                    isDraggingSubject = true
                                    subjectPosition = CGPoint(
                                        x: max(0.1, min(0.9, value.location.x / size.width)),
                                        y: max(0.2, min(0.9, value.location.y / size.height))
                                    )
                                }
                                .onEnded { _ in
                                    isDraggingSubject = false
                                    HapticManager.lightImpact()
                                }
                        )
                        .animation(Theme.Animation.snappy, value: isDraggingSubject)

                    // Instruction overlay
                    VStack {
                        Spacer()
                        HStack(spacing: Theme.Spacing.sm) {
                            HStack(spacing: 2) {
                                Circle().fill(.white).frame(width: 6, height: 6)
                                Text("Subject")
                            }
                            HStack(spacing: 2) {
                                Image(systemName: "plus").font(.system(size: 8))
                                Text("Vanishing pt")
                            }
                        }
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(Theme.Spacing.xs)
                        .background(.black.opacity(0.3))
                        .clipShape(Capsule())
                        .padding(Theme.Spacing.sm)
                    }
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))

            // Feedback
            Text(feedbackText)
                .font(Theme.Typography.caption)
                .foregroundStyle(alignmentScore > 0.5 ? Color.green : .secondary)
                .frame(maxWidth: .infinity)
                .padding(Theme.Spacing.xs)
                .background(alignmentScore > 0.5 ? Color.green.opacity(0.1) : Theme.Colors.secondaryBackground)
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
                .animation(Theme.Animation.quick, value: alignmentScore > 0.5)
        }
    }
}

// MARK: - Negative Space Demo
struct NegativeSpaceDemo: View {
    @Binding var negativeSpaceRatio: CGFloat

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            GeometryReader { geometry in
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.15), .cyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    HStack {
                        Spacer()
                            .frame(width: negativeSpaceRatio * geometry.size.width)
                        Circle()
                            .fill(Color.primary.opacity(0.8))
                            .frame(width: 40, height: 40)
                            .shadow(radius: 4)
                        Spacer()
                    }
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))

            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack {
                    Text("Space:")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(Int(negativeSpaceRatio * 100))%")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(Color.accentColor)
                }

                Slider(value: $negativeSpaceRatio, in: 0.2...0.9)
                    .tint(Color.accentColor)
                    .onChange(of: negativeSpaceRatio) { _, _ in
                        HapticManager.selection()
                    }
            }

            Text(negativeSpaceMessage)
                .font(Theme.Typography.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .animation(Theme.Animation.quick, value: negativeSpaceRatio)
        }
    }

    private var negativeSpaceMessage: String {
        if negativeSpaceRatio < 0.4 {
            return "Crowded — subject feels trapped"
        } else if negativeSpaceRatio < 0.6 {
            return "Balanced — consider giving more room"
        } else if negativeSpaceRatio < 0.8 {
            return "Good breathing room — subject stands out"
        } else {
            return "Dramatic isolation — powerful minimalism"
        }
    }
}

// MARK: - Composition Tip
struct CompositionTip: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.accentColor)
                .frame(width: 24)
            Text(text)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            Chapter3View()
        }
        .navigationTitle("Compose")
    }
}
