import SwiftUI

// MARK: - Illustration Placeholder
/// A placeholder view for custom illustrations to be added later
struct IllustrationPlaceholder: View {
    var width: CGFloat? = 280
    var height: CGFloat = 200
    var iconName: String = "photo.artframe"
    var label: String = "Illustration"
    var expandWidth: Bool = false
    
    var body: some View {
        ZStack {
            // Background gradient
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentColor.opacity(0.1),
                            Color.accentColor.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            
            // Dashed border
            RoundedRectangle(cornerRadius: Theme.CornerRadius.large)
                .strokeBorder(
                    Color.accentColor.opacity(0.3),
                    style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                )
            
            // Content
            VStack(spacing: Theme.Spacing.sm) {
                Image(systemName: iconName)
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentColor.opacity(0.5))
                
                Text(label)
                    .font(Theme.Typography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: expandWidth ? .infinity : nil)
        .frame(width: expandWidth ? nil : width, height: height)
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        IllustrationPlaceholder()
        
        IllustrationPlaceholder(
            width: 200,
            height: 150,
            iconName: "camera.fill",
            label: "Camera Illustration"
        )
    }
    .padding()
}
