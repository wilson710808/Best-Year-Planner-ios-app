import Foundation

/// 統一封裝 JSON 解析邏輯
struct JSONParser {
    
    // MARK: - Extract JSON from AI Response
    
    /// 從 AI 返回的文字中提取 JSON 字符串
    /// 支持 markdown code block 和純 JSON 格式
    static func extractJSON(from response: String) -> String {
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to extract JSON from markdown code block
        if let range = response.range(of: "```json") {
            let start = response.index(range.upperBound, offsetBy: 0)
            if let endRange = response[start...].range(of: "```") {
                jsonString = String(response[start..<endRange.lowerBound])
            }
        } else if let range = response.range(of: "```") {
            let start = response.index(range.upperBound, offsetBy: 0)
            if let endRange = response[start...].range(of: "```") {
                jsonString = String(response[start..<endRange.lowerBound])
            }
        }
        
        return jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    // MARK: - Parse JSON
    
    /// 解析為通用字典
    static func parseAsDictionary(from response: String) -> [String: Any]? {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return json
    }
    
    /// 解析為通用數組
    static func parseAsArray(from response: String) -> [[String: Any]]? {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return nil
        }
        return json
    }
    
    // MARK: - Challenge Plan Parsing
    
    /// 解析 7 天啟動計劃
    static func parseLaunchPlan(from response: String) -> SevenDayLaunchPlan? {
        guard let json = parseAsDictionary(from: response),
              let title = json["title"] as? String,
              let tasksArray = json["tasks"] as? [[String: Any]] else {
            return nil
        }
        
        let tasks: [DailyChallengeTask] = tasksArray.compactMap { taskDict in
            parseDailyTask(from: taskDict)
        }
        
        return SevenDayLaunchPlan(title: title, tasks: tasks)
    }
    
    /// 解析 21 天挑戰任務列表
    static func parseChallengeTasks(from response: String, challengeId: String) -> [DailyChallengeTask]? {
        guard let json = parseAsDictionary(from: response),
              let tasksArray = json["tasks"] as? [[String: Any]] else {
            return nil
        }
        
        return tasksArray.compactMap { taskDict in
            var task = parseDailyTask(from: taskDict)
            task.challengeId = challengeId
            return task
        }
    }
    
    // MARK: - Helper
    
    private static func parseDailyTask(from dict: [String: Any]) -> DailyChallengeTask {
        let dayNumber = dict["day"] as? Int ?? 0
        let title = dict["title"] as? String ?? "第\(dayNumber)天任務"
        let description = dict["description"] as? String ?? ""
        let tip = dict["tip"] as? String
        
        return DailyChallengeTask(
            dayNumber: dayNumber,
            title: title,
            description: description,
            estimatedMinutes: AppConstants.Challenge.defaultTaskMinutes,
            aiTip: tip
        )
    }
}