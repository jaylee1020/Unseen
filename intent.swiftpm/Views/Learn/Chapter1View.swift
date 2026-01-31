import SwiftUI

// MARK: - Chapter 1: See First
/// Teaches the difference between a snapshot and a photograph
struct Chapter1View: View {
    @State private var selectedOption: Int? = nil
    @State private var showFeedback = false
    
    // The "better" composition is option 1 (right side)
    private let correctAnswer = 1
    
    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
            // Introduction
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Snapshot vs. Photograph")
                
                Text("Every day, billions of photos are taken. But what separates a snapshot from a photograph?")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                Text("The answer is simple: **intention**.")
                    .font(Theme.Typography.body)
                
                Text("A snapshot captures what's in front of you. A photograph communicates what you saw — the feeling, the moment, the meaning you found.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
            }
            
            Divider()
                .padding(.vertical, Theme.Spacing.sm)
            
            // Illustration placeholder
            IllustrationPlaceholder(
                height: 180,
                iconName: "eye.fill",
                label: "Seeing vs. Looking",
                expandWidth: true
            )
            
            Divider()
                .padding(.vertical, Theme.Spacing.sm)
            
            // Interactive Exercise
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Exercise: Which Communicates More?")
                
                Text("Look at these two different crops of the same image. Tap the one that feels more intentional.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                // Two crop options
                HStack(spacing: Theme.Spacing.md) {
                    CropOptionCard(
                        optionNumber: 0,
                        isSelected: selectedOption == 0,
                        isCorrect: showFeedback ? (0 == correctAnswer) : nil
                    ) {
                        selectOption(0)
                    }
                    
                    CropOptionCard(
                        optionNumber: 1,
                        isSelected: selectedOption == 1,
                        isCorrect: showFeedback ? (1 == correctAnswer) : nil
                    ) {
                        selectOption(1)
                    }
                }
                
                // Feedback
                if showFeedback {
                    FeedbackCard(isCorrect: selectedOption == correctAnswer)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            
            Divider()
                .padding(.vertical, Theme.Spacing.sm)
            
            // Core message
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                SectionHeader(title: "Photography is a Language")
                
                Text("Just like writing, photography has grammar and vocabulary. Composition is your sentence structure. Light is your tone. Subject is your subject.")
                    .font(Theme.Typography.body)
                    .foregroundStyle(.secondary)
                
                Text("In the coming chapters, you'll learn this language — so every photo you take **says what you mean**.")
                    .font(Theme.Typography.body)
                
                // Illustration placeholder
                IllustrationPlaceholder(
                    height: 160,
                    iconName: "text.quote",
                    label: "Photography as Language",
                    expandWidth: true
                )
            }
            
            Spacer()
                .frame(height: Theme.Spacing.xl)
        }
        .padding(Theme.Spacing.md)
        .animation(Theme.Animation.standard, value: showFeedback)
    }
    
    private func selectOption(_ option: Int) {
        if selectedOption == nil {
            selectedOption = option

            // Haptic feedback based on correctness
            if option == correctAnswer {
                HapticManager.success()
            } else {
                HapticManager.error()
            }

            withAnimation(Theme.Animation.standard.delay(0.3)) {
                showFeedback = true
            }
        }
    }
}

// MARK: - Supporting Components

struct SectionHeader: View {
    let title: String
    
    var body: some View {
        Text(title)
            .font(Theme.Typography.title2)
    }
}

struct CropOptionCard: View {
    let optionNumber: Int
    let isSelected: Bool
    var isCorrect: Bool? = nil
    let action: () -> Void
    
    var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .accentColor : .clear
    }
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Placeholder for crop preview
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .fill(Theme.Colors.tertiaryBackground)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                            
                            Text("Crop \(optionNumber + 1)")
                                .font(Theme.Typography.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                
                // Selection/feedback border
                RoundedRectangle(cornerRadius: Theme.CornerRadius.medium)
                    .stroke(borderColor, lineWidth: 3)
                
                // Feedback icon
                if let isCorrect = isCorrect {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(isCorrect ? .green : .red)
                                .background(Circle().fill(.white))
                                .padding(Theme.Spacing.xs)
                        }
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(isCorrect != nil)
    }
}

struct FeedbackCard: View {
    let isCorrect: Bool
    
    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "lightbulb.fill")
                .font(.system(size: 24))
                .foregroundStyle(isCorrect ? .green : .orange)
            
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(isCorrect ? "Great eye!" : "Good observation!")
                    .font(Theme.Typography.headline)
                
                Text(isCorrect 
                     ? "You noticed how the tighter crop focuses attention and creates a stronger emotional connection."
                     : "Both crops have merit, but the other option draws the eye more directly to the subject, creating a stronger sense of intention.")
                    .font(Theme.Typography.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(isCorrect ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: Theme.CornerRadius.medium))
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        ScrollView {
            Chapter1View()
        }
        .navigationTitle("See First")
    }
}
