import Foundation

enum CheckInStatus: String, Codable, CaseIterable {
    case completed = "completed"
    case partial = "partial"
    case missed = "missed"

    var displayName: String {
        switch self {
        case .completed: return "已完成"
        case .partial: return "部分完成"
        case .missed: return "未完成"
        }
    }

    var icon: String {
        switch self {
        case .completed: return "checkmark.circle.fill"
        case .partial: return "circle.lefthalf.filled"
        case .missed: return "xmark.circle.fill"
        }
    }
}

struct CheckIn: Codable, Identifiable, Equatable {
    var id: String
    var taskId: String
    var date: Date
    var status: CheckInStatus
    var note: String?
    var streakDay: Int
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        taskId: String,
        date: Date = Date(),
        status: CheckInStatus = .completed,
        note: String? = nil,
        streakDay: Int = 1,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.taskId = taskId
        self.date = date
        self.status = status
        self.note = note
        self.streakDay = streakDay
        self.createdAt = createdAt
    }

    static func == (lhs: CheckIn, rhs: CheckIn) -> Bool {
        lhs.id == rhs.id
    }
}

struct DailyCheckInSummary: Identifiable {
    var id: String { date.formatted("yyyy-MM-dd") }
    let date: Date
    var totalTasks: Int
    var completedTasks: Int
    var partialTasks: Int
    var missedTasks: Int

    var completionRate: Double {
        guard totalTasks > 0 else { return 0 }
        return (Double(completedTasks) + Double(partialTasks) * 0.5) / Double(totalTasks)
    }
}
