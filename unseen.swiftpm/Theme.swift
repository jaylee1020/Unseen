import SwiftUI

struct UnseenCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .glassEffect(.regular, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

extension View {
    func unseenCard() -> some View {
        modifier(UnseenCardStyle())
    }
}

enum UnseenTheme {
    static let bg = Color(red: 250.0 / 255.0, green: 250.0 / 255.0, blue: 248.0 / 255.0)
    static let surface = Color.white
    static let surface2 = Color(red: 244.0 / 255.0, green: 244.0 / 255.0, blue: 240.0 / 255.0)
    static let border = Color(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 220.0 / 255.0)
    static let text = Color(red: 24.0 / 255.0, green: 24.0 / 255.0, blue: 15.0 / 255.0)
    static let dim = Color(red: 113.0 / 255.0, green: 113.0 / 255.0, blue: 106.0 / 255.0)
    static let accent = Color(red: 196.0 / 255.0, green: 65.0 / 255.0, blue: 0.0 / 255.0)
    static let accentBackground = Color(red: 1.0, green: 244.0 / 255.0, blue: 237.0 / 255.0)
    static let green = Color(red: 26.0 / 255.0, green: 122.0 / 255.0, blue: 76.0 / 255.0)
    static let greenBackground = Color(red: 238.0 / 255.0, green: 248.0 / 255.0, blue: 241.0 / 255.0)
    static let red = Color(red: 196.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0)
    static let redBackground = Color(red: 253.0 / 255.0, green: 240.0 / 255.0, blue: 240.0 / 255.0)
    static let blue = Color(red: 29.0 / 255.0, green: 95.0 / 255.0, blue: 160.0 / 255.0)
    static let blueBackground = Color(red: 238.0 / 255.0, green: 244.0 / 255.0, blue: 251.0 / 255.0)

    static var meshBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0.0, 0.0], [0.5, 0.0], [1.0, 0.0],
                [0.0, 0.5], [0.5, 0.5], [1.0, 0.5],
                [0.0, 1.0], [0.5, 1.0], [1.0, 1.0]
            ],
            colors: [
                accentBackground, Color(white: 0.97), blueBackground,
                Color(white: 0.98), bg, Color(white: 0.97),
                greenBackground, Color(white: 0.96), accentBackground
            ]
        )
        .ignoresSafeArea()
    }
}
