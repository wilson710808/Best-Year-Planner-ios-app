import Foundation

// MARK: - Challenge Phase
enum ChallengePhase: String, Codable, CaseIterable {
    case sevenDayLaunch = "7day_launch"
    case twentyOneDayChallenge = "21day_challenge"
    case completed = "completed"

    var displayName: String {
        switch self {
        case .sevenDayLaunch: return "7天啟動"
        case .twentyOneDayChallenge: return "21天挑戰"
        case .completed: return "已完成"
        }
    }
}

// MARK: - Challenge
struct Challenge: Codable, Identifiable, Equatable {
    var id: String
    var goalId: String
    var phase: ChallengePhase
    var totalDays: Int
    var completedDays: Int
    var startDate: Date
    var isUnlocked: Bool
    var dailyTasks: [DailyChallengeTask]
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        goalId: String,
        phase: ChallengePhase = .sevenDayLaunch,
        totalDays: Int = 7,
        completedDays: Int = 0,
        startDate: Date = Date(),
        isUnlocked: Bool = false,
        dailyTasks: [DailyChallengeTask] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.phase = phase
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.startDate = startDate
        self.isUnlocked = isUnlocked
        self.dailyTasks = dailyTasks
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(completedDays) / Double(totalDays)
    }

    var isCompleted: Bool {
        completedDays >= totalDays
    }

    var currentDayNumber: Int {
        let calendar = Calendar.current
        let daysElapsed = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        return min(daysElapsed + 1, totalDays)
    }

    static func == (lhs: Challenge, rhs: Challenge) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Daily Challenge Task
struct DailyChallengeTask: Codable, Identifiable, Equatable {
    var id: String
    var challengeId: String
    var dayNumber: Int
    var title: String
    var description: String
    var estimatedMinutes: Int
    var isCompleted: Bool
    var completedAt: Date?
    var aiTip: String?

    init(
        id: String = UUID().uuidString,
        challengeId: String,
        dayNumber: Int,
        title: String,
        description: String,
        estimatedMinutes: Int = 5,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        aiTip: String? = nil
    ) {
        self.id = id
        self.challengeId = challengeId
        self.dayNumber = dayNumber
        self.title = title
        self.description = description
        self.estimatedMinutes = estimatedMinutes
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.aiTip = aiTip
    }

    static func == (lhs: DailyChallengeTask, rhs: DailyChallengeTask) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Seven Day Launch Plan (AI 生成)
struct SevenDayLaunchPlan: Codable, Identifiable {
    var id: String
    var title: String
    var tasks: [DailyChallengeTask]
    var createdAt: Date

    init(id: String = UUID().uuidString, title: String, tasks: [DailyChallengeTask], createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.tasks = tasks
        self.createdAt = createdAt
    }
}

// MARK: - Challenge Progress (for tracking)
struct ChallengeProgress: Codable {
    var totalDays: Int
    var completedDays: Int
    var currentStreak: Int
    var longestStreak: Int
    var lastCheckInDate: Date?

    var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(completedDays) / Double(totalDays)
    }

    var isCompleted: Bool {
        completedDays >= totalDays
    }

    init(totalDays: Int = 21, completedDays: Int = 0, currentStreak: Int = 0, longestStreak: Int = 0, lastCheckInDate: Date? = nil) {
        self.totalDays = totalDays
        self.completedDays = completedDays
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.lastCheckInDate = lastCheckInDate
    }
}