import SwiftUI

@main
struct Best_Year_PlannerApp: App {
    @StateObject private var appState = AppState.shared

    init() {
        configureAppearance()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appState)
        }
    }

    private func configureAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color(hex: "2C3E50"))]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color(hex: "2C3E50"))]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.isLoggedIn {
                if appState.isOnboardingCompleted {
                    MainTabView()
                } else {
                    OnboardingContainerView()
                }
            } else {
                WelcomeView()
            }
        }
        .animation(.easeInOut, value: appState.isLoggedIn)
        .animation(.easeInOut, value: appState.isOnboardingCompleted)
    }
}

