import Foundation

enum ReviewType: String, Codable, CaseIterable {
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"

    var displayName: String {
        switch self {
        case .weekly: return "每週復盤"
        case .monthly: return "月度復盤"
        case .yearly: return "年度復盤"
        }
    }
}

struct Review: Codable, Identifiable, Equatable {
    var id: String
    var type: ReviewType
    var period: String
    var summary: String
    var achievements: [String]
    var improvements: [String]
    var nextWeekFocus: [String]?
    var aiSuggestions: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        type: ReviewType,
        period: String,
        summary: String = "",
        achievements: [String] = [],
        improvements: [String] = [],
        nextWeekFocus: [String]? = nil,
        aiSuggestions: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.period = period
        self.summary = summary
        self.achievements = achievements
        self.improvements = improvements
        self.nextWeekFocus = nextWeekFocus
        self.aiSuggestions = aiSuggestions
        self.createdAt = createdAt
    }

    static func == (lhs: Review, rhs: Review) -> Bool {
        lhs.id == rhs.id
    }
}
