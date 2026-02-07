import SwiftUI

// MARK: - Chapter 2: Your Lens
/// Teaches about focal length and perspective
/// Enhanced: Continuous scrubber, interactive camera UI, ProceduralScene, Progressive Reveal
struct Chapter2View: View {
    @State private var focalLengthValue: CGFloat = 35 // Continuous 13-120mm
    @State private var selectedLensButton: String? = nil

    private var currentFocalLength: FocalLength {
        FocalLength.nearest(to: focalLengthValue)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Section 1: Interactive focal length explorer
            RevealSection(title: "See the Difference") {
                VStack(spacing: Theme.Spacing.md) {
                    // Enhanced preview with perspective simulation
                    FocalLengthPreviewEnhanced(focalLength: focalLengthValue)

                    // Continuous scrubber
                    FocalLengthScrubber(value: $focalLengthValue)

                    // Compact feeling label
                    Text(currentFocalLength.feeling)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(Color.accentColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, Theme.Spacing.xxs)
                        .animation(Theme.Animation.quick, value: currentFocalLength)
                }
            } detail: {
                Text("Focal length changes how much you capture (**field of view**) and how the scene **feels**. Lower mm = wider view. Higher mm = tighter, more compressed.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Section 2: The 1x Trap — replaced with interactive ProceduralScene
            SimpleRevealSection(
                title: "The 1x Trap",
                explanation: "Your iPhone has multiple lenses. The ultra-wide (0.5x) makes spaces vast. The telephoto (2x, 3x) isolates subjects. **Choose your lens before you shoot.**"
            ) {
                ProceduralScene(preset: .focalTrap, height: 140, expandWidth: true)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Section 3: Interactive Camera UI Replica
            SimpleRevealSection(
                title: "Your iPhone's Lenses",
                explanation: "Tap the lens buttons to switch. Long-press for fine adjustment. Explore each lens to find the right perspective."
            ) {
                CameraUIReplica(
                    selectedLens: $selectedLensButton,
                    focalLength: $focalLengthValue
                )
            }

            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.md)
    }
}

// MARK: - Focal Length Model
enum FocalLength: CaseIterable, Identifiable {
    case ultraWide24
    case wide35
    case standard48
    case telephoto77

    var id: String { displayName }

    var displayName: String {
        switch self {
        case .ultraWide24: return "24mm"
        case .wide35: return "35mm"
        case .standard48: return "48mm"
        case .telephoto77: return "77mm"
        }
    }

    var shortName: String {
        switch self {
        case .ultraWide24: return "0.5x"
        case .wide35: return "1x"
        case .standard48: return "2x"
        case .telephoto77: return "3x"
        }
    }

    var mmValue: CGFloat {
        switch self {
        case .ultraWide24: return 24
        case .wide35: return 35
        case .standard48: return 48
        case .telephoto77: return 77
        }
    }

    var feeling: String {
        switch self {
        case .ultraWide24: return "Expansive • Dramatic • Open"
        case .wide35: return "Natural • Balanced • Versatile"
        case .standard48: return "Focused • Flattering • Clean"
        case .telephoto77: return "Intimate • Compressed • Detailed"
        }
    }

    var index: Int {
        switch self {
        case .ultraWide24: return 0
        case .wide35: return 1
        case .standard48: return 2
        case .telephoto77: return 3
        }
    }

    static func nearest(to mm: CGFloat) -> FocalLength {
        let sorted = allCases.sorted { abs($0.mmValue - mm) < abs($1.mmValue - mm) }
        return sorted.first ?? .wide35
    }
}

// MARK: - Enhanced Focal Length Preview
struct FocalLengthPreviewEnhanced: View {
    let focalLength: CGFloat // Continuous 13-120mm

    // Non-uniform scaling for foreground vs background
    private var backgroundScale: CGFloat {
        let normalized = (focalLength - 13) / (120 - 13)
        return 0.5 + normalized * 1.2
    }

    private var foregroundScale: CGFloat {
        let normalized = (focalLength - 13) / (120 - 13)
        return 0.4 + normalized * 1.5
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.4), .cyan.opacity(0.15)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Scene with perspective compression
            Canvas { context, size in
                let w = size.width
                let h = size.height
                let bgS = backgroundScale
                let fgS = foregroundScale

                // Ground
                context.fill(
                    Path(CGRect(x: 0, y: h * 0.55, width: w, height: h * 0.45)),
                    with: .color(.green.opacity(0.2))
                )

                // Background mountains
                let mountainY = h * 0.5
                let mountains: [(CGFloat, CGFloat, CGFloat, Double)] = [
                    (0.3, 60, 50, 0.35), (0.55, 80, 70, 0.3), (0.75, 50, 40, 0.25)
                ]

                for (cx, baseW, baseH, opacity) in mountains {
                    var m = Path()
                    let mW = baseW * bgS
                    let mH = baseH * bgS
                    m.move(to: CGPoint(x: w * cx - mW/2, y: mountainY + mH/2))
                    m.addLine(to: CGPoint(x: w * cx, y: mountainY - mH/2))
                    m.addLine(to: CGPoint(x: w * cx + mW/2, y: mountainY + mH/2))
                    m.closeSubpath()
                    context.fill(m, with: .color(.indigo.opacity(opacity)))
                }

                // Foreground person
                let personX = w * 0.5
                let personBaseY = h * 0.6
                let headR = 12 * fgS
                let bodyW: CGFloat = 18 * fgS
                let bodyH: CGFloat = 24 * fgS

                context.fill(
                    Path(ellipseIn: CGRect(x: personX - headR, y: personBaseY - headR * 2 - bodyH, width: headR * 2, height: headR * 2)),
                    with: .color(.primary.opacity(0.7))
                )
                context.fill(
                    Path(roundedRect: CGRect(x: personX - bodyW/2, y: personBaseY - bodyH, width: bodyW, height: bodyH), cornerRadius: 4),
                    with: .color(.primary.opacity(0.7))
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))

            // Focal length label
            VStack {
                HStack {
                    Text("\(Int(focalLength))mm")
                        .font(Theme.Typography.headline)
                        .monospacedDigit()
                        .padding(.horizontal, Theme.Spacing.sm)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(.ultraThinMaterial)
                        .clipShape(Capsule())

                    Spacer()
                }
                .padding(Theme.Spacing.sm)

                Spacer()
            }
        }
        .frame(height: 220)
        .animation(Theme.Animation.quick, value: focalLength)
    }
}

// MARK: - Continuous Focal Length Scrubber
struct FocalLengthScrubber: View {
    @Binding var value: CGFloat
    @State private var isDragging = false

    private let ticks: [(CGFloat, String)] = [
        (13, "13"), (24, "24"), (35, "35"), (48, "48"), (77, "77"), (120, "120")
    ]

    var body: some View {
        VStack(spacing: Theme.Spacing.xxs) {
            GeometryReader { geometry in
                let width = geometry.size.width

                ZStack(alignment: .leading) {
                    // Track
                    Capsule()
                        .fill(Theme.Colors.secondaryBackground)
                        .frame(height: 6)

                    // Filled track
                    Capsule()
                        .fill(Color.accentColor.opacity(0.6))
                        .frame(width: positionForValue(value, in: width), height: 6)

                    // Tick marks
                    ForEach(ticks, id: \.0) { tick in
                        let x = positionForValue(tick.0, in: width)
                        Rectangle()
                            .fill(Color.secondary.opacity(0.4))
                            .frame(width: 1, height: 14)
                            .position(x: x, y: 12)
                    }

                    // Thumb
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: isDragging ? 28 : 22, height: isDragging ? 28 : 22)
                        .shadow(color: .accentColor.opacity(0.3), radius: isDragging ? 8 : 4)
                        .position(x: positionForValue(value, in: width), y: 12)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { drag in
                                    isDragging = true
                                    let newValue = valueForPosition(drag.location.x, in: width)
                                    let clampedValue = max(13, min(120, newValue))

                                    // Snap to tick marks
                                    let snapDistance: CGFloat = 3
                                    var snappedValue = clampedValue
                                    for (tickValue, _) in ticks {
                                        if abs(clampedValue - tickValue) < snapDistance {
                                            snappedValue = tickValue
                                            if abs(value - tickValue) >= snapDistance {
                                                HapticManager.selection()
                                            }
                                            break
                                        }
                                    }
                                    value = snappedValue
                                }
                                .onEnded { _ in
                                    isDragging = false
                                    HapticManager.lightImpact()
                                }
                        )
                }
                .frame(height: 24)
            }
            .frame(height: 24)

            // Tick labels
            HStack {
                Text("Wide")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("Tele")
                    .font(.system(size: 9))
                    .foregroundStyle(.secondary)
            }
        }
        .animation(Theme.Animation.snappy, value: isDragging)
    }

    private func positionForValue(_ val: CGFloat, in width: CGFloat) -> CGFloat {
        let normalized = (val - 13) / (120 - 13)
        return normalized * width
    }

    private func valueForPosition(_ pos: CGFloat, in width: CGFloat) -> CGFloat {
        let normalized = pos / width
        return 13 + normalized * (120 - 13)
    }
}

// MARK: - Camera UI Replica
struct CameraUIReplica: View {
    @Binding var selectedLens: String?
    @Binding var focalLength: CGFloat

    private let lensOptions: [(String, CGFloat)] = [
        ("0.5", 13), ("1", 26), ("2", 48), ("3", 77), ("5", 120)
    ]

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.black.opacity(0.9))

            VStack(spacing: 0) {
                // Mini viewfinder
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.15)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Canvas { context, size in
                        let w = size.width
                        let h = size.height
                        let scale = (focalLength - 13) / (120 - 13)
                        let mScale = 0.5 + scale * 1.2

                        var mountain = Path()
                        mountain.move(to: CGPoint(x: w * 0.5 - 30 * mScale, y: h * 0.8))
                        mountain.addLine(to: CGPoint(x: w * 0.5, y: h * (0.6 - scale * 0.3)))
                        mountain.addLine(to: CGPoint(x: w * 0.5 + 30 * mScale, y: h * 0.8))
                        mountain.closeSubpath()
                        context.fill(mountain, with: .color(.white.opacity(0.2)))
                    }
                }
                .frame(height: 100)
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.top, Theme.Spacing.sm)

                Spacer()

                // Lens selector bar
                HStack(spacing: 0) {
                    ForEach(lensOptions, id: \.0) { (name, mm) in
                        Button {
                            withAnimation(Theme.Animation.spring) {
                                selectedLens = name
                                focalLength = mm
                            }
                            HapticManager.selection()
                        } label: {
                            let isSelected = selectedLens == name ||
                                (selectedLens == nil && name == "1")
                            Text(name)
                                .font(.system(size: 12, weight: isSelected ? .bold : .regular))
                                .foregroundStyle(isSelected ? .black : .white.opacity(0.7))
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(isSelected ? Color.yellow : Color.clear)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.xs)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.15))
                )
                .padding(.horizontal, Theme.Spacing.lg)

                // Shutter button
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.8), lineWidth: 3)
                        .frame(width: 44, height: 44)
                    Circle()
                        .fill(.white.opacity(0.9))
                        .frame(width: 36, height: 36)
                }
                .padding(.vertical, Theme.Spacing.sm)
            }
        }
        .frame(height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}

// MARK: - Triangle Shape
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            Chapter2View()
        }
        .navigationTitle("Your Lens")
    }
}
