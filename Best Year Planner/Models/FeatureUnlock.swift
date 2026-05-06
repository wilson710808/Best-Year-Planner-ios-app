import Foundation

// MARK: - 逐步解鎖機制

/// 功能解鎖管理 — 根據使用天數逐步開放功能，降低認知負荷
enum Feature: String, CaseIterable, Codable {
    case checkIn          = "checkIn"          // Day 1: 打卡（基礎）
    case aiCoach          = "aiCoach"          // Day 3: AI教練
    case aiPartners       = "aiPartners"       // Day 7: AI夥伴揪團
    case dataAnalytics    = "dataAnalytics"    // Day 14: 數據分析
    case beliefAudit      = "beliefAudit"      // Day 7: 信念審計
    case pastReview       = "pastReview"       // Day 1: 總結過去
    case smarterScorer    = "smarterScorer"    // Day 3: SMARTER評分
    case abandonList      = "abandonList"      // Day 14: 待棄清單
    case coachStyle       = "coachStyle"       // Day 7: 教練風格
    case makeUpCheckIn    = "makeUpCheckIn"    // Day 3: 補卡
    case milestone        = "milestone"        // Day 14: 里程碑

    /// 解鎖所需天數（從首次使用開始計算）
    var requiredDays: Int {
        switch self {
        case .checkIn:       return 1
        case .pastReview:    return 1
        case .aiCoach:       return 3
        case .smarterScorer: return 3
        case .makeUpCheckIn: return 3
        case .beliefAudit:   return 7
        case .aiPartners:    return 7
        case .coachStyle:    return 7
        case .dataAnalytics: return 14
        case .abandonList:   return 14
        case .milestone:     return 14
        }
    }

    var displayName: String {
        switch self {
        case .checkIn:       return "每日打卡"
        case .aiCoach:       return "AI 教練"
        case .aiPartners:    return "AI 夥伴揪團"
        case .dataAnalytics: return "進階數據分析"
        case .beliefAudit:   return "信念審計"
        case .pastReview:    return "總結過去"
        case .smarterScorer: return "SMARTER 評分"
        case .abandonList:   return "待棄清單"
        case .coachStyle:    return "教練風格"
        case .makeUpCheckIn: return "補打卡"
        case .milestone:     return "里程碑牆"
        }
    }

    var icon: String {
        switch self {
        case .checkIn:       return "checkmark.circle.fill"
        case .aiCoach:       return "brain.head.profile"
        case .aiPartners:    return "person.2.fill"
        case .dataAnalytics: return "chart.bar.fill"
        case .beliefAudit:   return "lightbulb.fill"
        case .pastReview:    return "book.fill"
        case .smarterScorer: return "target"
        case .abandonList:   return "scissors"
        case .coachStyle:    return "person.wave.2.fill"
        case .makeUpCheckIn: return "clock.arrow.circlepath"
        case .milestone:     return "flag.fill"
        }
    }

    var description: String {
        switch self {
        case .checkIn:       return "開始你的第一步：完成今天的打卡"
        case .aiCoach:       return "AI 教練上線！可以問問題、尋求建議"
        case .aiPartners:    return "3-5 位 AI 夥伴陪你一起成長"
        case .dataAnalytics: return "解鎖進階數據：趨勢圖、完成時間線"
        case .beliefAudit:   return "深入識別你的限制性信念"
        case .pastReview:    return "回顧過去，才能更好地規劃未來"
        case .smarterScorer: return "用 SMARTER 原則檢視你的目標"
        case .abandonList:   return "學會對不重要的事說「不」"
        case .coachStyle:    return "選擇最適合你的 AI 教練風格"
        case .makeUpCheckIn: return "錯過的打卡可以補，帶著反思"
        case .milestone:     return "記錄每一個重要突破"
        }
    }
}

// MARK: - Feature Unlock Manager

final class FeatureUnlockManager {
    static let shared = FeatureUnlockManager()
    private let defaults = UserDefaults.standard
    private let firstUseDateKey = "firstUseDate"

    private init() {}

    /// 首次使用日期
    var firstUseDate: Date? {
        get { defaults.object(forKey: firstUseDateKey) as? Date }
        set { defaults.set(newValue, forKey: firstUseDateKey) }
    }

    /// 使用天數
    var daysSinceFirstUse: Int {
        guard let firstDate = firstUseDate else { return 0 }
        return Calendar.current.dateComponents([.day], from: firstDate.startOfDay, to: Date().startOfDay).day ?? 0
    }

    /// 檢查功能是否已解鎖
    func isUnlocked(_ feature: Feature) -> Bool {
        return daysSinceFirstUse >= feature.requiredDays
    }

    /// 即將解鎖的功能（3天內）
    func upcomingUnlocks() -> [Feature] {
        Feature.allCases.filter { feature in
            let daysLeft = feature.requiredDays - daysSinceFirstUse
            return daysLeft > 0 && daysLeft <= 3
        }
    }

    /// 剛剛解鎖的功能（今天解鎖）
    func newlyUnlocked() -> [Feature] {
        Feature.allCases.filter { feature in
            feature.requiredDays == daysSinceFirstUse
        }
    }

    /// 確保首次使用日期已記錄
    func ensureFirstUseDate() {
        if firstUseDate == nil {
            firstUseDate = Date()
        }
    }

    /// 某功能還需幾天解鎖
    func daysUntilUnlock(_ feature: Feature) -> Int {
        return max(0, feature.requiredDays - daysSinceFirstUse)
    }
}

// MARK: - 無干擾模式

final class FocusModeManager {
    static let shared = FocusModeManager()
    private let defaults = UserDefaults.standard

    private init() {}

    var isFocusMode: Bool {
        get { defaults.bool(forKey: "isFocusMode") }
        set {
            defaults.set(newValue, forKey: "isFocusMode")
            NotificationCenter.default.post(name: .focusModeChanged, name: .focusModeChanged, object: nil)
        }
    }
}

extension Notification.Name {
    static let focusModeChanged = Notification.Name("focusModeChanged")
}

// MARK: - MIT 最重要三件事

/// 每天只聚焦3個最高優先級任務
struct MITTask: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var taskId: String
    var title: String
    var priority: Int  // 1-3, 1最重要
    var isCompleted: Bool = false
}

// MARK: - 智能提醒

/// 根據用戶歷史打卡時間推斷最佳提醒時機
final class SmartReminderManager {
    static let shared = SmartReminderManager()
    private let defaults = UserDefaults.standard
    private let checkInTimeHistoryKey = "checkInTimeHistory"

    private init() {}

    /// 記錄打卡時間
    func recordCheckInTime() {
        var history = loadHistory()
        history.append(Date())
        // 只保留最近30天
        if history.count > 30 { history = Array(history.suffix(30)) }
        if let data = try? JSONEncoder().encode(history) {
            defaults.set(data, forKey: checkInTimeHistoryKey)
        }
    }

    /// 推斷最佳提醒時間（用戶最常打卡的時間段）
    func suggestedReminderTime() -> Date? {
        let history = loadHistory()
        guard history.count >= 3 else { return nil }

        // 找出最常打卡的小時
        let hourCounts = history.reduce(into: [Int: Int]()) { counts, date in
            let hour = Calendar.current.component(.hour, from: date)
            counts[hour, default: 0] += 1
        }

        guard let mostCommonHour = hourCounts.max(by: { $0.value < $1.value })?.key else { return nil }

        // 建議提前30分鐘提醒
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = mostCommonHour
        components.minute = 0
        return Calendar.current.date(byAdding: .minute, value: -30, to: components.date ?? Date())
    }

    /// 連續打卡後提醒頻率自動降低
    func shouldShowReminder(consecutiveDays: Int) -> Bool {
        if consecutiveDays < 7 { return true }   // 每天提醒
        if consecutiveDays < 21 { return consecutiveDays % 3 == 0 } // 每3天
        return consecutiveDays % 7 == 0 // 每週一次
    }

    private func loadHistory() -> [Date] {
        guard let data = defaults.data(forKey: checkInTimeHistoryKey),
              let history = try? JSONDecoder().decode([Date].self, from: data) else { return [] }
        return history
    }
}

// MARK: - 季度/月度校正

struct PeriodCalibration: Codable, Identifiable {
    var id: String = UUID().uuidString
    var periodType: String   // "quarterly" or "monthly"
    var year: Int
    var period: Int          // quarter 1-4, month 1-12
    var completedItems: [String]    // 完成了什麼
    var stuckItems: [String]        // 什麼卡住了
    var adjustments: [String]       // 下期調整
    var goalAdjustments: [String]   // 目標調整（繼續/暫停/修改/刪除）
    var newOpportunities: [String]  // 新機會
    var aiReport: String?
    var createdAt: Date = Date()
}
