import Foundation

final class CommunityService {
    static let shared = CommunityService()

    private init() {}

    func createGroup(name: String, theme: String, description: String, dailyCheckInGoal: Int = 1) -> CommunityGroup {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString

        return CommunityGroup(
            name: name,
            theme: theme,
            groupDescription: description,
            memberIds: [userId],
            adminId: userId,
            dailyCheckInGoal: dailyCheckInGoal
        )
    }

    func joinGroup(_ groupId: String) -> Bool {
        return true
    }

    func leaveGroup(_ groupId: String) -> Bool {
        return true
    }

    func createPost(groupId: String, content: String, imageURLs: [String] = []) -> CommunityPost {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        let nickname = AuthService.shared.getCurrentUser()?.nickname ?? "匿名用戶"

        return CommunityPost(
            groupId: groupId,
            authorId: userId,
            authorNickname: nickname,
            content: content,
            imageURLs: imageURLs
        )
    }

    func likePost(_ postId: String, userId: String) -> Bool {
        return true
    }

    func unlikePost(_ postId: String, userId: String) -> Bool {
        return true
    }

    func addComment(toPostId postId: String, content: String) -> Comment {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        let nickname = AuthService.shared.getCurrentUser()?.nickname ?? "匿名用戶"

        return Comment(
            authorId: userId,
            authorNickname: nickname,
            content: content
        )
    }

    func getGroupLeaderboard(_ groupId: String) -> [GroupMember] {
        return []
    }

    func matchSimilarUsers(interests: [String]) -> [User] {
        return []
    }
}
