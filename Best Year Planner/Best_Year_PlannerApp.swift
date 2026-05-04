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
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }
}

struct RootView: View {
    @EnvironmentObject private var appState: AppState

    private var preferredColorScheme: ColorScheme? {
        switch appState.themeMode {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    /// UI Testing 支援：處理啟動參數
    private func processLaunchArguments() {
        // --onboarding-completed: 跳過引導流程
        if ProcessInfo.processInfo.arguments.contains("--onboarding-completed") {
            appState.isOnboardingCompleted = true
            appState.isLoggedIn = true
        }

        // --has-challenge: 模擬已有進行中的挑戰
        if ProcessInfo.processInfo.arguments.contains("--has-challenge") {
            // ChallengeViewModel 會處理
        }

        // --seven-day-completed: 模擬已完成 7 天
        if ProcessInfo.processInfo.arguments.contains("--seven-day-completed") {
            // 解鎖 21 天挑戰
        }

        // --free-tier-full: 模擬免費用戶已達挑戰上限
        if ProcessInfo.processInfo.arguments.contains("--free-tier-full") {
            // Subscription 限制檢查
        }
    }

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
        .preferredColorScheme(preferredColorScheme)
        .animation(.easeInOut, value: appState.isLoggedIn)
        .animation(.easeInOut, value: appState.isOnboardingCompleted)
        .onAppear {
            processLaunchArguments()
        }
    }
}

