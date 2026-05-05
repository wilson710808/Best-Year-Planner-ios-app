import Foundation

/// AI 驅動的個性化任務生成擴展
extension AIService {

    /// 根據目標內容調用 AI Gateway 生成個性化任務
    func generateTasksFromGoalWithAI(_ goal: Goal, userId: String) async -> [Task] {
        let prompt = """
        用戶有一個年度目標："\(goal.title)"（維度：\(goal.dimension.displayName)）
        描述：\(goal.description ?? "無")

        請為這個目標生成 4-6 個具體可執行的任務，每個任務包含：
        - title: 任務名稱（15字以內）
        - description: 簡要說明
        - priority: high/medium/low
        - deadline_days: 從今天起算的天數（建議1-180天內）

        請以 JSON 陣列格式輸出：
        [{"title":"...","description":"...","priority":"high","deadline_days":30}]
        """

        let response = await queryAIGateway(userId: userId, query: prompt)

        // 嘗試解析 AI 回覆
        guard let data = response.data(using: .utf8),
              let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            // Fallback: 使用規則模板
            return generateTasksFromGoal(goal)
        }

        return jsonArray.compactMap { dict -> Task? in
            guard let title = dict["title"] as? String else { return nil }
            let desc = dict["description"] as? String
            let priorityStr = dict["priority"] as? String ?? "medium"
            let deadlineDays = dict["deadline_days"] as? Int

            let priority: Priority = switch priorityStr {
            case "high": .high
            case "low": .low
            default: .medium
            }

            let deadline = deadlineDays.flatMap { Calendar.current.date(byAdding: .day, value: $0, to: Date()) }

            return Task(
                goalId: goal.id,
                title: title,
                description: desc ?? "",
                priority: priority,
                deadline: deadline
            )
        }
    }
}
