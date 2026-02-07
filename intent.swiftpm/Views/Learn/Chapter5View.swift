import SwiftUI

// MARK: - Chapter 5: Go Shoot
/// Closing chapter with mini-challenge carousel and journey visualization
/// Enhanced: Interactive recap challenges, animated progress path, ProceduralScene
struct Chapter5View: View {
    @State private var isAppearing = false
    @State private var completedChallenges: Set<Int> = []
    @State private var celebrate = false
    @Environment(\.dismiss) private var dismiss

    var allCompleted: Bool { completedChallenges.count >= 4 }

    var body: some View {
        VStack(spacing: Theme.Spacing.lg) {
            Spacer()
                .frame(height: Theme.Spacing.md)

            // Journey Path Visualization (replaces IllustrationPlaceholder)
            JourneyPathView(completedCount: completedChallenges.count)
                .frame(height: 80)
                .padding(.horizontal, Theme.Spacing.lg)
                .opacity(isAppearing ? 1 : 0)
                .animation(Theme.Animation.slow.delay(0.1), value: isAppearing)

            // Main message
            VStack(spacing: Theme.Spacing.sm) {
                Text("You're Ready")
                    .font(Theme.Typography.largeTitle)
                    .multilineTextAlignment(.center)
                    .opacity(isAppearing ? 1 : 0)
                    .offset(y: isAppearing ? 0 : 20)
                    .animation(Theme.Animation.slow.delay(0.2), value: isAppearing)

                Text("Quick recap — complete each mini-challenge:")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(isAppearing ? 1 : 0)
                    .animation(Theme.Animation.slow.delay(0.3), value: isAppearing)
            }

            // Mini-challenge carousel
            TabView {
                MiniChallengeCard(
                    challengeIndex: 0,
                    title: "See First",
                    color: Theme.Colors.chapter1,
                    icon: "eye.fill",
                    completedChallenges: $completedChallenges,
                    celebrate: $celebrate
                ) {
                    FindCompositionChallenge(
                        isCompleted: completedChallenges.contains(0),
                        onComplete: { completedChallenges.insert(0) }
                    )
                }

                MiniChallengeCard(
                    challengeIndex: 1,
                    title: "Your Lens",
                    color: Theme.Colors.chapter2,
                    icon: "camera.aperture",
                    completedChallenges: $completedChallenges,
                    celebrate: $celebrate
                ) {
                    FocalLengthMatchChallenge(
                        isCompleted: completedChallenges.contains(1),
                        onComplete: { completedChallenges.insert(1) }
                    )
                }

                MiniChallengeCard(
                    challengeIndex: 2,
                    title: "Compose",
                    color: Theme.Colors.chapter3,
                    icon: "square.on.square",
                    completedChallenges: $completedChallenges,
                    celebrate: $celebrate
                ) {
                    PowerPointChallenge(
                        isCompleted: completedChallenges.contains(2),
                        onComplete: { completedChallenges.insert(2) }
                    )
                }

                MiniChallengeCard(
                    challengeIndex: 3,
                    title: "Express",
                    color: Theme.Colors.chapter4,
                    icon: "rectangle.3.group",
                    completedChallenges: $completedChallenges,
                    celebrate: $celebrate
                ) {
                    AspectRatioMatchChallenge(
                        isCompleted: completedChallenges.contains(3),
                        onComplete: { completedChallenges.insert(3) }
                    )
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 260)
            .opacity(isAppearing ? 1 : 0)
            .animation(Theme.Animation.slow.delay(0.4), value: isAppearing)

            Spacer()

            // Go to Try Out — unlocks after all challenges
            VStack(spacing: Theme.Spacing.sm) {
                if allCompleted {
                    NavigateToTryOutButton()
                        .transition(.scale.combined(with: .opacity))

                    Text("Now go see.")
                        .font(.system(size: 28, weight: .light, design: .serif))
                        .italic()
                        .foregroundStyle(.primary)
                        .transition(.opacity)
                } else {
                    Text("Complete all challenges to unlock")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .animation(Theme.Animation.spring, value: allCompleted)
            .celebrationEffect(trigger: $celebrate)

            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isAppearing = true
        }
    }
}

// MARK: - Journey Path Visualization
struct JourneyPathView: View {
    let completedCount: Int

    private let chapters: [(String, Color, String)] = [
        ("eye.fill", .blue, "See"),
        ("camera.aperture", .purple, "Lens"),
        ("square.on.square", .orange, "Compose"),
        ("rectangle.3.group", .pink, "Express"),
        ("camera.fill", .green, "Shoot")
    ]

    var body: some View {
        GeometryReader { geometry in
            let w = geometry.size.width
            let h = geometry.size.height
            let spacing = w / CGFloat(chapters.count - 1)

            ZStack {
                // Connection path
                Path { path in
                    path.move(to: CGPoint(x: 0, y: h * 0.4))
                    for i in 1..<chapters.count {
                        let x = spacing * CGFloat(i)
                        let controlY = i % 2 == 0 ? h * 0.2 : h * 0.6
                        path.addQuadCurve(
                            to: CGPoint(x: x, y: h * 0.4),
                            control: CGPoint(x: x - spacing * 0.5, y: controlY)
                        )
                    }
                }
                .trim(from: 0, to: min(1, CGFloat(completedCount + 1) / CGFloat(chapters.count)))
                .stroke(Color.accentColor.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                .animation(Theme.Animation.slow, value: completedCount)

                // Chapter dots
                ForEach(0..<chapters.count, id: \.self) { i in
                    let x = spacing * CGFloat(i)
                    let (icon, color, label) = chapters[i]
                    let isCompleted = i < completedCount
                    let isCurrent = i == completedCount

                    VStack(spacing: 2) {
                        ZStack {
                            Circle()
                                .fill(isCompleted ? color : color.opacity(0.2))
                                .frame(width: isCurrent ? 32 : 26, height: isCurrent ? 32 : 26)

                            Image(systemName: icon)
                                .font(.system(size: isCurrent ? 14 : 11))
                                .foregroundStyle(isCompleted ? .white : color.opacity(0.5))
                        }

                        Text(label)
                            .font(.system(size: 8))
                            .foregroundStyle(isCompleted ? .primary : .secondary)
                    }
                    .position(x: x, y: h * 0.4)
                    .animation(Theme.Animation.spring, value: completedCount)
                }
            }
        }
    }
}

// MARK: - Mini Challenge Card
struct MiniChallengeCard<Content: View>: View {
    let challengeIndex: Int
    let title: String
    let color: Color
    let icon: String
    @Binding var completedChallenges: Set<Int>
    @Binding var celebrate: Bool
    @ViewBuilder let content: () -> Content

    var isCompleted: Bool { completedChallenges.contains(challengeIndex) }

    var body: some View {
        VStack(spacing: Theme.Spacing.sm) {
            // Header
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(Theme.Typography.headline)
                Spacer()
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .transition(.scale)
                }
            }

            // Challenge content
            content()

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
        .padding(.horizontal, Theme.Spacing.md)
        .onChange(of: completedChallenges.count) { _, newCount in
            if newCount == 4 {
                celebrate = true
            }
        }
    }
}

// MARK: - Mini Challenges

// Challenge 1: Tap the better composition
struct FindCompositionChallenge: View {
    let isCompleted: Bool
    let onComplete: () -> Void
    @State private var selected: Int? = nil

    var body: some View {
        if isCompleted {
            Label("Completed!", systemImage: "checkmark")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: Theme.Spacing.xs) {
                Text("Which feels more intentional?")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: Theme.Spacing.sm) {
                    // Option A: centered subject
                    Button {
                        selected = 0
                        HapticManager.error()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.opacity(0.15))
                            Circle()
                                .fill(.white.opacity(0.6))
                                .frame(width: 20, height: 20) // Dead center
                        }
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selected == 0 ? Color.red : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)

                    // Option B: rule of thirds
                    Button {
                        selected = 1
                        HapticManager.success()
                        onComplete()
                    } label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.blue.opacity(0.15))
                            Circle()
                                .fill(.white.opacity(0.6))
                                .frame(width: 20, height: 20)
                                .offset(x: 20, y: -15) // At thirds intersection
                        }
                        .frame(height: 80)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selected == 1 ? Color.green : .clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

// Challenge 2: Match focal length to description
struct FocalLengthMatchChallenge: View {
    let isCompleted: Bool
    let onComplete: () -> Void
    @State private var selected: String? = nil
    private let correctAnswer = "0.5x"

    var body: some View {
        if isCompleted {
            Label("Completed!", systemImage: "checkmark")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: Theme.Spacing.xs) {
                Text("\"Make it feel vast and dramatic\"")
                    .font(Theme.Typography.caption)
                    .italic()
                    .foregroundStyle(.secondary)

                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(["0.5x", "1x", "2x", "3x"], id: \.self) { lens in
                        Button {
                            selected = lens
                            if lens == correctAnswer {
                                HapticManager.success()
                                onComplete()
                            } else {
                                HapticManager.error()
                            }
                        } label: {
                            Text(lens)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(buttonColor(for: lens))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Theme.Spacing.sm)
                                .background(buttonBG(for: lens))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .disabled(selected != nil)
                    }
                }
            }
        }
    }

    private func buttonColor(for lens: String) -> Color {
        guard let s = selected else { return .primary }
        if lens == s && lens == correctAnswer { return .white }
        if lens == s { return .white }
        return .secondary
    }

    private func buttonBG(for lens: String) -> Color {
        guard let s = selected else { return Theme.Colors.tertiaryBackground }
        if lens == s && lens == correctAnswer { return .green }
        if lens == s { return .red.opacity(0.7) }
        return Theme.Colors.tertiaryBackground
    }
}

// Challenge 3: Drag to power point
struct PowerPointChallenge: View {
    let isCompleted: Bool
    let onComplete: () -> Void
    @State private var position: CGPoint = CGPoint(x: 0.5, y: 0.5)

    private let target = CGPoint(x: 2.0/3.0, y: 1.0/3.0)

    var body: some View {
        if isCompleted {
            Label("Completed!", systemImage: "checkmark")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: Theme.Spacing.xs) {
                Text("Drag the dot to a power point")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                GeometryReader { geo in
                    let s = geo.size
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orange.opacity(0.15))

                        RuleOfThirdsGrid(lineColor: .orange.opacity(0.3))

                        Circle()
                            .fill(Color.accentColor)
                            .frame(width: 24, height: 24)
                            .position(x: position.x * s.width, y: position.y * s.height)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        position = CGPoint(
                                            x: max(0.05, min(0.95, value.location.x / s.width)),
                                            y: max(0.05, min(0.95, value.location.y / s.height))
                                        )
                                        if hypot(position.x - target.x, position.y - target.y) < 0.08 {
                                            position = target
                                            HapticManager.success()
                                            onComplete()
                                        }
                                    }
                            )
                    }
                }
                .frame(height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
}

// Challenge 4: Match aspect ratio
struct AspectRatioMatchChallenge: View {
    let isCompleted: Bool
    let onComplete: () -> Void
    @State private var selected: String? = nil
    private let correctAnswer = "16:9"

    var body: some View {
        if isCompleted {
            Label("Completed!", systemImage: "checkmark")
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.green)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            VStack(spacing: Theme.Spacing.xs) {
                Text("Which ratio is cinematic?")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                HStack(spacing: Theme.Spacing.xs) {
                    ForEach(["4:3", "16:9", "1:1"], id: \.self) { ratio in
                        Button {
                            selected = ratio
                            if ratio == correctAnswer {
                                HapticManager.success()
                                onComplete()
                            } else {
                                HapticManager.error()
                            }
                        } label: {
                            VStack(spacing: 4) {
                                // Visual representation
                                let w: CGFloat = ratio == "16:9" ? 50 : (ratio == "1:1" ? 35 : 40)
                                let h: CGFloat = ratio == "16:9" ? 28 : (ratio == "1:1" ? 35 : 30)
                                RoundedRectangle(cornerRadius: 3)
                                    .stroke(ratioColor(ratio), lineWidth: 1.5)
                                    .frame(width: w, height: h)

                                Text(ratio)
                                    .font(.system(size: 11))
                                    .foregroundStyle(ratioColor(ratio))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, Theme.Spacing.xs)
                            .background(ratioBG(ratio))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                        .disabled(selected != nil)
                    }
                }
            }
        }
    }

    private func ratioColor(_ ratio: String) -> Color {
        guard let s = selected else { return .primary }
        if ratio == s && ratio == correctAnswer { return .white }
        if ratio == s { return .white }
        return .secondary
    }

    private func ratioBG(_ ratio: String) -> Color {
        guard let s = selected else { return Theme.Colors.tertiaryBackground }
        if ratio == s && ratio == correctAnswer { return .green }
        if ratio == s { return .red.opacity(0.7) }
        return Theme.Colors.tertiaryBackground
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let navigateToChapter = Notification.Name("navigateToChapter")
    static let switchToTryOutTab = Notification.Name("switchToTryOutTab")
}

// MARK: - Navigate to Try Out Button
struct NavigateToTryOutButton: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button {
            HapticManager.mediumImpact()
            NotificationCenter.default.post(name: .switchToTryOutTab, object: nil)
            dismiss()
        } label: {
            HStack(spacing: Theme.Spacing.xs) {
                Text("Go to Try Out")
                    .font(Theme.Typography.headline)
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundStyle(.white)
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .background(Color.accentColor)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            Chapter5View()
        }
        .navigationTitle("Go Shoot")
    }
}
