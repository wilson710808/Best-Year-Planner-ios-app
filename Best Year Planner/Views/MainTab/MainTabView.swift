import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var appState: AppState

    var body: some View {
        TabView(selection: $selectedTab) {
            // Tab 1: 首頁 (挑戰)
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("首頁", systemImage: "house.fill")
            }
            .tag(0)

            // Tab 2: 打卡
            NavigationStack {
                CheckInView()
            }
            .tabItem {
                Label("打卡", systemImage: "checkmark.circle.fill")
            }
            .tag(1)

            // Tab 3: AI教練
            NavigationStack {
                AICoachView()
            }
            .tabItem {
                Label("AI教練", systemImage: "bubble.left.and.bubble.right.fill")
            }
            .tag(2)

            // Tab 4: 我的
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("我的", systemImage: "person.fill")
            }
            .tag(3)
        }
        .tint(AppColors.primary)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBackground

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
