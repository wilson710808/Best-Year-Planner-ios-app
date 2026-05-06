import SwiftUI

/// 揪團詳情頁 — 查看社群揪團的成員和動態
struct GroupDetailView: View {
    let group: CommunityGroup
    @ObservedObject var viewModel: CommunityViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newMessage = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 揪團資訊卡片
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundColor(AppColors.primary)
                                Text(group.name)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                if group.isActive {
                                    Text("進行中")
                                        .font(.caption2)
                                        .foregroundColor(AppColors.success)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(AppColors.success.opacity(0.1))
                                        .cornerRadius(4)
                                }
                            }
                            
                            if !group.theme.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "tag.fill")
                                        .font(.caption2)
                                    Text(group.theme)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            
                            if !group.groupDescription.isEmpty {
                                Text(group.groupDescription)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            
                            HStack(spacing: 16) {
                                Label("\(group.memberIds.count) 位成員", systemImage: "person.2.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                                Label("每日 \(group.dailyCheckInGoal) 次打卡", systemImage: "checkmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        
                        // 成員列表
                        let members = viewModel.getMembers(for: group.id)
                        if !members.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("👥 成員")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal)
                                
                                ForEach(members) { member in
                                    MemberRow(member: member)
                                }
                            }
                        }
                        
                        // 最近貼文
                        let posts = viewModel.getPosts(for: group.id)
                        if !posts.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("📝 最近動態")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal)
                                
                                ForEach(posts.prefix(10)) { post in
                                    PostCard(post: post)
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "text.bubble.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("還沒有動態，來發第一條吧！")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.top, 30)
                        }
                    }
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("揪團詳情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct MemberRow: View {
    let member: GroupMember
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(AppColors.primary.opacity(0.15))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(member.nickname.prefix(1)))
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)
                )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(member.nickname)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                HStack(spacing: 8) {
                    Text("打卡 \(member.totalCheckIns) 次")
                    if member.currentStreak > 0 {
                        Text("🔥 \(member.currentStreak) 天")
                    }
                }
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

struct PostCard: View {
    let post: CommunityPost
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(AppColors.accent.opacity(0.15))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Text(String(post.authorNickname.prefix(1)))
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.accent)
                    )
                Text(post.authorNickname)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(post.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(post.content)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            
            if !post.likes.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.caption2)
                        .foregroundColor(.red)
                    Text("\(post.likes.count)")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                    if !post.comments.isEmpty {
                        Text("· \(post.comments.count) 則留言")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(10)
        .padding(.horizontal)
    }
}
