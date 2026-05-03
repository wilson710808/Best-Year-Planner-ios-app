import Foundation

struct CommunityGroup: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var theme: String
    var groupDescription: String
    var memberIds: [String]
    var adminId: String
    var createdAt: Date
    var dailyCheckInGoal: Int
    var isActive: Bool

    init(
        id: String = UUID().uuidString,
        name: String,
        theme: String,
        groupDescription: String = "",
        memberIds: [String] = [],
        adminId: String,
        createdAt: Date = Date(),
        dailyCheckInGoal: Int = 1,
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.theme = theme
        self.groupDescription = groupDescription
        self.memberIds = memberIds
        self.adminId = adminId
        self.createdAt = createdAt
        self.dailyCheckInGoal = dailyCheckInGoal
        self.isActive = isActive
    }

    static func == (lhs: CommunityGroup, rhs: CommunityGroup) -> Bool {
        lhs.id == rhs.id
    }
}

struct CommunityPost: Codable, Identifiable, Equatable {
    var id: String
    var groupId: String
    var authorId: String
    var authorNickname: String
    var content: String
    var imageURLs: [String]
    var likes: [String]
    var comments: [Comment]
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        groupId: String,
        authorId: String,
        authorNickname: String,
        content: String,
        imageURLs: [String] = [],
        likes: [String] = [],
        comments: [Comment] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.authorId = authorId
        self.authorNickname = authorNickname
        self.content = content
        self.imageURLs = imageURLs
        self.likes = likes
        self.comments = comments
        self.createdAt = createdAt
    }

    static func == (lhs: CommunityPost, rhs: CommunityPost) -> Bool {
        lhs.id == rhs.id
    }
}

struct Comment: Codable, Identifiable, Equatable {
    var id: String
    var authorId: String
    var authorNickname: String
    var content: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        authorId: String,
        authorNickname: String,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.authorId = authorId
        self.authorNickname = authorNickname
        self.content = content
        self.createdAt = createdAt
    }

    static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
}

struct GroupMember: Codable, Identifiable, Equatable {
    var id: String { odUserId }
    var odUserId: String
    var nickname: String
    var avatarURL: String?
    var totalCheckIns: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCheckInDate: Date?

    init(
        odUserId: String,
        nickname: String,
        avatarURL: String? = nil,
        totalCheckIns: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        lastCheckInDate: Date? = nil
    ) {
        self.odUserId = odUserId
        self.nickname = nickname
        self.avatarURL = avatarURL
        self.totalCheckIns = totalCheckIns
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCheckInDate = lastCheckInDate
    }

    static func == (lhs: GroupMember, rhs: GroupMember) -> Bool {
        lhs.odUserId == rhs.odUserId
    }
}
