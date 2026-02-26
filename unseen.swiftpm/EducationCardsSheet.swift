import SwiftUI

struct EducationCardsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Accessibility Cards for Designers")
                        .font(.system(.title2, design: .serif, weight: .regular))
                        .foregroundStyle(UnseenTheme.text)

                    EducationCard(title: "Rule 1", content: "Don't rely on color alone — always pair with icons or text.")
                    EducationCard(title: "Rule 2", content: "Check contrast: 4.5:1 minimum for normal text, 3:1 for large text.")
                    EducationCard(title: "Rule 3", content: "Avoid green/red pairs — prefer orange/blue alternatives.")
                    EducationCard(title: "Rule 4", content: "Always do a final review on real devices under various lighting.")
                    EducationCard(title: "Rule 5", content: "Document your accessibility review process in deliverables.")
                }
                .padding(20)
            }
            .background(UnseenTheme.bg.ignoresSafeArea())
            .navigationTitle("Education Cards")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                        .accessibilityLabel("Close education cards")
                }
            }
        }
    }
}
