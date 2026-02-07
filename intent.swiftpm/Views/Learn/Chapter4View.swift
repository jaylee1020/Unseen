import SwiftUI

// MARK: - Chapter 4: Express
/// Teaches about aspect ratios and creative expression
/// Enhanced: Mood scenes per ratio, interactive multi-crop discovery, split-line monochrome
struct Chapter4View: View {
    @State private var selectedAspectRatio: AspectRatio = .fourThree
    @State private var monochromeAmount: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Section 1: Aspect Ratios — interactive preview
            RevealSection(title: "Aspect Ratios") {
                VStack(spacing: Theme.Spacing.md) {
                    AspectRatioPreview(selected: selectedAspectRatio)
                    AspectRatioSelector(selected: $selectedAspectRatio)

                    // Compact inline description
                    Text(aspectRatioOneLiner)
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .animation(Theme.Animation.quick, value: selectedAspectRatio)
                }
            } detail: {
                Text("The shape of your image affects how it **feels**. 16:9 is cinematic, 1:1 is balanced, 3:2 is classic film. Choose intentionally.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Section 2: Monochrome — split-line comparison
            SimpleRevealSection(
                title: "The Power of Monochrome",
                explanation: "Black and white removes color distractions — focus on light, shadow, and form. It creates timeless emotional impact."
            ) {
                MonochromeSplitDemo(amount: $monochromeAmount)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Section 3: Multi-crop discovery — now interactive
            SimpleRevealSection(
                title: "Many Photos in One",
                explanation: "A single image can contain multiple stories. Through cropping, you discover photos you never knew you took."
            ) {
                InteractiveMultiCropDemo()
            }

            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.md)
    }

    private var aspectRatioOneLiner: String {
        switch selectedAspectRatio {
        case .free: return "Free — Complete creative control"
        case .fourThree: return "4:3 — Smartphone default, versatile"
        case .sixteenNine: return "16:9 — Cinematic, dramatic landscapes"
        case .oneOne: return "1:1 — Square, symmetrical, social media"
        case .threeTwo: return "3:2 — Classic 35mm film proportions"
        }
    }
}

// MARK: - Aspect Ratio Preview
struct AspectRatioPreview: View {
    let selected: AspectRatio

    private var aspectRatioValue: CGFloat {
        selected.ratio ?? 1.0
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.tertiaryBackground)
                .frame(height: 200)

            // Mood scene per aspect ratio
            ZStack {
                Canvas { context, size in
                    drawMoodScene(context: context, size: size, ratio: selected)
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
            }
            .aspectRatio(aspectRatioValue, contentMode: .fit)
            .frame(maxWidth: 280, maxHeight: 180)
            .animation(Theme.Animation.spring, value: selected)

            // Ratio label
            VStack {
                HStack {
                    Text(selected.rawValue)
                        .font(Theme.Typography.caption)
                        .padding(.horizontal, Theme.Spacing.xs)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())
                    Spacer()
                }
                .padding(Theme.Spacing.sm)
                Spacer()
            }
        }
    }

    private func drawMoodScene(context: GraphicsContext, size: CGSize, ratio: AspectRatio) {
        let w = size.width
        let h = size.height

        switch ratio {
        case .sixteenNine:
            // Cinematic landscape
            context.fill(
                Path(CGRect(origin: .zero, size: size)),
                with: .linearGradient(
                    Gradient(colors: [.orange.opacity(0.5), .pink.opacity(0.3), .purple.opacity(0.2)]),
                    startPoint: CGPoint(x: w * 0.5, y: 0),
                    endPoint: CGPoint(x: w * 0.5, y: h)
                )
            )
            var m = Path()
            m.move(to: CGPoint(x: 0, y: h * 0.75))
            m.addLine(to: CGPoint(x: w * 0.2, y: h * 0.55))
            m.addLine(to: CGPoint(x: w * 0.4, y: h * 0.65))
            m.addLine(to: CGPoint(x: w * 0.7, y: h * 0.5))
            m.addLine(to: CGPoint(x: w, y: h * 0.7))
            m.addLine(to: CGPoint(x: w, y: h))
            m.addLine(to: CGPoint(x: 0, y: h))
            m.closeSubpath()
            context.fill(m, with: .color(.indigo.opacity(0.4)))
            context.fill(Path(ellipseIn: CGRect(x: w * 0.7 - 14, y: h * 0.25, width: 28, height: 28)),
                         with: .color(.yellow.opacity(0.6)))

        case .oneOne:
            // Symmetrical pattern
            context.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .color(.mint.opacity(0.15)))
            for i in stride(from: 4, through: 1, by: -1) {
                let r = CGFloat(i) * min(w, h) * 0.1
                context.fill(
                    Path(ellipseIn: CGRect(x: w/2 - r, y: h/2 - r, width: r * 2, height: r * 2)),
                    with: .color(.teal.opacity(0.1 + Double(5 - i) * 0.08))
                )
            }
            context.fill(Path(ellipseIn: CGRect(x: w/2 - 16, y: h/2 - 16, width: 32, height: 32)),
                         with: .color(.white.opacity(0.8)))

        case .threeTwo:
            // Portrait with bokeh
            context.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .linearGradient(
                            Gradient(colors: [.green.opacity(0.3), .brown.opacity(0.2)]),
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: w, y: h)
                         ))
            let bokehs: [(CGFloat, CGFloat, CGFloat)] = [
                (0.15, 0.2, 18), (0.8, 0.3, 22), (0.1, 0.75, 14),
                (0.85, 0.8, 20), (0.5, 0.15, 12)
            ]
            for (bx, by, br) in bokehs {
                context.fill(
                    Path(ellipseIn: CGRect(x: w * bx, y: h * by, width: br, height: br)),
                    with: .color(.white.opacity(0.15))
                )
            }
            let px = w * 0.4
            context.fill(Path(ellipseIn: CGRect(x: px - 14, y: h * 0.3, width: 28, height: 28)),
                         with: .color(.white.opacity(0.7)))
            context.fill(Path(roundedRect: CGRect(x: px - 16, y: h * 0.3 + 32, width: 32, height: 44), cornerRadius: 6),
                         with: .color(.white.opacity(0.7)))

        default:
            context.fill(Path(CGRect(origin: .zero, size: size)),
                         with: .linearGradient(
                            Gradient(colors: [.blue.opacity(0.4), .purple.opacity(0.3)]),
                            startPoint: CGPoint(x: 0, y: 0),
                            endPoint: CGPoint(x: w, y: h)
                         ))
            context.fill(Path(ellipseIn: CGRect(x: w/2 - 20, y: h/2 - 20, width: 40, height: 40)),
                         with: .color(.white.opacity(0.5)))
        }
    }
}

// MARK: - Aspect Ratio Selector
struct AspectRatioSelector: View {
    @Binding var selected: AspectRatio

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.xs) {
                ForEach(AspectRatio.allCases) { ratio in
                    Button {
                        HapticManager.selection()
                        withAnimation(Theme.Animation.spring) {
                            selected = ratio
                        }
                    } label: {
                        Text(ratio.rawValue)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(selected == ratio ? .white : .primary)
                            .padding(.horizontal, Theme.Spacing.md)
                            .padding(.vertical, Theme.Spacing.sm)
                            .background(
                                Capsule()
                                    .fill(selected == ratio ? Color.accentColor : Theme.Colors.secondaryBackground)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, Theme.Spacing.xxs)
        }
    }
}

// MARK: - Monochrome Split Demo (Drag divider line)
struct MonochromeSplitDemo: View {
    @Binding var amount: CGFloat
    @State private var splitPosition: CGFloat = 0.5
    @State private var isDragging = false

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            GeometryReader { geometry in
                let w = geometry.size.width
                let h = geometry.size.height

                ZStack {
                    // Full color scene
                    Canvas { context, size in
                        drawColorScene(context: context, size: size)
                    }

                    // Monochrome overlay on right side
                    Canvas { context, size in
                        drawColorScene(context: context, size: size)
                    }
                    .saturation(0)
                    .mask(
                        HStack(spacing: 0) {
                            Color.clear
                                .frame(width: splitPosition * w)
                            Color.white
                        }
                    )

                    // Split line
                    Rectangle()
                        .fill(.white)
                        .frame(width: 2, height: h)
                        .position(x: splitPosition * w, y: h / 2)
                        .shadow(color: .black.opacity(0.3), radius: 4)

                    // Drag handle
                    ZStack {
                        Circle()
                            .fill(.white)
                            .frame(width: isDragging ? 32 : 26, height: isDragging ? 32 : 26)
                            .shadow(radius: 4)

                        HStack(spacing: 2) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 8, weight: .bold))
                            Image(systemName: "chevron.right")
                                .font(.system(size: 8, weight: .bold))
                        }
                        .foregroundStyle(.secondary)
                    }
                    .position(x: splitPosition * w, y: h / 2)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                splitPosition = max(0.05, min(0.95, value.location.x / w))
                                amount = splitPosition
                            }
                            .onEnded { _ in
                                isDragging = false
                                HapticManager.lightImpact()
                            }
                    )

                    // Labels
                    HStack {
                        Text("Color")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.3))
                            .clipShape(Capsule())
                            .padding(.leading, Theme.Spacing.sm)

                        Spacer()

                        Text("B&W")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.black.opacity(0.3))
                            .clipShape(Capsule())
                            .padding(.trailing, Theme.Spacing.sm)
                    }
                    .padding(.top, Theme.Spacing.xs)
                    .frame(maxHeight: .infinity, alignment: .top)
                }
            }
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            .animation(Theme.Animation.snappy, value: isDragging)
        }
    }

    private func drawColorScene(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        // Colorful sunset scene
        context.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                Gradient(colors: [.orange, .red.opacity(0.7), .purple.opacity(0.5), .blue.opacity(0.4)]),
                startPoint: CGPoint(x: w * 0.5, y: 0),
                endPoint: CGPoint(x: w * 0.5, y: h)
            )
        )

        for (tx, th) in [(0.15, 0.5), (0.3, 0.4), (0.7, 0.45), (0.85, 0.35)] as [(CGFloat, CGFloat)] {
            context.fill(Path(CGRect(x: w * tx - 3, y: h * (1 - th), width: 6, height: h * th)),
                         with: .color(.brown.opacity(0.6)))
            context.fill(Path(ellipseIn: CGRect(x: w * tx - 16, y: h * (1 - th) - 20, width: 32, height: 28)),
                         with: .color(.green.opacity(0.5)))
        }

        let px = w * 0.5
        context.fill(Path(ellipseIn: CGRect(x: px - 10, y: h * 0.5, width: 20, height: 20)),
                     with: .color(.white.opacity(0.8)))
        context.fill(Path(roundedRect: CGRect(x: px - 12, y: h * 0.5 + 22, width: 24, height: 34), cornerRadius: 4),
                     with: .color(.white.opacity(0.8)))
    }
}

// MARK: - Interactive Multi-Crop Discovery
struct InteractiveMultiCropDemo: View {
    @State private var cropPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    @State private var cropSize: CGFloat = 0.35
    @State private var isDragging = false
    @State private var discoveredFrames: Set<Int> = []
    @State private var celebrate = false

    private let hotZones: [(CGPoint, CGFloat, String, Color)] = [
        (CGPoint(x: 0.2, y: 0.45), 0.12, "Portrait", .blue),
        (CGPoint(x: 0.55, y: 0.3), 0.1, "Detail", .orange),
        (CGPoint(x: 0.82, y: 0.5), 0.1, "Architecture", .green),
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    Canvas { context, canvasSize in
                        drawDiscoveryScene(context: context, size: canvasSize)
                    }

                    // Dark overlay with cutout
                    Rectangle()
                        .fill(Color.black.opacity(0.5))
                        .mask(
                            Rectangle()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(
                                            width: size.width * cropSize,
                                            height: size.width * cropSize * 0.75
                                        )
                                        .position(
                                            x: cropPosition.x * size.width,
                                            y: cropPosition.y * size.height
                                        )
                                        .blendMode(.destinationOut)
                                )
                        )
                        .compositingGroup()

                    // Crop frame
                    let matchIdx = checkHotZoneMatch()
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(matchIdx != nil ? .green : .white, lineWidth: 2)
                        .frame(width: size.width * cropSize, height: size.width * cropSize * 0.75)
                        .position(x: cropPosition.x * size.width, y: cropPosition.y * size.height)

                    // Grid
                    RuleOfThirdsGrid(lineColor: .white.opacity(0.2), lineWidth: 0.5)
                        .frame(width: size.width * cropSize, height: size.width * cropSize * 0.75)
                        .position(x: cropPosition.x * size.width, y: cropPosition.y * size.height)

                    // Counter
                    VStack {
                        HStack {
                            Spacer()
                            Text("\(discoveredFrames.count)/\(hotZones.count)")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.black.opacity(0.5))
                                .clipShape(Capsule())
                                .padding(Theme.Spacing.sm)
                        }
                        Spacer()
                    }

                    // Discovery label
                    if let idx = matchIdx, !discoveredFrames.contains(idx) {
                        Text("\(hotZones[idx].2) found!")
                            .font(Theme.Typography.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, Theme.Spacing.sm)
                            .padding(.vertical, 4)
                            .background(hotZones[idx].3.opacity(0.8))
                            .clipShape(Capsule())
                            .position(x: size.width * 0.5, y: size.height * 0.9)
                            .transition(.scale)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            isDragging = true
                            let newX = max(cropSize / 2, min(1 - cropSize / 2, value.location.x / size.width))
                            let newY = max(cropSize * 0.375, min(1 - cropSize * 0.375, value.location.y / size.height))
                            cropPosition = CGPoint(x: newX, y: newY)

                            if let idx = checkHotZoneMatch() {
                                if !discoveredFrames.contains(idx) {
                                    discoveredFrames.insert(idx)
                                    HapticManager.success()
                                    if discoveredFrames.count == hotZones.count {
                                        celebrate = true
                                    }
                                }
                            }
                        }
                        .onEnded { _ in isDragging = false }
                )
                .celebrationEffect(trigger: $celebrate)
            }
            .frame(height: 180)

            // Discovered thumbnails strip
            if !discoveredFrames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: Theme.Spacing.xs) {
                        ForEach(Array(discoveredFrames.sorted()), id: \.self) { idx in
                            let zone = hotZones[idx]
                            HStack(spacing: 4) {
                                Circle().fill(zone.3).frame(width: 8, height: 8)
                                Text(zone.2).font(.system(size: 11, weight: .medium))
                            }
                            .padding(.horizontal, Theme.Spacing.xs)
                            .padding(.vertical, 4)
                            .background(zone.3.opacity(0.15))
                            .clipShape(Capsule())
                        }
                    }
                }
                .animation(Theme.Animation.spring, value: discoveredFrames.count)
            }
        }
    }

    private func checkHotZoneMatch() -> Int? {
        for (idx, (center, radius, _, _)) in hotZones.enumerated() {
            if hypot(cropPosition.x - center.x, cropPosition.y - center.y) < radius {
                return idx
            }
        }
        return nil
    }

    private func drawDiscoveryScene(context: GraphicsContext, size: CGSize) {
        let w = size.width
        let h = size.height

        context.fill(Path(CGRect(origin: .zero, size: size)),
                     with: .linearGradient(
                        Gradient(colors: [.teal.opacity(0.4), .blue.opacity(0.2)]),
                        startPoint: CGPoint(x: w * 0.5, y: 0),
                        endPoint: CGPoint(x: w * 0.5, y: h)
                     ))
        context.fill(Path(CGRect(x: 0, y: h * 0.55, width: w, height: h * 0.45)),
                     with: .color(.green.opacity(0.2)))

        // Person
        let px = w * 0.2
        context.fill(Path(ellipseIn: CGRect(x: px - 10, y: h * 0.32, width: 20, height: 20)),
                     with: .color(.white.opacity(0.8)))
        context.fill(Path(roundedRect: CGRect(x: px - 12, y: h * 0.32 + 22, width: 24, height: 36), cornerRadius: 4),
                     with: .color(.white.opacity(0.8)))

        // Flower
        for i in 0..<5 {
            let angle = Double(i) * 72 * .pi / 180
            let cx = w * 0.55 + cos(angle) * 10
            let cy = h * 0.3 + sin(angle) * 10
            context.fill(Path(ellipseIn: CGRect(x: cx - 5, y: cy - 5, width: 10, height: 10)),
                         with: .color(.pink.opacity(0.6)))
        }
        context.fill(Path(ellipseIn: CGRect(x: w * 0.55 - 4, y: h * 0.3 - 4, width: 8, height: 8)),
                     with: .color(.yellow.opacity(0.7)))

        // Building
        context.fill(Path(roundedRect: CGRect(x: w * 0.75, y: h * 0.2, width: 35, height: 60), cornerRadius: 2),
                     with: .color(.white.opacity(0.4)))
        for row in 0..<3 {
            for col in 0..<2 {
                context.fill(Path(CGRect(x: w * 0.76 + CGFloat(col) * 14, y: h * 0.25 + CGFloat(row) * 18, width: 8, height: 10)),
                             with: .color(.yellow.opacity(0.3)))
            }
        }

        // Tree
        context.fill(Path(roundedRect: CGRect(x: w * 0.42, y: h * 0.5, width: 6, height: 30), cornerRadius: 2),
                     with: .color(.brown.opacity(0.4)))
        context.fill(Path(ellipseIn: CGRect(x: w * 0.37, y: h * 0.32, width: 36, height: 30)),
                     with: .color(.green.opacity(0.4)))
    }
}

// MARK: - Monochrome Tip
struct MonochromeTip: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14))
                .foregroundStyle(.green)
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
            Chapter4View()
        }
        .navigationTitle("Express")
    }
}
