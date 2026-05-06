import Foundation
import Combine

@MainActor
final class CommunityViewModel: ObservableObject {
    @Published var groups: [CommunityGroup] = []
    @Published var posts: [CommunityPost] = []
    @Published var selectedGroup: CommunityGroup?
    @Published var leaderboard: [GroupMember] = []
    @Published var isLoading: Bool = false
    @Published var newPostContent: String = ""
    @Published var errorMessage: String?

    private let communityService = CommunityService.shared
    private let database = DatabaseManager.shared

    // MARK: - Groups

    func loadGroups() {
        isLoading = true
        groups = communityService.getAllGroups()
        isLoading = false
    }

    func createGroup(name: String, theme: String, description: String) {
        let group = communityService.createGroup(name: name, theme: theme, description: description)
        groups.append(group)
    }

    func joinGroup(_ group: CommunityGroup) {
        if communityService.joinGroup(group.id) {
            loadGroups() // 重新載入以反映成員變化
        } else {
            errorMessage = "加入群組失敗"
        }
    }

    func leaveGroup(_ group: CommunityGroup) {
        if communityService.leaveGroup(group.id) {
            groups.removeAll { $0.id == group.id }
            if selectedGroup?.id == group.id {
                clearSelection()
            }
        }
    }

    func selectGroup(_ group: CommunityGroup) {
        selectedGroup = group
        loadPosts(forGroupId: group.id)
        loadLeaderboard(forGroupId: group.id)
    }

    // MARK: - Posts

    func loadPosts(forGroupId groupId: String) {
        posts = communityService.getPosts(forGroupId: groupId)
    }

    func createPost(groupId: String, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let post = communityService.createPost(groupId: groupId, content: content)
        posts.insert(post, at: 0)
        newPostContent = ""
    }

    func deletePost(_ post: CommunityPost) {
        if communityService.deletePost(post.id) {
            posts.removeAll { $0.id == post.id }
        }
    }

    func likePost(_ post: CommunityPost) {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        guard !post.likes.contains(userId) else { return }
        var updatedPost = post
        updatedPost.likes.append(userId)
        _ = database.saveCommunityPost(updatedPost)
        // 更新本地列表
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = updatedPost
        }
    }

    func unlikePost(_ post: CommunityPost) {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        var updatedPost = post
        updatedPost.likes.removeAll { $0 == userId }
        _ = database.saveCommunityPost(updatedPost)
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = updatedPost
        }
    }

    func addComment(toPost post: CommunityPost, content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let comment = communityService.addComment(toPostId: post.id, content: content)
        var updatedPost = post
        updatedPost.comments.append(comment)
        _ = database.saveCommunityPost(updatedPost)
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index] = updatedPost
        }
    }

    // MARK: - Leaderboard

    func loadLeaderboard(forGroupId groupId: String) {
        leaderboard = communityService.getGroupLeaderboard(groupId)
    }

    func matchSimilarUsers(interests: [String]) {
        // 未來可接 AI 匹配
    }

    func clearSelection() {
        selectedGroup = nil
        posts.removeAll()
        leaderboard.removeAll()
    }
    
    // MARK: - 便利方法（供 GroupDetailView 使用）
    func getMembers(for groupId: String) -> [GroupMember] {
        communityService.getGroupLeaderboard(groupId)
    }
    
    func getPosts(for groupId: String) -> [CommunityPost] {
        communityService.getPosts(forGroupId: groupId)
    }
}
