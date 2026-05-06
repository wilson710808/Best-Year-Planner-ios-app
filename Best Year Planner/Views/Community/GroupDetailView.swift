import SwiftUI

/// 揪團詳情頁 — 查看特定揪團的夥伴動態和互動
struct GroupDetailView: View {
    let groupId: String
    @StateObject private var viewModel = GrowthGroupViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var newMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        if let group = viewModel.groups.first(where: { $0.id == groupId }) {
                            // 揪團資訊
                            GroupInfoCard(group: group)
                            
                            // 夥伴列表
                            VStack(alignment: .leading, spacing: 12) {
                                Text("👥 夥伴")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal)
                                
                                ForEach(group.aiPartners) { partner in
                                    BuddyCard(name: partner.name, status: partner.currentStatus, role: partner.role.displayName)
                                }
                            }
                            
                            // 最近動態
                            let activities = viewModel.activities
                            if !activities.isEmpty {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("📝 最近動態")
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)
                                        .padding(.horizontal)
                                    
                                    ForEach(activities.prefix(10)) { activity in
                                        ActivityCard(activity: activity)
                                    }
                                }
                            }
                        } else {
                            // 找不到揪團
                            VStack(spacing: 12) {
                                Image(systemName: "person.3.sequence.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("揪團不存在或已解散")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("揪團詳情")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadGroups()
            }
        }
    }
}

struct GroupInfoCard: View {
    let group: GrowthGroup
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(AppColors.primary)
                Text(group.name)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("第 \(group.dayNumber)/\(group.totalDays) 天")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if let goalId = group.goalId {
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.caption)
                    Text("關聯目標 ID: \(goalId)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            // 進度條
            ProgressView(value: Double(group.dayNumber) / Double(group.totalDays))
                .tint(AppColors.primary)
                .padding(.top, 4)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct BuddyCard: View {
    let name: String
    let status: String
    let role: String
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppColors.primary.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(name.prefix(1)))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                Text("\(role) · \(status)")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct ActivityCard: View {
    let activity: GroupActivity
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: (activity.userId != nil) ? "person.fill" : "bubble.left.fill")
                .foregroundColor((activity.userId != nil) ? AppColors.accent : AppColors.primary)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(activity.content)
                    .font(.caption)
                    .foregroundColor(AppColors.textPrimary)
                Text(activity.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
