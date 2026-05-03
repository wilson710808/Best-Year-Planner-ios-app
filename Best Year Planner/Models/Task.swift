import Foundation

enum TaskStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    case cancelled = "cancelled"

    var displayName: String {
        switch self {
        case .pending: return "待開始"
        case .inProgress: return "進行中"
        case .completed: return "已完成"
        case .cancelled: return "已取消"
        }
    }
}

struct Task: Codable, Identifiable, Equatable {
    var id: String
    var goalId: String
    var title: String
    var description: String?
    var checkInCount: Int
    var currentStreak: Int
    var longestStreak: Int
    var priority: Priority
    var status: TaskStatus
    var deadline: Date?
    var reminderTime: Date?
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        goalId: String,
        title: String,
        description: String? = nil,
        checkInCount: Int = 0,
        currentStreak: Int = 0,
        longestStreak: Int = 0,
        priority: Priority = .medium,
        status: TaskStatus = .pending,
        deadline: Date? = nil,
        reminderTime: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.title = title
        self.description = description
        self.checkInCount = checkInCount
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.priority = priority
        self.status = status
        self.deadline = deadline
        self.reminderTime = reminderTime
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    static func == (lhs: Task, rhs: Task) -> Bool {
        lhs.id == rhs.id
    }
}
