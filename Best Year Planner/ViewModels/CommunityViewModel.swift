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

    private let communityService = CommunityService.shared

    func loadGroups() {
        isLoading = true
        groups = []
        isLoading = false
    }

    func createGroup(name: String, theme: String, description: String) {
        let group = communityService.createGroup(name: name, theme: theme, description: description)
        groups.append(group)
    }

    func joinGroup(_ group: CommunityGroup) {
        _ = communityService.joinGroup(group.id)
    }

    func leaveGroup(_ group: CommunityGroup) {
        _ = communityService.leaveGroup(group.id)
        groups.removeAll { $0.id == group.id }
    }

    func selectGroup(_ group: CommunityGroup) {
        selectedGroup = group
        loadPosts(forGroupId: group.id)
        loadLeaderboard(forGroupId: group.id)
    }

    func loadPosts(forGroupId groupId: String) {
        posts = []
    }

    func loadLeaderboard(forGroupId groupId: String) {
        leaderboard = communityService.getGroupLeaderboard(groupId)
    }

    func createPost(groupId: String, content: String) {
        let post = communityService.createPost(groupId: groupId, content: content)
        posts.insert(post, at: 0)
    }

    func likePost(_ post: CommunityPost) {
        _ = communityService.likePost(post.id, userId: UserDefaultsManager.shared.currentUserId ?? "")
    }

    func unlikePost(_ post: CommunityPost) {
        _ = communityService.unlikePost(post.id, userId: UserDefaultsManager.shared.currentUserId ?? "")
    }

    func addComment(toPost post: CommunityPost, content: String) {
        let comment = communityService.addComment(toPostId: post.id, content: content)
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].comments.append(comment)
        }
    }

    func matchSimilarUsers(interests: [String]) {
        _ = communityService.matchSimilarUsers(interests: interests)
    }

    func clearSelection() {
        selectedGroup = nil
        posts.removeAll()
        leaderboard.removeAll()
    }
}
