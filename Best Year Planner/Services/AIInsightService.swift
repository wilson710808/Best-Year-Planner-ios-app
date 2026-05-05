import Foundation

/// AI 洞察報告服務 — 彙整用戶週/月數據，調用 AI Gateway 生成洞察
final class AIInsightService {
    static let shared = AIInsightService()
    private let database = DatabaseManager.shared
    private let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
    private init() {}

    // MARK: - 週洞察

    func generateWeeklyInsight(userId: String) async -> AIInsight? {
        let checkIns = CheckInService.shared.getRecentCheckIns(days: 7)
        let goals = GoalService.shared.getAllGoals()
        let tasks = TaskService.shared.getAllTasks()

        let completedTasks = tasks.filter { $0.status == .completed }
        let completionRate = tasks.isEmpty ? 0 : Double(completedTasks.count) / Double(tasks.count)

        let prompt = """
        作為AI生活教練，根據以下用戶本週數據生成洞察報告：
        - 打卡次數：\(checkIns.count)
        - 任務完成率：\(Int(completionRate * 100))%
        - 活躍目標數：\(goals.count)
        - 完成任務數：\(completedTasks.count)

        請輸出 JSON 格式：
        {
          "summary": "一句話總結本週表現",
          "strengths": ["優勢1", "優勢2"],
          "improvements": ["改進1", "改進2"],
          "nextWeekFocus": "下週聚焦建議",
          "motivationQuote": "激勵語句"
        }
        """

        let response = await aiProvider.query(userId: userId, query: prompt)
        return parseInsightResponse(response, type: .weekly)
    }

    // MARK: - 月洞察

    func generateMonthlyInsight(userId: String) async -> AIInsight? {
        let checkIns = CheckInService.shared.getRecentCheckIns(days: 30)
        let goals = GoalService.shared.getAllGoals()
        let tasks = TaskService.shared.getAllTasks()
        let reviews = ReviewService.shared.getWeeklyReviews()

        let completedGoals = goals.filter { $0.status == .completed }
        let completionRate = goals.isEmpty ? 0 : Double(completedGoals.count) / Double(goals.count)

        let prompt = """
        作為AI生活教練，根據以下用戶本月數據生成深度洞察報告：
        - 打卡次數：\(checkIns.count)
        - 目標完成率：\(Int(completionRate * 100))%
        - 已完成目標：\(completedGoals.count)/\(goals.count)
        - 週復盤次數：\(reviews.count)

        請輸出 JSON 格式：
        {
          "summary": "一句話總結本月表現",
          "trends": ["趨勢1", "趨勢2"],
          "achievements": ["成就1", "成就2"],
          "challenges": ["挑戰1", "挑戰2"],
          "nextMonthFocus": "下月聚焦建議",
          "motivationQuote": "激勵語句"
        }
        """

        let response = await aiProvider.query(userId: userId, query: prompt)
        return parseInsightResponse(response, type: .monthly)
    }

    // MARK: - 解析

    private func parseInsightResponse(_ response: String, type: AIInsightType) -> AIInsight? {
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // Fallback: 嘗試從文本中提取
            return AIInsight(
                type: type,
                summary: response.prefix(100).description,
                strengths: [],
                improvements: [],
                focus: "",
                motivationQuote: "",
                createdAt: Date()
            )
        }

        return AIInsight(
            type: type,
            summary: json["summary"] as? String ?? json["summary"] as? String ?? "",
            strengths: json["strengths"] as? [String] ?? json["trends"] as? [String] ?? [],
            improvements: json["improvements"] as? [String] ?? json["challenges"] as? [String] ?? [],
            focus: json["nextWeekFocus"] as? String ?? json["nextMonthFocus"] as? String ?? "",
            motivationQuote: json["motivationQuote"] as? String ?? "",
            createdAt: Date()
        )
    }
}

// MARK: - Models

enum AIInsightType: String, Codable {
    case weekly = "weekly"
    case monthly = "monthly"
}

struct AIInsight: Codable, Identifiable {
    var id: String = UUID().uuidString
    var type: AIInsightType
    var summary: String
    var strengths: [String]
    var improvements: [String]
    var focus: String
    var motivationQuote: String
    var createdAt: Date
}
