import SwiftUI

// MARK: - Learn Tab View
/// The main Learn tab displaying all chapters
struct LearnTabView: View {
    @State private var selectedChapter: Chapter?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    // Header
                    VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                        Text("Learn the Fundamentals")
                            .font(Theme.Typography.title)

                        Text("Master the art of intentional photography")
                            .font(Theme.Typography.body)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, Theme.Spacing.md)

                    // Chapter list
                    LazyVStack(spacing: Theme.Spacing.sm) {
                        ForEach(Chapter.chapters) { chapter in
                            NavigationLink(value: chapter) {
                                ChapterCardContent(chapter: chapter)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.xl)
                }
            }
            .background(Theme.Colors.background)
            .navigationTitle("Learn")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Chapter.self) { chapter in
                ChapterDetailView(chapter: chapter)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToChapter)) { notification in
            if let chapterId = notification.userInfo?["chapterId"] as? Int,
               let chapter = Chapter.chapters.first(where: { $0.id == chapterId }) {
                // Clear current path and navigate to the chapter
                navigationPath = NavigationPath()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    navigationPath.append(chapter)
                }
            }
        }
    }
}

// MARK: - Chapter Detail View
/// Container view that routes to specific chapter content
struct ChapterDetailView: View {
    let chapter: Chapter
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            switch chapter.id {
            case 1:
                Chapter1View()
            case 2:
                Chapter2View()
            case 3:
                Chapter3View()
            case 4:
                Chapter4View()
            case 5:
                Chapter5View()
            default:
                Text("Chapter not found")
            }
        }
        .background(Theme.Colors.background)
        .navigationTitle(chapter.title)
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Preview
#Preview {
    LearnTabView()
}
