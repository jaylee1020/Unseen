import SwiftUI

// MARK: - Liquid Glass Button Style
/// A button style that applies the iOS 26 liquid glass effect when available,
/// with a beautiful glassmorphism fallback for older iOS versions
struct LiquidGlassButtonStyle: ButtonStyle {
    var isSelected: Bool = false
    var tint: Color? = nil

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background {
                if #available(iOS 26.0, *) {
                    // iOS 26+ Liquid Glass
                    Capsule()
                        .fill(.clear)
                        .glassEffect()
                } else {
                    // Fallback glassmorphism for iOS 18+
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        }
                }
            }
            .foregroundStyle(tint ?? .primary)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.lightImpact()
                }
            }
    }
}

// MARK: - Liquid Glass Aspect Ratio Button
/// Specialized button for aspect ratio selection with liquid glass effect
struct LiquidGlassAspectRatioButton: View {
    let ratio: AspectRatio
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(ratio.rawValue)
                .font(Theme.Typography.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
        }
        .buttonStyle(LiquidGlassAspectRatioButtonStyle(isSelected: isSelected))
    }
}

// MARK: - Liquid Glass Aspect Ratio Button Style
struct LiquidGlassAspectRatioButtonStyle: ButtonStyle {
    var isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .foregroundStyle(isSelected ? .white : .white.opacity(0.8))
            .background {
                if #available(iOS 26.0, *) {
                    // iOS 26+ Liquid Glass
                    Capsule()
                        .fill(isSelected ? Color.white.opacity(0.3) : Color.clear)
                        .glassEffect()
                } else {
                    // Fallback glassmorphism
                    Capsule()
                        .fill(isSelected ? .ultraThickMaterial : .ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .stroke(
                                    isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.2),
                                    lineWidth: isSelected ? 1 : 0.5
                                )
                        }
                }
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.selection()
                }
            }
    }
}

// MARK: - Liquid Glass Action Button
/// A prominent action button with liquid glass effect (for Add Frame, Add Another, Save to Photos)
struct LiquidGlassActionButton: View {
    let title: String
    let icon: String
    var isPrimary: Bool = false
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            if isLoading {
                ProgressView()
                    .tint(.white)
                    .frame(height: 20)
            } else {
                Label(title, systemImage: icon)
                    .font(Theme.Typography.subheadline)
                    .fontWeight(.medium)
            }
        }
        .buttonStyle(LiquidGlassActionButtonStyle(isPrimary: isPrimary))
        .disabled(isLoading)
    }
}

// MARK: - Liquid Glass Action Button Style
struct LiquidGlassActionButtonStyle: ButtonStyle {
    var isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.sm)
            .foregroundStyle(.white)
            .background {
                if #available(iOS 26.0, *) {
                    // iOS 26+ Liquid Glass with tint
                    Capsule()
                        .fill(isPrimary ? Color.accentColor.opacity(0.3) : Color.white.opacity(0.1))
                        .glassEffect()
                } else {
                    // Fallback glassmorphism
                    Capsule()
                        .fill(isPrimary ? .regularMaterial : .ultraThinMaterial)
                        .overlay {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: isPrimary
                                            ? [Color.accentColor.opacity(0.4), Color.accentColor.opacity(0.2)]
                                            : [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .overlay {
                            Capsule()
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 0.5
                                )
                        }
                }
            }
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(Theme.Animation.quick, value: configuration.isPressed)
            .onChange(of: configuration.isPressed) { _, isPressed in
                if isPressed {
                    HapticManager.mediumImpact()
                }
            }
    }
}

// MARK: - Liquid Glass Full Width Button
/// A full-width liquid glass button for prominent actions like "Add Frame"
struct LiquidGlassFullWidthButton: View {
    let title: String
    let icon: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Label(title, systemImage: icon)
            .font(Theme.Typography.headline)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .foregroundStyle(.white)
            .background(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Color.accentColor)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .opacity(isPressed ? 0.9 : 1.0)
            .animation(Theme.Animation.quick, value: isPressed)
            .onTapGesture {
                HapticManager.mediumImpact()
                action()
            }
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        // Background image to show glass effect
        LinearGradient(
            colors: [.purple, .blue, .cyan],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()

        VStack(spacing: 24) {
            // Aspect ratio buttons
            HStack(spacing: 8) {
                ForEach(AspectRatio.allCases.prefix(4)) { ratio in
                    LiquidGlassAspectRatioButton(
                        ratio: ratio,
                        isSelected: ratio == .free
                    ) {}
                }
            }

            // Action buttons
            HStack(spacing: 16) {
                LiquidGlassActionButton(
                    title: "Add Another",
                    icon: "plus.viewfinder",
                    isPrimary: true
                ) {}

                LiquidGlassActionButton(
                    title: "Save to Photos",
                    icon: "square.and.arrow.down"
                ) {}
            }

            // Full width button
            LiquidGlassFullWidthButton(
                title: "Add Frame",
                icon: "plus.viewfinder"
            ) {}
            .padding(.horizontal, 20)
        }
    }
}
