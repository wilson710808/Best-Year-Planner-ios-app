import Foundation

/// Mock AI 服務實現，用於測試和離線環境
/// 完全符合 AIProvider 協議，可熱插拔替換
public final class MockAIService: AIProvider, Sendable {
    
    public let name = "MockAIService"
    
    // MARK: - AIProvider Protocol
    
    public func query(userId: String, query: String) async -> String {
        // 模擬網絡延遲
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if query.contains("教練") || query.contains("教練") {
            return "作為你的 AI 教練，我建議你每天進步一點點，堅持就是勝利！"
        } else if query.contains("夥伴") {
            return "嘿！我是你的 AI 夥伴，我曾經也遇到過類似的挑戰，一起加油！"
        } else {
            return "這是一個來自 Mock AI 的回覆。在測試環境中，一切都在掌控之中。"
        }
    }
    
    public func generateSevenDayLaunchPlan(answers: [String], userId: String) async -> SevenDayLaunchPlan? {
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        // 返回模擬數據
        let tasks = (1...7).map { day -> LaunchTask in
            LaunchTask(
                day: day,
                title: "第\(day)天任務",
                description: "這是第\(day)天的任務描述",
                tip: "每天進步一點點！"
            )
        }
        
        return SevenDayLaunchPlan(
            title: "7天啟動計畫（Mock）",
            tasks: tasks
        )
    }
    
    public func generateTwentyOneDayChallenge(goalId: String, completedLaunch: Challenge, userId: String) async -> [DailyChallengeTask]? {
        try? await Task.sleep(nanoseconds: 300_000_000)
        
        return (1...21).map { day in
            DailyChallengeTask(
                id: UUID().uuidString,
                challengeId: goalId,
                dayNumber: day,
                title: "第\(day)天挑戰",
                description: "完成今天的挑戰任務",
                tip: "堅持就是勝利！",
                isCompleted: false
            )
        }
    }
    
    public func generateDailyTip(challengeId: String, dayNumber: Int, previousDays: [DailyChallengeTask], userId: String) async -> String {
        let completed = previousDays.filter { $0.isCompleted }.count
        
        let tips = [
            "每天進步一點點，累積起來就是巨大的改變！🌟",
            "你已經完成了\(completed)天，繼續保持這個勢頭！💪",
            "現在的堅持，就是未來成功的基石！🏆",
            "相信自己能夠做到，你已經在正確的道路上了！✨",
            "休息也是進步的一部分，不要忘記照顧好自己！🌿"
        ]
        
        return tips.randomElement() ?? tips[0]
    }
    
    public func getCoachResponse(userId: String, query: String, conversationHistory: [AIMessage]) async -> String {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        if query.contains("放棄") || query.contains("堅持不下去") {
            return "我理解你的感受。每個人都會有低潮期，但放棄永遠不是解決問題的方法。讓我們一起找出阻礙你的原因，重新調整計畫。你願意告訴我什麼讓你感到困難嗎？"
        } else if query.contains("成功") || query.contains("完成") {
            return "太棒了！恭喜你取得這個成就！這證明你的努力正在產生回報。讓我們設定下一個目標，繼續這個成功的勢頭！🎉"
        } else {
            return "作為你的教練，我建議你：1) 設定具體可行的目標 2) 每天堅持一小步 3) 定期回顧和調整。記住，改變是一個過程，不要著急。"
        }
    }
    
    public func getPartnerResponse(userId: String, query: String, partnerName: String, conversationHistory: [AIMessage]) async -> String {
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        return "嗨！我是\(partnerName)，你親密的夥伴！我理解你的處境，我也曾經歷過類似的挑戰。重要的是我們不放棄，一起加油！你今天做了什麼讓自己驕傲的事情嗎？"
    }
    
    public func generateWeeklyReviewSummary(checkIns: [CheckIn], tasks: [Task]) async -> String {
        let completedTasks = tasks.filter { $0.status == .completed }.count
        let totalTasks = tasks.count
        let completionRate = totalTasks > 0 ? Double(completedTasks) / Double(totalTasks) : 0
        
        let completedCheckIns = checkIns.filter { $0.status == .completed }.count
        let longestStreak = checkIns.map { $0.streakDay }.max() ?? 0
        
        var summary = "📊 本週回顧（Mock）\n\n"
        summary += "✅ 完成任務：\(completedTasks)/\(totalTasks) (\(Int(completionRate * 100))%)\n"
        summary += "📝 打卡次數：\(completedCheckIns)\n"
        summary += "🔥 最長連續：\(longestStreak) 天\n\n"
        
        if completionRate >= 0.8 {
            summary += "🌟 表現出色！這週你做得非常好！"
        } else if completionRate >= 0.5 {
            summary += "👍 還不錯！還有進步空間。"
        } else {
            summary += "💪 下週繼續努力！"
        }
        
        return summary
    }
    
    public func generateAISuggestion(forType type: ReviewType, data: [String: Any]) async -> String {
        switch type {
        case .weekly:
            return "這週的表現很不錯！建議你繼續保持每日的微習慣，不要給自己太大壓力。"
        case .monthly:
            return "月的複盤很重要。建議你記錄這月最大的三個成就，然後規劃下月的重點突破領域。"
        case .yearly:
            return "年度目標的設定，建議採用 SMART 原則：具體(S)、可衡量(M)、可達成(A)、相關(R)、有時限(T)。"
        }
    }
}

// MARK: - Mock Storage Provider

public final class MockStorageProvider: StorageProvider, Sendable {
    private var storage: [String: Data] = [:]
    
    public func save<T: Codable>(_ item: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(item)
        storage[key] = data
    }
    
    public func load<T: Codable>(forKey key: String) async throws -> T? {
        guard let data = storage[key] else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        storage.removeValue(forKey: key)
    }
}

// MARK: - UserDefaults Storage Provider

public final class UserDefaultsStorageProvider: StorageProvider, Sendable {
    private let defaults = UserDefaults.standard
    
    public func save<T: Codable>(_ item: T, forKey key: String) async throws {
        let data = try JSONEncoder().encode(item)
        defaults.set(data, forKey: key)
    }
    
    public func load<T: Codable>(forKey key: String) async throws -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    public func remove(forKey key: String) async throws {
        defaults.removeObject(forKey: key)
    }
}
