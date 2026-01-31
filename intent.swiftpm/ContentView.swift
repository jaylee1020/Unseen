import SwiftUI

// MARK: - Main Content View
/// The root view that handles onboarding and main app navigation
struct ContentView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var projectStorage = ProjectStorage()
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView(selectedTab: $selectedTab)
                    .environmentObject(projectStorage)
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .animation(Theme.Animation.standard, value: hasCompletedOnboarding)
        .onReceive(NotificationCenter.default.publisher(for: .switchToTryOutTab)) { _ in
            selectedTab = 1
        }
    }
}

// MARK: - Main Tab View
/// The main app interface with Learn and Try Out tabs
struct MainTabView: View {
    @Binding var selectedTab: Int
    @EnvironmentObject var projectStorage: ProjectStorage
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LearnTabView()
                .tabItem {
                    Label("Learn", systemImage: "book.fill")
                }
                .tag(0)
            
            TryOutTabView()
                .environmentObject(projectStorage)
                .tabItem {
                    Label("Try Out", systemImage: "camera.viewfinder")
                }
                .tag(1)
        }
        .tint(Color.accentColor)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}
