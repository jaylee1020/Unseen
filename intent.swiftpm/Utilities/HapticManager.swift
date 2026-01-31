import SwiftUI
import UIKit

// MARK: - Haptic Manager
/// Centralized haptic feedback manager for consistent tactile responses
struct HapticManager {

    // MARK: - Impact Feedback
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.prepare()
        generator.impactOccurred()
    }

    /// Light impact - for subtle interactions (button taps, toggles)
    static func lightImpact() {
        impact(.light)
    }

    /// Medium impact - for standard interactions (selections, card taps)
    static func mediumImpact() {
        impact(.medium)
    }

    /// Heavy impact - for significant actions (delete, save)
    static func heavyImpact() {
        impact(.heavy)
    }

    // MARK: - Notification Feedback
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }

    /// Success notification - for completed actions (save success, correct answer)
    static func success() {
        notification(.success)
    }

    /// Warning notification - for attention-needed states
    static func warning() {
        notification(.warning)
    }

    /// Error notification - for failed actions or wrong answers
    static func error() {
        notification(.error)
    }

    // MARK: - Selection Feedback
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }

    // MARK: - Custom Patterns

    /// Snap feedback - for snapping to positions (horizon level, grid alignment)
    static func snap() {
        impact(.rigid)
    }

    /// Soft tap - for non-destructive button taps
    static func softTap() {
        impact(.soft)
    }
}
