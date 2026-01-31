import SwiftUI

// MARK: - Chapter 5: Go Shoot
/// Closing chapter with encouragement to practice
struct Chapter5View: View {
    @State private var isAppearing = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            Spacer()
                .frame(height: Theme.Spacing.xl)

            // Illustration placeholder
            IllustrationPlaceholder(
                width: 240,
                height: 200,
                iconName: "camera.fill",
                label: "Go Shoot!"
            )
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.1), value: isAppearing)

            // Main message
            VStack(spacing: Theme.Spacing.md) {
                Text("You're Ready")
                    .font(Theme.Typography.largeTitle)
                    .multilineTextAlignment(.center)
                    .opacity(isAppearing ? 1 : 0)
                    .offset(y: isAppearing ? 0 : 20)
                    .animation(Theme.Animation.slow.delay(0.2), value: isAppearing)

                Text("You've learned the fundamentals. You understand that great photos come from intention, not chance.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)
                    .opacity(isAppearing ? 1 : 0)
                    .offset(y: isAppearing ? 0 : 20)
                    .animation(Theme.Animation.slow.delay(0.3), value: isAppearing)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.md)
                .padding(.horizontal, Theme.Spacing.xl)
                .opacity(isAppearing ? 1 : 0)
                .animation(Theme.Animation.slow.delay(0.4), value: isAppearing)

            // Recap points - Now tappable!
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                TappableRecapItem(
                    icon: "eye.fill",
                    color: .blue,
                    title: "See First",
                    text: "Look for meaning before you shoot",
                    chapterId: 1
                )

                TappableRecapItem(
                    icon: "camera.aperture",
                    color: .purple,
                    title: "Choose Your Lens",
                    text: "Each focal length tells a different story",
                    chapterId: 2
                )

                TappableRecapItem(
                    icon: "square.on.square",
                    color: .orange,
                    title: "Compose with Intent",
                    text: "Guide the eye, create balance",
                    chapterId: 3
                )

                TappableRecapItem(
                    icon: "rectangle.3.group",
                    color: .pink,
                    title: "Express Yourself",
                    text: "Aspect ratio and style are your voice",
                    chapterId: 4
                )
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.5), value: isAppearing)

            Spacer()

            // Practice encouragement
            VStack(spacing: Theme.Spacing.md) {
                Text("Practice in the **Try Out** tab — import photos and find multiple frames hiding in a single image.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Theme.Spacing.lg)

                // Navigate to Try Out tab
                NavigateToTryOutButton()
            }
            .opacity(isAppearing ? 1 : 0)
            .offset(y: isAppearing ? 0 : 20)
            .animation(Theme.Animation.slow.delay(0.6), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.md)

            // Closing line
            Text("Now go see.")
                .font(.system(size: 28, weight: .light, design: .serif))
                .italic()
                .foregroundStyle(.primary)
                .opacity(isAppearing ? 1 : 0)
                .animation(Theme.Animation.slow.delay(0.8), value: isAppearing)

            Spacer()
                .frame(height: Theme.Spacing.xxl)
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            isAppearing = true
        }
    }
}

// MARK: - Tappable Recap Item
struct TappableRecapItem: View {
    let icon: String
    let color: Color
    let title: String
    let text: String
    let chapterId: Int
    @Environment(\.dismiss) private var dismiss

    @State private var isPressed = false

    var body: some View {
        Button {
            HapticManager.mediumImpact()
            // Dismiss current view and navigate to the chapter
            dismiss()
            // Post notification to navigate to specific chapter
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                NotificationCenter.default.post(
                    name: .navigateToChapter,
                    object: nil,
                    userInfo: ["chapterId": chapterId]
                )
            }
        } label: {
            HStack(spacing: Theme.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text(title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)

                    Text(text)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(Theme.Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(isPressed ? Theme.Colors.tertiaryBackground : Color.clear)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .animation(Theme.Animation.snappy, value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(Theme.Animation.snappy) {
                isPressed = pressing
            }
        }, perform: {})
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
            // This will be handled by the parent to switch tabs
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
