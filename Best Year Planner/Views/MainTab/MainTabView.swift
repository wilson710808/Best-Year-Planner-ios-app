import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var appState: AppState
    @StateObject private var moduleManager = ModuleManager.shared

    private var enabledModules: [any AppModule] {
        moduleManager.getEnabledModules()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(Array(enabledModules.enumerated()), id: \.element.id) { index, module in
                tabContent(for: module)
                    .tabItem {
                        Label(module.name, systemImage: module.icon)
                    }
                    .tag(index)
            }
        }
        .tint(AppColors.primary)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    @ViewBuilder
    private func tabContent(for module: any AppModule) -> some View {
        switch module.id {
        case "dashboard":
            DashboardView()
        case "goals":
            GoalsListView()
        case "checkin":
            CheckInView()
        case "aicoach":
            AICoachView()
        case "community":
            CommunityView()
        default:
            EmptyView()
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

