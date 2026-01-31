import SwiftUI

// MARK: - Chapter Model
/// Represents a learning chapter in the app
struct Chapter: Identifiable, Hashable {
    let id: Int
    let title: String
    let subtitle: String
    let iconName: String
    let accentColor: Color
    
    // Hashable conformance (Color is not Hashable, so we implement manually)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Chapter, rhs: Chapter) -> Bool {
        lhs.id == rhs.id
    }
    
    static let chapters: [Chapter] = [
        Chapter(
            id: 1,
            title: "See First",
            subtitle: "The difference between a snapshot and a photograph",
            iconName: "eye.fill",
            accentColor: .blue
        ),
        Chapter(
            id: 2,
            title: "Your Lens",
            subtitle: "Understanding focal length and perspective",
            iconName: "camera.aperture",
            accentColor: .purple
        ),
        Chapter(
            id: 3,
            title: "Compose",
            subtitle: "Framing, balance, and visual harmony",
            iconName: "square.on.square",
            accentColor: .orange
        ),
        Chapter(
            id: 4,
            title: "Express",
            subtitle: "Aspect ratios and creative choices",
            iconName: "rectangle.3.group",
            accentColor: .pink
        ),
        Chapter(
            id: 5,
            title: "Go Shoot",
            subtitle: "Put your knowledge into practice",
            iconName: "camera.fill",
            accentColor: .green
        )
    ]
}
