import Foundation

enum Gender: String, Codable, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"

    var displayName: String {
        switch self {
        case .male: return "男性"
        case .female: return "女性"
        case .other: return "其他"
        case .preferNotToSay: return "不便透露"
        }
    }
}

struct User: Codable, Identifiable, Equatable {
    var id: String
    var account: String
    var passwordHash: String
    var nickname: String
    var avatarURL: String?
    var gender: Gender?
    var birthYear: Int?
    var createdAt: Date
    var personalityTags: [String]
    var isOnboardingCompleted: Bool

    init(
        id: String = UUID().uuidString,
        account: String,
        passwordHash: String,
        nickname: String,
        avatarURL: String? = nil,
        gender: Gender? = nil,
        birthYear: Int? = nil,
        createdAt: Date = Date(),
        personalityTags: [String] = [],
        isOnboardingCompleted: Bool = false
    ) {
        self.id = id
        self.account = account
        self.passwordHash = passwordHash
        self.nickname = nickname
        self.avatarURL = avatarURL
        self.gender = gender
        self.birthYear = birthYear
        self.createdAt = createdAt
        self.personalityTags = personalityTags
        self.isOnboardingCompleted = isOnboardingCompleted
    }

    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}
