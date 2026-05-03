import Foundation

enum GoalDimension: String, Codable, CaseIterable {
    case career = "career"
    case relationship = "relationship"
    case growth = "growth"

    var displayName: String {
        switch self {
        case .career: return "事業/財富"
        case .relationship: return "人際關係"
        case .growth: return "自我成長"
        }
    }

    var color: String {
        switch self {
        case .career: return "3498DB"
        case .relationship: return "E74C8C"
        case .growth: return "27AE60"
        }
    }

    var icon: String {
        switch self {
        case .career: return "briefcase.fill"
        case .relationship: return "person.2.fill"
        case .growth: return "leaf.fill"
        }
    }
}

enum GoalLevel: String, Codable, CaseIterable {
    case yearly = "yearly"
    case quarterly = "quarterly"
    case monthly = "monthly"
    case weekly = "weekly"
    case daily = "daily"

    var displayName: String {
        switch self {
        case .yearly: return "年度"
        case .quarterly: return "季度"
        case .monthly: return "月度"
        case .weekly: return "每週"
        case .daily: return "每日"
        }
    }
}

enum Priority: String, Codable, CaseIterable {
    case high = "high"
    case medium = "medium"
    case low = "low"

    var displayName: String {
        switch self {
        case .high: return "高"
        case .medium: return "中"
        case .low: return "低"
        }
    }

    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

enum GoalStatus: String, Codable, CaseIterable {
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .active: return "進行中"
        case .paused: return "已暫停"
        case .completed: return "已完成"
        case .cancelled: return "已取消"
        }
    }
}

struct Goal: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var dimension: GoalDimension
    var level: GoalLevel
    var parentGoalId: String?
    var priority: Priority
    var status: GoalStatus
    var deadline: Date?
    var progress: Double
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        dimension: GoalDimension,
        level: GoalLevel,
        parentGoalId: String? = nil,
        priority: Priority = .medium,
        status: GoalStatus = .active,
        deadline: Date? = nil,
        progress: Double = 0.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.dimension = dimension
        self.level = level
        self.parentGoalId = parentGoalId
        self.priority = priority
        self.status = status
        self.deadline = deadline
        self.progress = progress
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id
    }
}
