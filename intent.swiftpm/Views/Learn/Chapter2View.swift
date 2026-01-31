import SwiftUI

// MARK: - Chapter 2: Your Lens
/// Teaches about focal length and perspective
struct Chapter2View: View {
    @State private var selectedFocalLength: FocalLength = .wide35
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Introduction
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Understanding Focal Length")
                
                Text("When photographers talk about \"millimeters\" — 24mm, 35mm, 50mm, 77mm — they're describing the **focal length** of a lens.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                Text("Focal length changes two things: how much of the scene you capture (**field of view**) and how the scene **feels**.")
                    .font(Theme.Typography.body)
            }
            
            Divider()
                .padding(.vertical, Theme.Spacing.sm)
            
            // Interactive focal length slider
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "See the Difference")
                
                Text("Drag the slider to see how the same scene looks at different focal lengths.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                // Focal length preview
                FocalLengthPreview(focalLength: selectedFocalLength)
                
                // Focal length selector
                FocalLengthSlider(selected: $selectedFocalLength)
                
                // Description
                FocalLengthDescription(focalLength: selectedFocalLength)
            }
            
            Divider()
                .padding(.vertical, Theme.Spacing.sm)
            
            // The 1x Trap
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "The 1x Trap")
                
                IllustrationPlaceholder(
                    height: 140,
                    iconName: "1.circle.fill",
                    label: "1x Trap Illustration",
                    expandWidth: true
                )
                
                Text("Most people never leave 1x. They point, tap, done.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                Text("But your iPhone has **multiple lenses** with different perspectives. Each one tells a different story.")
                    .font(Theme.Typography.body)
                
                Text("The ultra-wide (0.5x) makes spaces feel vast and dramatic. The telephoto (2x, 3x, 5x) isolates subjects and compresses distance. **The best photographers choose their lens before they shoot.**")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.vertical, Theme.Spacing.sm)
            
            // iPhone Camera Guide
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Your iPhone's Lenses")
                
                Text("Here's where to find your lens options:")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                // Camera app guide
                CameraGuideCard(
                    title: "In the Camera App",
                    steps: [
                        "Open the Camera app",
                        "Look for the lens buttons above the shutter: 0.5x, 1x, 2x, 3x, or 5x",
                        "Tap to switch, or tap and hold for fine adjustments"
                    ]
                )
                
                CameraGuideCard(
                    title: "Pro Tip: Settings",
                    steps: [
                        "Go to Settings → Camera",
                        "Turn on \"Lens Correction\" for ultra-wide",
                        "Explore \"Preserve Settings\" to keep your preferences"
                    ]
                )
                
                // Illustration placeholder
                IllustrationPlaceholder(
                    height: 160,
                    iconName: "iphone.rear.camera",
                    label: "iPhone Camera Interface",
                    expandWidth: true
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
    
    var description: String {
        switch self {
        case .ultraWide24:
            return "Ultra-wide: Everything feels expansive and dramatic. Great for architecture, landscapes, and creating a sense of space."
        case .wide35:
            return "Wide: Natural perspective, similar to human vision. Versatile for everyday photography and street scenes."
        case .standard48:
            return "Standard: Slight compression begins to isolate subjects. Perfect for portraits and food photography."
        case .telephoto77:
            return "Telephoto: Strong compression, intimate feeling. Ideal for portraits, details, and creating depth."
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
}

// MARK: - Focal Length Preview
struct FocalLengthPreview: View {
    let focalLength: FocalLength
    
    // Simulate field of view change with scale
    private var scale: CGFloat {
        switch focalLength {
        case .ultraWide24: return 0.6
        case .wide35: return 0.8
        case .standard48: return 1.0
        case .telephoto77: return 1.3
        }
    }
    
    var body: some View {
        ZStack {
            // Placeholder background - represents the scene
            RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    // Scene elements that scale
                    VStack(spacing: Theme.Spacing.md) {
                        // "Mountain" shapes
                        HStack(spacing: Theme.Spacing.lg) {
                            Triangle()
                                .fill(.gray.opacity(0.5))
                                .frame(width: 60, height: 50)
                            
                            Triangle()
                                .fill(.gray.opacity(0.7))
                                .frame(width: 80, height: 70)
                            
                            Triangle()
                                .fill(.gray.opacity(0.5))
                                .frame(width: 50, height: 40)
                        }
                        .scaleEffect(scale)
                        
                        // "Person" silhouette
                        VStack(spacing: 4) {
                            Circle()
                                .fill(.primary.opacity(0.7))
                                .frame(width: 24, height: 24)
                            
                            Capsule()
                                .fill(.primary.opacity(0.7))
                                .frame(width: 36, height: 48)
                        }
                        .scaleEffect(scale)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
            
            // Focal length label
            VStack {
                HStack {
                    Text(focalLength.displayName)
                        .font(Theme.Typography.headline)
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
        .animation(Theme.Animation.spring, value: focalLength)
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

// MARK: - Focal Length Slider
struct FocalLengthSlider: View {
    @Binding var selected: FocalLength
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(FocalLength.allCases) { focal in
                Button {
                    withAnimation(Theme.Animation.spring) {
                        selected = focal
                    }
                } label: {
                    VStack(spacing: Theme.Spacing.xxs) {
                        Text(focal.shortName)
                            .font(Theme.Typography.headline)
                        
                        Text(focal.displayName)
                            .font(Theme.Typography.caption)
                    }
                    .foregroundStyle(selected == focal ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.small)
                            .fill(selected == focal ? Color.accentColor : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Theme.Spacing.xxs)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }
}

// MARK: - Focal Length Description
struct FocalLengthDescription: View {
    let focalLength: FocalLength
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(focalLength.feeling)
                .font(Theme.Typography.subheadline)
                .foregroundStyle(Color.accentColor)
            
            Text(focalLength.description)
                .font(Theme.Typography.body)
                .foregroundStyle(.secondary)
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
        .animation(Theme.Animation.quick, value: focalLength)
    }
}

// MARK: - Camera Guide Card
struct CameraGuideCard: View {
    let title: String
    let steps: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            Text(title)
                .font(Theme.Typography.headline)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: Theme.Spacing.sm) {
                        Text("\(index + 1).")
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(Color.accentColor)
                            .frame(width: 20)
                        
                        Text(step)
                            .font(Theme.Typography.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.Colors.secondaryBackground)
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
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
