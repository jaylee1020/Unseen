import SwiftUI

// MARK: - App Theme
/// Central theme configuration for consistent styling
struct Theme {
    // MARK: - Colors
    struct Colors {
        static let primary = Color.primary
        static let secondary = Color.secondary
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        static let accent = Color.accentColor
        
        // Chapter colors
        static let chapter1 = Color.blue
        static let chapter2 = Color.purple
        static let chapter3 = Color.orange
        static let chapter4 = Color.pink
        static let chapter5 = Color.green
        
        // Overlay colors
        static let darkOverlay = Color.black.opacity(0.5)
        static let cropFrame = Color.white
    }
    
    // MARK: - Typography
    struct Typography {
        static let largeTitle = Font.largeTitle.weight(.bold)
        static let title = Font.title.weight(.semibold)
        static let title2 = Font.title2.weight(.semibold)
        static let title3 = Font.title3.weight(.medium)
        static let headline = Font.headline
        static let body = Font.body
        static let callout = Font.callout
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption = Font.caption
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 24
    }
    
    // MARK: - Animation
    struct Animation {
        static let quick = SwiftUI.Animation.easeInOut(duration: 0.2)
        static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        static let slow = SwiftUI.Animation.easeInOut(duration: 0.5)
        static let spring = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.8)

        // Additional animations for enhanced UX
        static let bouncy = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.6)
        static let smooth = SwiftUI.Animation.easeOut(duration: 0.35)
        static let snappy = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let pageTransition = SwiftUI.Animation.easeInOut(duration: 0.4)
    }
}

// MARK: - View Extensions for Theme
extension View {
    /// Applies card styling with rounded corners and shadow
    func cardStyle(padding: CGFloat = Theme.Spacing.md) -> some View {
        self
            .padding(padding)
            .background(Theme.Colors.secondaryBackground)
            .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }
    
    /// Adds subtle shadow
    func subtleShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
