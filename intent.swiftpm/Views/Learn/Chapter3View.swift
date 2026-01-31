import SwiftUI

// MARK: - Chapter 3: Compose
/// Teaches composition fundamentals
struct Chapter3View: View {
    @State private var showRuleOfThirds = true
    @State private var horizonOffset: CGFloat = 0
    @State private var negativeSpaceRatio: CGFloat = 0.7

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Introduction
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "The Art of Composition")

                Text("Composition is how you arrange elements within your frame. It's the difference between a snapshot and a story.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                Text("Good composition guides the viewer's eye exactly where you want it to go.")
                    .font(Theme.Typography.body)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Horizon Line
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "The Horizon Line")

                Text("A level horizon feels stable and calm. A tilted horizon creates tension — sometimes intentionally, sometimes by accident.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Interactive horizon example
                HorizonDemo(offset: $horizonOffset)

                Text(horizonMessage)
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(Theme.Spacing.sm)
                    .frame(maxWidth: .infinity)
                    .background(Theme.Colors.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Rule of Thirds
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Rule of Thirds")

                Text("Divide your frame into nine equal parts. Place important elements along the lines or at the intersections — not dead center.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Interactive grid overlay
                RuleOfThirdsDemo(showGrid: $showRuleOfThirds)

                Toggle("Show Grid", isOn: $showRuleOfThirds)
                    .font(Theme.Typography.subheadline)
                    .tint(Color.accentColor)
                    .onChange(of: showRuleOfThirds) { _, _ in
                        HapticManager.lightImpact()
                    }

                Text("Notice how placing the subject off-center creates visual interest and leaves room for the eye to wander.")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Leading Lines
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Leading Lines")

                Text("Lines in your scene — roads, fences, shadows, architecture — can guide the viewer's eye toward your subject.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Interactive Leading Lines Demo
                LeadingLinesDemo()

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    CompositionTip(icon: "road.lanes", text: "Roads and paths draw the eye into the distance")
                    CompositionTip(icon: "building.2.fill", text: "Architecture creates strong geometric lines")
                    CompositionTip(icon: "sun.min.fill", text: "Shadows can create invisible leading lines")
                }
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Negative Space
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Negative Space")

                Text("Empty space isn't empty — it's a powerful compositional tool. It gives your subject room to breathe and creates visual balance.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Interactive Negative Space Demo
                NegativeSpaceDemo(negativeSpaceRatio: $negativeSpaceRatio)

                Text("Tip: When in doubt, include more space than you think you need. You can always crop later.")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Color.accentColor)
                    .padding(Theme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
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
            return "Dramatic tilt: Bold and intentional — if that's what you want"
        }
    }
}

// MARK: - Horizon Demo
struct HorizonDemo: View {
    @Binding var offset: CGFloat

    var body: some View {
        ZStack {
            // Sky
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.6), .blue.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Ground
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

            // Horizon line indicator
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
                        // Snap to level if close
                        if abs(offset) < 5 {
                            HapticManager.snap()
                            offset = 0
                        }
                    }
                }
        )
        .overlay {
            // Drag hint
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

// MARK: - Rule of Thirds Demo
struct RuleOfThirdsDemo: View {
    @Binding var showGrid: Bool

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                // Background scene placeholder
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.3), .pink.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subject positioned at rule of thirds intersection (2/3 from left, 1/3 from top)
                Circle()
                    .fill(.primary.opacity(0.7))
                    .frame(width: 50, height: 50)
                    .position(x: size.width * 2 / 3, y: size.height / 3)

                // Grid overlay
                if showGrid {
                    RuleOfThirdsGrid(lineColor: .white.opacity(0.8), lineWidth: 1)
                        .transition(.opacity)
                }

                // Intersection points
                if showGrid {
                    ForEach(0..<4, id: \.self) { index in
                        let row = index / 2
                        let col = index % 2
                        Circle()
                            .fill(.yellow)
                            .frame(width: 8, height: 8)
                            .position(
                                x: CGFloat(col + 1) * size.width / 3,
                                y: CGFloat(row + 1) * size.height / 3
                            )
                    }
                    .transition(.opacity)
                }
            }
        }
        .frame(height: 180)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        .animation(Theme.Animation.quick, value: showGrid)
    }
}

// MARK: - Leading Lines Demo
struct LeadingLinesDemo: View {
    @State private var subjectPosition: CGPoint = CGPoint(x: 0.7, y: 0.3)
    @State private var isDragging = false

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size

            ZStack {
                // Background with perspective lines (road)
                Canvas { context, canvasSize in
                    // Sky
                    context.fill(
                        Path(CGRect(x: 0, y: 0, width: canvasSize.width, height: canvasSize.height * 0.5)),
                        with: .linearGradient(
                            Gradient(colors: [Color.blue.opacity(0.4), Color.blue.opacity(0.2)]),
                            startPoint: CGPoint(x: canvasSize.width * 0.5, y: 0),
                            endPoint: CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.5)
                        )
                    )

                    // Ground
                    context.fill(
                        Path(CGRect(x: 0, y: canvasSize.height * 0.5,
                                   width: canvasSize.width, height: canvasSize.height * 0.5)),
                        with: .color(Color.green.opacity(0.3))
                    )

                    // Leading lines (road converging to vanishing point)
                    let vanishingPoint = CGPoint(x: canvasSize.width * 0.5, y: canvasSize.height * 0.4)

                    var roadPath = Path()
                    roadPath.move(to: CGPoint(x: 0, y: canvasSize.height))
                    roadPath.addLine(to: vanishingPoint)
                    roadPath.addLine(to: CGPoint(x: canvasSize.width, y: canvasSize.height))
                    roadPath.closeSubpath()

                    context.fill(roadPath, with: .color(Color.gray.opacity(0.5)))

                    // Road lines
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: canvasSize.width * 0.3, y: canvasSize.height))
                            p.addLine(to: vanishingPoint)
                        },
                        with: .color(Color.yellow.opacity(0.7)),
                        lineWidth: 2
                    )
                    context.stroke(
                        Path { p in
                            p.move(to: CGPoint(x: canvasSize.width * 0.7, y: canvasSize.height))
                            p.addLine(to: vanishingPoint)
                        },
                        with: .color(Color.yellow.opacity(0.7)),
                        lineWidth: 2
                    )
                }

                // Draggable subject (person silhouette)
                Circle()
                    .fill(isDragging ? Color.accentColor : Color.primary.opacity(0.8))
                    .frame(width: 40, height: 40)
                    .shadow(radius: isDragging ? 8 : 4)
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
                                subjectPosition = CGPoint(
                                    x: max(0.1, min(0.9, value.location.x / size.width)),
                                    y: max(0.2, min(0.9, value.location.y / size.height))
                                )
                            }
                            .onEnded { _ in
                                HapticManager.lightImpact()
                                isDragging = false
                            }
                    )
                    .animation(Theme.Animation.snappy, value: isDragging)

                // Instruction overlay
                VStack {
                    Spacer()
                    HStack {
                        Image(systemName: "hand.draw")
                            .font(.system(size: 12))
                        Text("Drag the subject")
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
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }
}

// MARK: - Negative Space Demo
struct NegativeSpaceDemo: View {
    @Binding var negativeSpaceRatio: CGFloat

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            GeometryReader { geometry in
                ZStack {
                    // Background (negative space)
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.15), .cyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // Subject (small circle representing the main subject)
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

            // Slider to adjust negative space
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                HStack {
                    Text("Negative Space:")
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
            return "Too crowded — the subject feels trapped"
        } else if negativeSpaceRatio < 0.6 {
            return "Balanced — but consider giving more room"
        } else if negativeSpaceRatio < 0.8 {
            return "Good breathing room — the subject stands out"
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
