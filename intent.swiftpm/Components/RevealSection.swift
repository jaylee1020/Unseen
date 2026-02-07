import SwiftUI

// MARK: - Progressive Reveal Section
/// Shows interactive content first, with text explanation hidden behind a "Why?" button.
/// Addresses "too much text" feedback by defaulting to visual-first experience.

struct RevealSection<Content: View, Detail: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    @ViewBuilder let detail: () -> Detail

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            // Section title
            SectionHeader(title: title)

            // Main interactive content (always visible)
            content()

            // Expandable detail text
            if isExpanded {
                detail()
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Toggle button
            Button {
                HapticManager.lightImpact()
                withAnimation(Theme.Animation.standard) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: Theme.Spacing.xxs) {
                    Image(systemName: isExpanded ? "chevron.up" : "questionmark.circle")
                        .font(.system(size: 12, weight: .medium))

                    Text(isExpanded ? "Hide" : "Why?")
                        .font(Theme.Typography.caption)
                }
                .foregroundStyle(Color.accentColor.opacity(0.8))
                .padding(.horizontal, Theme.Spacing.sm)
                .padding(.vertical, Theme.Spacing.xxs)
                .background(Color.accentColor.opacity(0.08))
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Simple Reveal (title + content + single text detail)
struct SimpleRevealSection<Content: View>: View {
    let title: String
    let explanation: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        RevealSection(title: title) {
            content()
        } detail: {
            Text(explanation)
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        VStack(spacing: 24) {
            SimpleRevealSection(
                title: "The Horizon Line",
                explanation: "A level horizon feels stable and calm. A tilted horizon creates tension."
            ) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.blue.opacity(0.2))
                    .frame(height: 150)
                    .overlay(Text("Interactive Demo Here"))
            }

            RevealSection(title: "Rule of Thirds") {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.orange.opacity(0.2))
                    .frame(height: 150)
                    .overlay(Text("Interactive Demo Here"))
            } detail: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Place subjects at the intersection points.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                    Text("Notice how off-center placement creates visual interest.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}
