import SwiftUI

// MARK: - Chapter Card Content
/// The visual content of a chapter card (without button behavior)
/// Use this inside NavigationLink or other interactive containers
struct ChapterCardContent: View {
    let chapter: Chapter

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Chapter number with icon
            ZStack {
                Circle()
                    .fill(chapter.accentColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: chapter.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(chapter.accentColor)
            }

            // Chapter info
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text("Chapter \(chapter.id)")
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)

                Text(chapter.title)
                    .font(Theme.Typography.title3)
                    .foregroundStyle(.primary)

                Text(chapter.subtitle)
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer()

            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.tertiary)
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }
}

// MARK: - Chapter Card
/// A card component for displaying a chapter in the Learn tab
/// Use this when you need a standalone tappable card (not inside NavigationLink)
struct ChapterCard: View {
    let chapter: Chapter
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.mediumImpact()
            action()
        }) {
            HStack(spacing: Theme.Spacing.md) {
                // Chapter number with icon
                ZStack {
                    Circle()
                        .fill(chapter.accentColor.opacity(0.15))
                        .frame(width: 56, height: 56)

                    Image(systemName: chapter.iconName)
                        .font(.system(size: 24))
                        .foregroundStyle(chapter.accentColor)
                }

                // Chapter info
                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("Chapter \(chapter.id)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)

                    Text(chapter.title)
                        .font(Theme.Typography.title3)
                        .foregroundStyle(.primary)

                    Text(chapter.subtitle)
                        .font(Theme.Typography.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                // Arrow indicator
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(Theme.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Theme.Colors.secondaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(isPressed ? chapter.accentColor.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(
                color: isPressed ? chapter.accentColor.opacity(0.15) : Color.clear,
                radius: isPressed ? 8 : 0
            )
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

// MARK: - Chapter Progress Card (Alternative Style)
/// A more visual chapter card with progress indicator
struct ChapterProgressCard: View {
    let chapter: Chapter
    var isCompleted: Bool = false
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            HapticManager.mediumImpact()
            action()
        }) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack {
                    // Icon
                    ZStack {
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .fill(chapter.accentColor.opacity(0.15))
                            .frame(width: 44, height: 44)

                        Image(systemName: chapter.iconName)
                            .font(.system(size: 20))
                            .foregroundStyle(chapter.accentColor)
                    }

                    Spacer()

                    // Completion indicator
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.tertiary)
                    }
                }

                Spacer()

                VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                    Text("Chapter \(chapter.id)")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)

                    Text(chapter.title)
                        .font(Theme.Typography.headline)
                        .foregroundStyle(.primary)
                }
            }
            .padding(Theme.Spacing.md)
            .frame(height: 140)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            .scaleEffect(isPressed ? 0.97 : 1.0)
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

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 16) {
            ForEach(Chapter.chapters) { chapter in
                ChapterCard(chapter: chapter) {
                    print("Tapped \(chapter.title)")
                }
            }
        }
        .padding()
    }
}
