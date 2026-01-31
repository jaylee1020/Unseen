import SwiftUI

// MARK: - Chapter 4: Express
/// Teaches about aspect ratios and creative expression
struct Chapter4View: View {
    @State private var selectedAspectRatio: AspectRatio = .fourThree
    @State private var monochromeAmount: CGFloat = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Introduction
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Creative Expression")

                Text("Photography isn't just about what you capture — it's about **how** you present it. Aspect ratio, color choices, and cropping are all part of your creative voice.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Aspect Ratios
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Aspect Ratios")

                Text("The shape of your image affects how it feels. Choose intentionally.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Interactive aspect ratio preview
                AspectRatioPreview(selected: selectedAspectRatio)

                // Aspect ratio selector
                AspectRatioSelector(selected: $selectedAspectRatio)

                // Description
                AspectRatioDescription(aspectRatio: selectedAspectRatio)
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Monochrome Section
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "The Power of Monochrome")

                Text("Black and white isn't just a filter — it's a creative decision made **before** you shoot.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Interactive Color vs B&W transition demo
                MonochromeTransitionDemo(amount: $monochromeAmount)

                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    MonochromeTip(text: "Removes color distractions — focus on light, shadow, and form")
                    MonochromeTip(text: "Creates timeless, emotional impact")
                    MonochromeTip(text: "Works especially well for portraits and architecture")
                }

                Text("Tip: On iPhone, enable the Photographic Styles setting for \"Black & White\" to see your composition without color distraction while shooting.")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(Color.accentColor)
                    .padding(Theme.Spacing.sm)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.accentColor.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.small))
            }

            Divider()
                .padding(.vertical, Theme.Spacing.sm)

            // Finding Multiple Photos
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Many Photos in One")

                Text("A single image can contain multiple stories. Through cropping, you can find photos you never knew you took.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Multi-crop illustration
                MultiCropDemo()

                Text("This is the power of seeing after shooting. One wide shot might contain a landscape, a portrait, and an abstract detail — all waiting to be discovered.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)

                // Illustration placeholder
                IllustrationPlaceholder(
                    height: 140,
                    iconName: "square.on.square.dashed",
                    label: "Multiple Frames",
                    expandWidth: true
                )
            }

            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.md)
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
            // Outer container
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(Theme.Colors.tertiaryBackground)
                .frame(height: 200)

            // Inner preview with aspect ratio
            ZStack {
                RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.4), .purple.opacity(0.4)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                // Subject placeholder
                Circle()
                    .fill(.white.opacity(0.5))
                    .frame(width: 40, height: 40)
            }
            .aspectRatio(aspectRatioValue, contentMode: .fit)
            .frame(maxWidth: 280, maxHeight: 180)
            .animation(Theme.Animation.spring, value: selected)
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

// MARK: - Aspect Ratio Description
struct AspectRatioDescription: View {
    let aspectRatio: AspectRatio

    var description: (title: String, body: String) {
        switch aspectRatio {
        case .free:
            return ("Free Form", "No constraints — crop exactly as you see fit. Best for when you need complete creative control.")
        case .fourThree:
            return ("4:3 — The Default", "The native aspect ratio of most smartphone cameras. Balanced and versatile for everyday shots.")
        case .sixteenNine:
            return ("16:9 — Cinematic", "Wide and dramatic, like a movie frame. Perfect for landscapes and scenes with horizontal movement.")
        case .oneOne:
            return ("1:1 — Square", "Equal on all sides. Classic, balanced, and perfect for symmetrical subjects or social media.")
        case .threeTwo:
            return ("3:2 — Classic Film", "The aspect ratio of 35mm film. Photographers love it for its natural, slightly wide proportions.")
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(description.title)
                .font(Theme.Typography.headline)

            Text(description.body)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        .animation(Theme.Animation.quick, value: aspectRatio)
    }
}

// MARK: - Monochrome Transition Demo
struct MonochromeTransitionDemo: View {
    @Binding var amount: CGFloat // 0 = full color, 1 = full B&W

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Interactive color-to-B&W preview using saturation modifier
            ZStack {
                // Color gradient that gets desaturated
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(
                        LinearGradient(
                            colors: [.orange, .red, .purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 140)
                    .saturation(1 - amount) // 1 = full color, 0 = grayscale

                // Subject silhouette
                VStack(spacing: 4) {
                    Circle()
                        .fill(.white.opacity(0.9))
                        .frame(width: 30, height: 30)
                    Capsule()
                        .fill(.white.opacity(0.9))
                        .frame(width: 40, height: 50)
                }
                .shadow(radius: 4)
            }

            // Slider
            VStack(spacing: Theme.Spacing.xs) {
                HStack {
                    Text("Color")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("Monochrome")
                        .font(Theme.Typography.caption)
                        .foregroundStyle(.secondary)
                }

                Slider(value: $amount, in: 0...1)
                    .tint(Color.gray)
                    .onChange(of: amount) { _, _ in
                        HapticManager.selection()
                    }
            }

            // Dynamic message
            Text(monochromeMessage)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .animation(Theme.Animation.quick, value: amount)
        }
    }

    private var monochromeMessage: String {
        if amount < 0.3 {
            return "Full color captures the vibrancy of the scene"
        } else if amount < 0.7 {
            return "Desaturating focuses attention on light and form"
        } else {
            return "Pure monochrome removes all color distraction"
        }
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

// MARK: - Multi Crop Demo
struct MultiCropDemo: View {
    var body: some View {
        ZStack {
            // Original image background
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(
                    LinearGradient(
                        colors: [.orange.opacity(0.3), .blue.opacity(0.3)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            // Simulated scene elements
            HStack(spacing: Theme.Spacing.xl) {
                // Left element
                VStack(spacing: 4) {
                    Circle()
                        .fill(.white.opacity(0.6))
                        .frame(width: 30, height: 30)
                    Capsule()
                        .fill(.white.opacity(0.6))
                        .frame(width: 40, height: 60)
                }

                // Center element
                Circle()
                    .fill(.white.opacity(0.8))
                    .frame(width: 60, height: 60)

                // Right element
                RoundedRectangle(cornerRadius: 4)
                    .fill(.white.opacity(0.6))
                    .frame(width: 50, height: 80)
            }

            // Crop frames overlay
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height

                // Crop frame 1
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.white, lineWidth: 2)
                    .frame(width: width * 0.35, height: height * 0.7)
                    .position(x: width * 0.22, y: height * 0.5)

                // Crop frame 2
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.yellow, lineWidth: 2)
                    .frame(width: width * 0.3, height: height * 0.5)
                    .position(x: width * 0.5, y: height * 0.45)

                // Crop frame 3
                RoundedRectangle(cornerRadius: 4)
                    .stroke(.green, lineWidth: 2)
                    .frame(width: width * 0.25, height: height * 0.6)
                    .position(x: width * 0.8, y: height * 0.5)
            }
        }
        .frame(height: 160)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
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
