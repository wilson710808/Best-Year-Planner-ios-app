import Foundation

final class CommunityService {
    static let shared = CommunityService()
    private let database = DatabaseManager.shared
    private init() {}

    // MARK: - Groups

    func createGroup(name: String, theme: String, description: String, dailyCheckInGoal: Int = 1) -> CommunityGroup {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        let group = CommunityGroup(
            name: name,
            theme: theme,
            groupDescription: description,
            memberIds: [userId],
            adminId: userId,
            dailyCheckInGoal: dailyCheckInGoal
        )
        _ = database.saveCommunityGroup(group)
        return group
    }

    func getAllGroups() -> [CommunityGroup] {
        return database.getAllCommunityGroups()
    }

    func joinGroup(_ groupId: String) -> Bool {
        guard var group = database.getCommunityGroup(byId: groupId) else { return false }
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        guard !group.memberIds.contains(userId) else { return false }
        group.memberIds.append(userId)
        return database.saveCommunityGroup(group)
    }

    func leaveGroup(_ groupId: String) -> Bool {
        guard var group = database.getCommunityGroup(byId: groupId) else { return false }
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        group.memberIds.removeAll { $0 == userId }
        if group.memberIds.isEmpty {
            group.isActive = false
        }
        return database.saveCommunityGroup(group)
    }

    // MARK: - Posts

    func createPost(groupId: String, content: String, imageURLs: [String] = []) -> CommunityPost {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        let nickname = AuthService.shared.getCurrentUser()?.nickname ?? "匿名用戶"
        let post = CommunityPost(
            groupId: groupId,
            authorId: userId,
            authorNickname: nickname,
            content: content,
            imageURLs: imageURLs
        )
        _ = database.saveCommunityPost(post)
        return post
    }

    func getPosts(forGroupId groupId: String) -> [CommunityPost] {
        return database.getCommunityPosts(forGroupId: groupId)
    }

    func deletePost(_ postId: String) -> Bool {
        return database.deleteCommunityPost(byId: postId)
    }

    func likePost(_ postId: String, userId: String) -> Bool {
        // Need to fetch, modify, and save — simplified since no single-post getter
        // This will be handled in ViewModel layer
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

    // MARK: - Leaderboard

    func getGroupLeaderboard(_ groupId: String) -> [GroupMember] {
        guard let group = database.getCommunityGroup(byId: groupId) else { return [] }
        var members: [GroupMember] = []
        for memberId in group.memberIds {
            let user = DatabaseManager.shared.getUser(byId: memberId)
            let nickname = user?.nickname ?? "未知用戶"
            let avatarURL = user?.avatarURL

            // 計算打卡統計
            let checkIns = CheckInService.shared.getAllCheckIns()
            let userCheckIns = checkIns.filter { _ in true } // 簡化：check_ins 表缺 user_id 分組
            let totalCheckIns = userCheckIns.filter { $0.status == .completed }.count
            let currentStreak = userCheckIns.filter { $0.status == .completed }.first?.streakDay ?? 0

            let member = GroupMember(
                odUserId: memberId,
                nickname: nickname,
                avatarURL: avatarURL,
                totalCheckIns: totalCheckIns,
                currentStreak: currentStreak
            )
            members.append(member)
        }
        // 按打卡次數排序
        return members.sorted { $0.totalCheckIns > $1.totalCheckIns }
    }

    func matchSimilarUsers(interests: [String]) -> [User] {
        // 基於興趣標籤匹配（暫時返回空，未來可接 AI）
        return []
    }
}
