import SwiftUI

// MARK: - Celebration Particle Effect
/// A reusable particle burst animation for success moments

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var scale: CGFloat
    var opacity: Double
    var color: Color
    var rotation: Double
}

struct CelebrationEffect: View {
    @Binding var trigger: Bool
    var particleCount: Int = 30
    var colors: [Color] = [.yellow, .orange, .pink, .purple, .blue, .green, .mint]

    @State private var particles: [Particle] = []
    @State private var elapsed: Double = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let rect = CGRect(
                        x: particle.x - particle.scale * 4,
                        y: particle.y - particle.scale * 4,
                        width: particle.scale * 8,
                        height: particle.scale * 8
                    )

                    context.opacity = particle.opacity

                    // Draw star-like shape
                    let path = starPath(in: rect, rotation: particle.rotation)
                    context.fill(path, with: .color(particle.color))
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
        }
        .allowsHitTesting(false)
        .onChange(of: trigger) { _, newValue in
            if newValue {
                spawnParticles()
                // Auto-reset trigger after animation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    trigger = false
                    particles = []
                }
            }
        }
    }

    private func starPath(in rect: CGRect, rotation: Double) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        var path = Path()

        for i in 0..<5 {
            let angle = (Double(i) * 72 - 90 + rotation) * .pi / 180
            let innerAngle = (Double(i) * 72 - 90 + 36 + rotation) * .pi / 180
            let outerPoint = CGPoint(
                x: center.x + radius * cos(angle),
                y: center.y + radius * sin(angle)
            )
            let innerPoint = CGPoint(
                x: center.x + radius * 0.4 * cos(innerAngle),
                y: center.y + radius * 0.4 * sin(innerAngle)
            )
            if i == 0 {
                path.move(to: outerPoint)
            } else {
                path.addLine(to: outerPoint)
            }
            path.addLine(to: innerPoint)
        }
        path.closeSubpath()
        return path
    }

    private func spawnParticles() {
        particles = (0..<particleCount).map { _ in
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 2...8)
            return Particle(
                x: 0, y: 0, // Will be centered via overlay
                vx: cos(angle) * speed,
                vy: sin(angle) * speed - 3, // Upward bias
                scale: CGFloat.random(in: 0.5...1.5),
                opacity: 1.0,
                color: colors.randomElement() ?? .yellow,
                rotation: Double.random(in: 0...360)
            )
        }
        elapsed = 0
    }

    private func updateParticles() {
        guard !particles.isEmpty else { return }
        elapsed += 1.0 / 60.0

        for i in particles.indices {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            particles[i].vy += 0.15 // Gravity
            particles[i].opacity = max(0, 1.0 - elapsed / 1.2)
            particles[i].scale *= 0.995
            particles[i].rotation += Double(particles[i].vx) * 2
        }
    }
}

// MARK: - View Modifier for Celebration
struct CelebrationModifier: ViewModifier {
    @Binding var trigger: Bool
    var colors: [Color]

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { geometry in
                CelebrationEffect(trigger: $trigger, colors: colors)
                    .offset(x: geometry.size.width / 2, y: geometry.size.height / 2)
            }
        }
    }
}

extension View {
    /// Adds a celebration particle burst effect triggered by a boolean
    func celebrationEffect(trigger: Binding<Bool>, colors: [Color] = [.yellow, .orange, .pink, .purple, .blue, .green]) -> some View {
        modifier(CelebrationModifier(trigger: trigger, colors: colors))
    }
}

// MARK: - Preview
#Preview {
    struct PreviewWrapper: View {
        @State private var celebrate = false

        var body: some View {
            VStack {
                Button("Celebrate!") {
                    celebrate = true
                }
                .font(.title)
                .padding()
                .celebrationEffect(trigger: $celebrate)
            }
        }
    }

    return PreviewWrapper()
}
