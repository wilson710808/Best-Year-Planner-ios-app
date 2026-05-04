import Foundation

// MARK: - Subscription Tier
enum SubscriptionTier: String, Codable {
    case free = "free"
    case premium = "premium"
}

// MARK: - Subscription State
struct SubscriptionState: Codable {
    var tier: SubscriptionTier
    var activeChallengeCount: Int
    var maxFreeChallenges: Int = 3
    var startDate: Date
    var expiryDate: Date?
    var isPremium: Bool { tier == .premium }
    var canCreateNewChallenge: Bool { isPremium || activeChallengeCount < maxFreeChallenges }

    var remainingFreeChallenges: Int {
        max(0, maxFreeChallenges - activeChallengeCount)
    }

    init(
        tier: SubscriptionTier = .free,
        activeChallengeCount: Int = 0,
        maxFreeChallenges: Int = 3,
        startDate: Date = Date(),
        expiryDate: Date? = nil
    ) {
        self.tier = tier
        self.activeChallengeCount = activeChallengeCount
        self.maxFreeChallenges = maxFreeChallenges
        self.startDate = startDate
        self.expiryDate = expiryDate
    }
}

// MARK: - Subscription Feature
enum SubscriptionFeature: String, CaseIterable {
    case unlimitedChallenges = "unlimited_challenges"
    case advancedAnalytics = "advanced_analytics"
    case aiInsights = "ai_insights"
    case prioritySupport = "priority_support"
    case customReminder = "custom_reminder"

    var title: String {
        switch self {
        case .unlimitedChallenges: return "無限挑戰"
        case .advancedAnalytics: return "進階分析"
        case .aiInsights: return "AI 洞察報告"
        case .prioritySupport: return "優先客服支援"
        case .customReminder: return "自訂提醒時間"
        }
    }

    var description: String {
        switch self {
        case .unlimitedChallenges: return "可同時進行多個 21 天挑戰"
        case .advancedAnalytics: return "查看詳細的進度分析與趨勢圖"
        case .aiInsights: return "每日 AI 生成的個人化洞察"
        case .prioritySupport: return "遇到問題時優先獲得回覆"
        case .customReminder: return "自由設定任何時間的提醒通知"
        }
    }
}