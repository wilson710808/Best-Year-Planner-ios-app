import SwiftUI

/// 揪團動態消息流 — 夥伴打卡、分享、鼓勵、里程碑、提問、反思
struct BuddyFeedView: View {
    @StateObject private var viewModel = BuddyFeedViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 16) {
                    // 用戶自己的打卡入口
                    myCheckInCard
                    
                    // 夥伴動態
                    ForEach(viewModel.feedPosts) { post in
                        BuddyFeedPostCard(post: post, onLike: {
                            viewModel.toggleLike(postId: post.id)
                        }, onChat: {
                            viewModel.openChat(with: post.buddyId, name: post.buddyName, role: post.buddyRole)
                        })
                    }
                    
                    if viewModel.feedPosts.isEmpty {
                        emptyState
                    }
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("揪團動態")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .refreshable {
                viewModel.refreshFeed()
            }
            .onAppear {
                viewModel.loadFeed()
            }
            .sheet(item: $viewModel.chatTarget) { target in
                AIPartnerView(partnerName: target.name, buddyRole: target.role)
            }
        }
    }
    
    // MARK: - 用戶打卡卡片
    
    private var myCheckInCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary)
                Text("我")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("今天")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            if viewModel.hasCheckedInToday {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text("今日已打卡 ✅")
                        .font(.subheadline)
                        .foregroundColor(AppColors.success)
                }
            } else {
                Button(action: { viewModel.quickCheckIn() }) {
                    HStack {
                        Image(systemName: "checkmark.circle")
                        Text("快速打卡")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 48))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            Text("還沒有夥伴動態")
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)
            Text("開始打卡後，夥伴們也會分享他們的進度！")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
    }
}

// MARK: - 動態貼文卡片

struct BuddyFeedPostCard: View {
    let post: BuddyFeedPost
    let onLike: () -> Void
    let onChat: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 頭部：夥伴資訊
            HStack(spacing: 12) {
                // 角色圖標
                ZStack {
                    Circle()
                        .fill(roleColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                    Image(systemName: post.buddyRole.icon)
                        .font(.body)
                        .foregroundColor(roleColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(post.buddyName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text(post.buddyRole.emoji)
                            .font(.caption)
                        
                        // 貼文類型標籤
                        Text(post.postType.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(typeColor)
                            .cornerRadius(8)
                    }
                    
                    Text(timeAgoString)
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
            }
            
            // 內容
            Text(post.content)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(5)
            
            // 底部互動
            HStack(spacing: 20) {
                // 按讚
                Button(action: onLike) {
                    HStack(spacing: 4) {
                        Image(systemName: post.isLikedByUser ? "heart.fill" : "heart")
                            .font(.caption)
                            .foregroundColor(post.isLikedByUser ? .pink : AppColors.textSecondary)
                        if post.likes > 0 {
                            Text("\(post.likes)")
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                
                // 私聊
                Button(action: onChat) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        Text("私聊")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Helpers
    
    private var roleColor: Color {
        switch post.buddyRole {
        case .companion: return .orange
        case .veteran: return .yellow
        case .beginner: return .green
        case .coach: return .purple
        }
    }
    
    private var typeColor: Color {
        Color(hex: post.postType.color) ?? AppColors.primary
    }
    
    private var timeAgoString: String {
        let interval = Date().timeIntervalSince(post.timestamp)
        if interval < 60 { return "剛剛" }
        if interval < 3600 { return "\(Int(interval / 60))分鐘前" }
        if interval < 86400 { return "\(Int(interval / 3600))小時前" }
        return "\(Int(interval / 86400))天前"
    }
}

// MARK: - Chat Target

struct ChatTarget: Identifiable {
    let id = UUID()
    let buddyId: String
    let name: String
    let role: BuddyRole
}

// MARK: - ViewModel

@MainActor
final class BuddyFeedViewModel: ObservableObject {
    @Published var feedPosts: [BuddyFeedPost] = []
    @Published var hasCheckedInToday: Bool = false
    @Published var chatTarget: ChatTarget?
    
    private let buddyService = BuddyService.shared
    private let checkInService = CheckInService.shared
    
    func loadFeed() {
        checkTodayCheckIn()
        generateFeedPosts()
    }
    
    func refreshFeed() {
        generateFeedPosts()
    }
    
    func quickCheckIn() {
        let tasks = TaskService.shared.getTodaysTasks()
        for task in tasks {
            let _ = checkInService.checkIn(taskId: task.id, status: .completed)
        }
        hasCheckedInToday = true
        // 打卡後夥伴也會有新動態
        generateFeedPosts()
    }
    
    func toggleLike(postId: String) {
        if let index = feedPosts.firstIndex(where: { $0.id == postId }) {
            feedPosts[index].isLikedByUser.toggle()
            if feedPosts[index].isLikedByUser {
                feedPosts[index].likes += 1
            } else {
                feedPosts[index].likes = max(0, feedPosts[index].likes - 1)
            }
        }
    }
    
    func openChat(with buddyId: String, name: String, role: BuddyRole) {
        chatTarget = ChatTarget(buddyId: buddyId, name: name, role: role)
    }
    
    // MARK: - Private
    
    private func checkTodayCheckIn() {
        let todayCheckIns = checkInService.getTodayCheckIns()
        hasCheckedInToday = !todayCheckIns.isEmpty
    }
    
    private func generateFeedPosts() {
        var posts: [BuddyFeedPost] = []
        
        guard let group = buddyService.currentGroup ?? buddyService.getOrCreateGroup() as BuddyGroup? else { return }
        let userDay = group.buddies.first?.challengeDay ?? 1
        
        for buddy in group.buddies {
            // 每個夥伴生成 1-2 條動態
            let postCount = buddy.role == .coach ? 1 : Int.random(in: 1...2)
            for _ in 0..<postCount {
                let post = BuddyFeedPost.generatePost(
                    buddyRole: buddy.role,
                    buddyName: buddy.name,
                    buddyId: buddy.id,
                    buddyAvatar: buddy.avatar,
                    day: userDay
                )
                posts.append(post)
            }
        }
        
        // 按時間排序（最新的在前）
        posts.sort { $0.timestamp > $1.timestamp }
        feedPosts = posts
    }
}

#Preview {
    BuddyFeedView()
}
