import Foundation

/// 限制性信念記錄
struct LimitingBelief: Codable, Identifiable, Equatable {
    var id: String
    var content: String           // 信念內容
    var category: BeliefCategory // 分類
    var isOvercome: Bool         // 是否已克服
    var overcomeDate: Date?      // 克服日期
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        content: String,
        category: BeliefCategory = .selfDoubt,
        isOvercome: Bool = false,
        overcomeDate: Date? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.content = content
        self.category = category
        self.isOvercome = isOvercome
        self.overcomeDate = overcomeDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

enum BeliefCategory: String, Codable, CaseIterable {
    case selfDoubt = "self_doubt"           // 自我懷疑
    case fearFailure = "fear_failure"        // 害怕失敗
    case fearSuccess = "fear_success"        // 害怕成功
    case perfectionism = "perfectionism"     // 完美主義
    case procrastination = "procrastination" // 拖延
    case lackConfidence = "lack_confidence"  // 缺乏自信
    case timeBelief = "time_belief"          // 時間信念
    case resourceBelief = "resource_belief"  // 資源信念

    var displayName: String {
        switch self {
        case .selfDoubt: return "自我懷疑"
        case .fearFailure: return "害怕失敗"
        case .fearSuccess: return "害怕成功"
        case .perfectionism: return "完美主義"
        case .procrastination: return "拖延"
        case .lackConfidence: return "缺乏自信"
        case .timeBelief: return "時間信念"
        case .resourceBelief: return "資源信念"
        }
    }

    var icon: String {
        switch self {
        case .selfDoubt: return "questionmark.circle"
        case .fearFailure: return "xmark.octagon"
        case .fearSuccess: return "bolt.circle"
        case .perfectionism: return "scope"
        case .procrastination: return "clock"
        case .lackConfidence: return "person.fill.xmark"
        case .timeBelief: return "timer"
        case .resourceBelief: return "cube.box"
        }
    }

    var inspiringQuote: String {
        switch self {
        case .selfDoubt:
            return "你比自己想像的更強大。過去的成功證明瞭你有能力應對挑戰。"
        case .fearFailure:
            return "失敗不是終點，而是學習的機會。每次失敗都讓你更接近成功。"
        case .fearSuccess:
            return "你有資格成功。允許自己成功，是成長的重要一步。"
        case .perfectionism:
            return "完成比完美更好。行動創造改變，而非完美無缺的計劃。"
        case .procrastination:
            return "未來取決於現在。邁出第一步，你就已經在改變的路上了。"
        case .lackConfidence:
            return "自信來自行動。每一次堅持都在為你建立更深厚的信心。"
        case .timeBelief:
            return "時間是最公平的資源。每個人每天都同樣擁有 24 小時。"
        case .resourceBelief:
            return "你擁有所需的一切資源。重要的是如何運用你已有的東西。"
        }
    }
}

/// 目標動機（Why）
struct GoalMotivation: Codable, Equatable {
    var primaryWhy: String      // 主要動機
    var emotionalWhy: String    // 情感層面動機
    var identityWhy: String     // 身份認同動機
    var legacyWhy: String?      // 遺產動機（選填）
}

/// 里程碑
struct Milestone: Codable, Identifiable, Equatable {
    var id: String
    var goalId: String
    var title: String
    var targetDate: Date?
    var isCompleted: Bool
    var completedDate: Date?
    var progress: Double // 0.0 - 1.0
    var createdAt: Date
    var updatedAt: Date

    init(
        id: String = UUID().uuidString,
        goalId: String,
        title: String,
        targetDate: Date? = nil,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        progress: Double = 0.0,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.goalId = goalId
        self.title = title
        self.targetDate = targetDate
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.progress = progress
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

/// 落後預警
struct ProgressWarning: Identifiable {
    var id: String { "\(goalId)-\(date.formatted("yyyy-MM-dd"))" }
    var goalId: String
    var goalTitle: String
    var dimension: GoalDimension
    var date: Date
    var expectedProgress: Double
    var actualProgress: Double
    var severity: WarningSeverity

    var gapPercentage: Double {
        expectedProgress - actualProgress
    }
}

enum WarningSeverity: String, Codable {
    case low = "low"
    case medium = "medium"
    case high = "high"

    var displayName: String {
        switch self {
        case .low: return "輕微落後"
        case .medium: return "需要關注"
        case .high: return "嚴重落後"
        }
    }

    var icon: String {
        switch self {
        case .low: return "info.circle"
        case .medium: return "exclamationmark.triangle"
        case .high: return "exclamationmark.octagon.fill"
        }
    }

    var color: String {
        switch self {
        case .low: return "F5A623"
        case .medium: return "F5A623"
        case .high: return "E74C3C"
        }
    }
}

/// 每日趨勢數據點
struct DailyTrendPoint: Identifiable {
    var id: String { date.formatted("yyyy-MM-dd") }
    var date: Date
    var completionRate: Double
    var checkInCount: Int
    var streakDay: Int
    var tasksCompleted: Int
    var tasksTotal: Int

    var dimensionBreakdown: DimensionBreakdown?
}

struct DimensionBreakdown {
    var career: Double
    var relationship: Double
    var growth: Double

    var avg: Double {
        (career + relationship + growth) / 3.0
    }
}

/// 維度均衡分析
struct DimensionBalanceAnalysis {
    var careerProgress: Double
    var relationshipProgress: Double
    var growthProgress: Double

    var careerStatus: BalanceStatus
    var relationshipStatus: BalanceStatus
    var growthStatus: BalanceStatus

    var overallBalance: BalanceStatus
    var recommendation: String

    var maxGap: Double {
        max(
            abs(careerProgress - relationshipProgress),
            abs(relationshipProgress - growthProgress),
            abs(careerProgress - growthProgress)
        )
    }
}

enum BalanceStatus: String, Codable {
    case balanced = "balanced"
    case slightlyOff = "slightly_off"
    case unbalanced = "unbalanced"
    case critical = "critical"

    var displayName: String {
        switch self {
        case .balanced: return "均衡"
        case .slightlyOff: return "輕微失衡"
        case .unbalanced: return "失衡"
        case .critical: return "嚴重失衡"
        }
    }

    var icon: String {
        switch self {
        case .balanced: return "checkmark.circle.fill"
        case .slightlyOff: return "minus.circle"
        case .unbalanced: return "exclamationmark.triangle"
        case .critical: return "xmark.octagon.fill"
        }
    }

    var color: String {
        switch self {
        case .balanced: return "7ED321"
        case .slightlyOff: return "F5A623"
        case .unbalanced: return "F5A623"
        case .critical: return "E74C3C"
        }
    }
}

/// 增強版 Goal
extension Goal {
    /// SMART 目標屬性
    var isSMART: Bool {
        !title.isEmpty &&
        deadline != nil &&
        progress >= 0
    }

    /// 是否即將逾期（7天內）
    var isNearingDeadline: Bool {
        guard let deadline = deadline else { return false }
        return deadline.daysBetween(Date()) <= 7 && deadline > Date()
    }

    /// 是否已逾期
    var isOverdue: Bool {
        guard let deadline = deadline else { return false }
        return deadline < Date() && status != .completed
    }

    /// 剩余天數
    var daysRemaining: Int? {
        guard let deadline = deadline else { return nil }
        return deadline.daysBetween(Date())
    }
}

/// 增強版 Task
extension Task {
    /// 是否今天到期
    var isDueToday: Bool {
        guard let deadline = deadline else { return false }
        return Calendar.current.isDateInToday(deadline)
    }

    /// 是否已逾期
    var isOverdue: Bool {
        guard let deadline = deadline else { return false }
        return deadline < Date() && status != .completed
    }

    /// 健康度評分（基於連續打卡）
    var healthScore: HealthScore {
        if currentStreak >= 30 { return .excellent }
        if currentStreak >= 14 { return .good }
        if currentStreak >= 7 { return .fair }
        if currentStreak >= 3 { return .needsAttention }
        return .atRisk
    }
}

enum HealthScore: String {
    case excellent = "excellent"
    case good = "good"
    case fair = "fair"
    case needsAttention = "needs_attention"
    case atRisk = "at_risk"

    var displayName: String {
        switch self {
        case .excellent: return "極佳"
        case .good: return "良好"
        case .fair: return "一般"
        case .needsAttention: return "需關注"
        case .atRisk: return "危險"
        }
    }

    var icon: String {
        switch self {
        case .excellent: return "star.fill"
        case .good: return "hand.thumbsup.fill"
        case .fair: return "minus.circle"
        case .needsAttention: return "exclamationmark.circle"
        case .atRisk: return "flame.fill"
        }
    }

    var color: String {
        switch self {
        case .excellent: return "7ED321"
        case .good: return "27AE60"
        case .fair: return "F5A623"
        case .needsAttention: return "F5A623"
        case .atRisk: return "E74C3C"
        }
    }
}
