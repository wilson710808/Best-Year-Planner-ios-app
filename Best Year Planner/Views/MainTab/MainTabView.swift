import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var appState: AppState
    @State private var showNewlyUnlocked = false
    @State private var newlyUnlockedFeatures: [Feature] = []
    
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
            
            // Tab 3: AI教練 (Day 3 解鎖)
            if FeatureUnlockManager.shared.isUnlocked(.aiCoach) {
                NavigationStack {
                    AICoachView()
                }
                .tabItem {
                    Label("AI教練", systemImage: "bubble.left.and.bubble.right.fill")
                }
                .tag(2)
            }
            
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
            FeatureUnlockManager.shared.ensureFirstUseDate()
            checkNewlyUnlocked()
            configureTabBarAppearance()
        }
        .sheet(isPresented: $showNewlyUnlocked) {
            FeatureUnlockCelebrationView(features: newlyUnlockedFeatures)
        }
    }
    
    private func checkNewlyUnlocked() {
        let newFeatures = FeatureUnlockManager.shared.newlyUnlocked()
        if !newFeatures.isEmpty {
            newlyUnlockedFeatures = newFeatures
            showNewlyUnlocked = true
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

// MARK: - 功能解鎖慶祝視圖
struct FeatureUnlockCelebrationView: View {
    let features: [Feature]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // 慶祝標題
                        VStack(spacing: 8) {
                            Text("🎉")
                                .font(.system(size: 60))
                            Text("新功能解鎖！")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            Text("你已經使用 Best Year Planner \(FeatureUnlockManager.shared.daysSinceFirstUse) 天了，這是你的獎勵！")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)
                        
                        // 解鎖的功能列表
                        ForEach(features) { feature in
                            HStack(spacing: 16) {
                                Image(systemName: feature.icon)
                                    .font(.title2)
                                    .foregroundColor(AppColors.primary)
                                    .frame(width: 44, height: 44)
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(12)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(feature.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text(feature.description)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "lock.open.fill")
                                    .foregroundColor(AppColors.success)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        // 即將解鎖
                        let upcoming = FeatureUnlockManager.shared.upcomingUnlocks()
                        if !upcoming.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("🔜 即將解鎖")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                
                                ForEach(upcoming) { feature in
                                    HStack(spacing: 12) {
                                        Image(systemName: feature.icon)
                                            .foregroundColor(AppColors.textSecondary)
                                            .frame(width: 24)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(feature.displayName)
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.textSecondary)
                                            Text("還需 \(FeatureUnlockManager.shared.daysUntilUnlock(feature)) 天")
                                                .font(.caption2)
                                                .foregroundColor(AppColors.textSecondary)
                                        }
                                        Spacer()
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(AppColors.divider)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                        }
                        
                        Button(action: { dismiss() }) {
                            Text("太棒了！")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(AppColors.primary)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
