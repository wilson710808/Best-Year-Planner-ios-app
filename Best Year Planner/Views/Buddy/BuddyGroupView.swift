import SwiftUI

struct BuddyGroupView: View {
    @StateObject private var viewModel = BuddyViewModel()
    @EnvironmentObject var challengeViewModel: ChallengeViewModel
    @State private var showFeed = false
    @State private var showChatPartner: GrowthBuddy?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 群組概覽
                    groupOverview
                    
                    // 動態消息入口
                    feedEntryCard
                    
                    // 影響力進度（針對待開始夥伴）
                    if viewModel.pendingBuddy != nil {
                        influenceProgress
                    }
                    
                    // 夥伴列表
                    buddySection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("揪團成長")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showFeed = true }) {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .refreshable {
                viewModel.refreshBuddies()
            }
            .onAppear {
                viewModel.loadGroup()
            }
            .sheet(isPresented: $showFeed) {
                BuddyFeedView()
            }
            .sheet(item: $showChatPartner) { buddy in
                AIPartnerView(partnerName: buddy.name, buddyRole: buddy.role)
            }
        }
    }
    
    // MARK: - Group Overview
    
    private var groupOverview: some View {
        VStack(spacing: 16) {
            // 標題
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("揪團成長小隊")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("一起成長，互相激勵")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                // 統計
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .foregroundColor(AppColors.primary)
                    Text("\(viewModel.activeBuddies)/\(viewModel.totalBuddies)")
                        .font(.headline)
                        .foregroundColor(AppColors.primary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AppColors.primary.opacity(0.1))
                .cornerRadius(20)
            }
            
            // 群組狀態卡片
            HStack(spacing: 12) {
                OverviewStatCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(viewModel.startingBuddies.count + viewModel.inProgressBuddies.count)",
                    label: "進行中"
                )
                
                OverviewStatCard(
                    icon: "checkmark.seal.fill",
                    iconColor: .green,
                    value: "\(viewModel.experiencedBuddy != nil ? 1 : 0)",
                    label: "已完成"
                )
                
                OverviewStatCard(
                    icon: "questionmark.circle",
                    iconColor: .gray,
                    value: "\(viewModel.pendingBuddy != nil ? 1 : 0)",
                    label: "待開始"
                )
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Influence Progress
    
    private var influenceProgress: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.badge.clock.fill")
                    .foregroundColor(AppColors.accent)
                Text("影響力進度")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            if let pendingBuddy = viewModel.pendingBuddy {
                HStack(spacing: 12) {
                    // 頭像
                    Image(systemName: pendingBuddy.avatar)
                        .font(.title2)
                        .foregroundColor(.gray)
                        .frame(width: 40, height: 40)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(pendingBuddy.name) 還沒開始")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("堅持 \(challengeViewModel.currentStreak) 天就能影響他！")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                }
                
                // 進度條
                VStack(alignment: .leading, spacing: 4) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.accent)
                                .frame(width: geo.size.width * viewModel.influenceProgress)
                            
                            // 里程碑標記
                            HStack {
                                ForEach([0.3, 0.6, 1.0], id: \.self) { milestone in
                                    Circle()
                                        .fill(viewModel.influenceProgress >= milestone ? AppColors.accent : Color.gray.opacity(0.3))
                                        .frame(width: 8, height: 8)
                                    if milestone < 1.0 {
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .frame(height: 8)
                    
                    HStack {
                        Text("3天")
                            .font(.caption2)
                        Spacer()
                        Text("7天")
                            .font(.caption2)
                        Spacer()
                        Text("10天")
                            .font(.caption2)
                    }
                    .foregroundColor(AppColors.textSecondary)
                }
                
                // 按鈕
                if viewModel.canInfluencePending {
                    Button {
                        viewModel.inspirePendingBuddy()
                    } label: {
                        Label("點擊影響 \(pendingBuddy.name) 開始！", systemImage: "sparkles")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [AppColors.accent, .orange],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    // MARK: - Feed Entry Card
    
    private var feedEntryCard: some View {
        Button(action: { showFeed = true }) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(AppColors.secondary.opacity(0.15))
                        .frame(width: 44, height: 44)
                    Image(systemName: "dot.radiowaves.left.and.right")
                        .font(.title3)
                        .foregroundColor(AppColors.secondary)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("揪團動態")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                    Text("看看夥伴們的最新動態")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.caption)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
    }

    // MARK: - Buddy Section
    
    private var buddySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("夥伴們")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if let group = viewModel.group {
                ForEach(group.buddies) { buddy in
                    BuddyCardView(buddy: buddy)
                        .onTapGesture {
                            showChatPartner = buddy
                        }
                }
            }
        }
    }
}

// MARK: - Overview Stat Card

struct OverviewStatCard: View {
    let icon: String
    let iconColor: Color
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(iconColor)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(iconColor.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    BuddyGroupView()
        .environmentObject(ChallengeViewModel.shared)
}