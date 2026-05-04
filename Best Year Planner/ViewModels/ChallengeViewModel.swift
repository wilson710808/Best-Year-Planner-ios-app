import Foundation
import Combine

@MainActor
final class ChallengeViewModel: ObservableObject {
    @Published var activeChallenges: [Challenge] = []
    @Published var currentChallenge: Challenge?
    @Published var todayTask: DailyChallengeTask?
    @Published var isLoading: Bool = false
    @Published var isCompleting: Bool = false
    @Published var showingUnlock: Bool = false
    @Published var showingSubscription: Bool = false

    private let db = DatabaseManager.shared
    private let aiService = AIService.shared

    // MARK: - Load Challenges
    func loadChallenges() {
        activeChallenges = db.getAllChallenges().filter { $0.phase != .completed }
        if let current = activeChallenges.first {
            currentChallenge = current
            loadTodayTask(for: current)
        }
    }

    private func loadTodayTask(for challenge: Challenge) {
        let dayNumber = challenge.currentDayNumber
        todayTask = challenge.dailyTasks.first { $0.dayNumber == dayNumber }
    }

    // MARK: - Complete Daily Task
    func completeTodayTask() async {
        guard var challenge = currentChallenge,
              let taskIndex = challenge.dailyTasks.firstIndex(where: { $0.dayNumber == challenge.currentDayNumber }) else {
            return
        }

        isCompleting = true

        // Get AI tip for completing
        let userId = UserDefaultsManager.shared.currentUserId ?? "anonymous"
        let aiTip = await aiService.queryAIGateway(
            userId: userId,
            query: "用戶剛完成了\(challenge.phase == .sevenDayLaunch ? "7天啟動" : "21天挑戰")第\(challenge.currentDayNumber)天的任務「\(challenge.dailyTasks[taskIndex].title)」，請給一句簡短鼓勵（20字以內）"
        )

        // Update task
        challenge.dailyTasks[taskIndex].isCompleted = true
        challenge.dailyTasks[taskIndex].completedAt = Date()
        challenge.dailyTasks[taskIndex].aiTip = aiTip
        challenge.completedDays += 1
        challenge.updatedAt = Date()

        // Check if challenge is complete
        if challenge.isCompleted {
            if challenge.phase == .sevenDayLaunch {
                // 7天完成，顯示解鎖頁面 + 通知
                showingUnlock = true
                challenge.phase = .completed
                ChallengeNotificationManager.shared.scheduleUnlockReminder()
            } else if challenge.phase == .twentyOneDayChallenge {
                // 21天完成
                challenge.phase = .completed
                AppState.shared.decrementActiveChallengeCount()
                ChallengeNotificationManager.shared.clearBadge()
            }
        } else {
            // Schedule streak warning for the evening
            ChallengeNotificationManager.shared.scheduleStreakWarningReminder(streakDays: challenge.completedDays)
        }

        // Save to database
        _ = db.saveChallenge(challenge)
        currentChallenge = challenge

        // Update today's task
        todayTask = challenge.dailyTasks.first { $0.dayNumber == challenge.currentDayNumber }

        isCompleting = false
    }

    // MARK: - Start 21-Day Challenge
    func startTwentyOneDayChallenge() async {
        guard let launchChallenge = currentChallenge,
              launchChallenge.phase == .completed && launchChallenge.totalDays == AppConstants.Challenge.launchDays else {
            return
        }

        // Check subscription limit
        guard AppState.shared.canCreateNewChallenge else {
            showingSubscription = true
            return
        }

        isLoading = true

        // Get AI to generate 21-day plan based on completed 7-day plan
        let userId = UserDefaultsManager.shared.currentUserId ?? "anonymous"
        let completedTasks = launchChallenge.dailyTasks.map { "第\($0.dayNumber)天: \($0.title) - \($0.isCompleted ? "✅" : "❌")" }.joined(separator: "\n")

        let prompt = """
        用戶已經完成了7天啟動計畫「\(launchChallenge.dailyTasks.first?.title ?? "")」，以下是每天的完成情況：
        \(completedTasks)

        請根據這個基礎，為用戶設計一個21天習慣養成計畫，每天一個任務，時間可以從5-15分鐘遞增。

        請嚴格按照以下JSON格式返回，不要包含其他文字：
        {"title":"計畫標題","tasks":[{"day":1,"title":"任務標題","description":"任務描述","tip":"AI小建議"}]}
        """

        let response = await aiService.queryAIGateway(userId: userId, query: prompt)

        // Create goal for 21-day challenge
        let goal = Goal(
            title: "21天習慣養成",
            description: "基於7天啟動的進階挑戰",
            dimension: .growth,
            level: .twentyOneDayChallenge,
            priority: .high
        )
        _ = GoalService.shared.createGoal(goal)

        // Parse or create fallback 21-day challenge
        var tasks: [DailyChallengeTask] = []
        if let plan = parsePlanFromResponse(response, challengeId: goal.id) {
            tasks = plan.tasks
        } else {
            tasks = generateFallback21DayTasks(challengeId: goal.id)
        }

        let challenge = Challenge(
            goalId: goal.id,
            phase: .twentyOneDayChallenge,
            totalDays: AppConstants.Challenge.challengeDays,
            dailyTasks: tasks
        )

        _ = db.saveChallenge(challenge)
        AppState.shared.incrementActiveChallengeCount()

        // Schedule notifications for the new challenge
        ChallengeNotificationManager.shared.scheduleTwentyOneDayReminders(challenge: challenge)

        showingUnlock = false
        currentChallenge = challenge
        loadTodayTask(for: challenge)

        isLoading = false
    }

    // MARK: - Parsing & Fallback
    private func parsePlanFromResponse(_ response: String, challengeId: String) -> SevenDayLaunchPlan? {
        var jsonString = response

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

        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)

        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let title = json["title"] as? String,
              let tasksArray = json["tasks"] as? [[String: Any]] else {
            return nil
        }

        var tasks: [DailyChallengeTask] = []
        for taskDict in tasksArray {
            let day = taskDict["day"] as? Int ?? (tasks.count + 1)
            let title = taskDict["title"] as? String ?? "第\(day)天任務"
            let desc = taskDict["description"] as? String ?? ""
            let tip = taskDict["tip"] as? String

            tasks.append(DailyChallengeTask(
                challengeId: challengeId,
                dayNumber: day,
                title: title,
                description: desc,
                estimatedMinutes: min(5 + (day / 3) * 2, 15),
                aiTip: tip
            ))
        }

        return SevenDayLaunchPlan(title: title, tasks: tasks)
    }

    private func generateFallback21DayTasks(challengeId: String) -> [DailyChallengeTask] {
        let week1 = (1...7).map { day in
            DailyChallengeTask(
                challengeId: challengeId,
                dayNumber: day,
                title: "第\(day)天 · 習慣建立",
                description: "持續你的微行動，每天5分鐘",
                estimatedMinutes: 5,
                aiTip: "第一週的關鍵是：不間斷。即使很忙，也做最小的版本。"
            )
        }
        let week2 = (8...14).map { day in
            DailyChallengeTask(
                challengeId: challengeId,
                dayNumber: day,
                title: "第\(day)天 · 深化練習",
                description: "增加時間和深度，感受成長",
                estimatedMinutes: 8,
                aiTip: "第二週是深化期，你會開始感受到這個習慣帶來的變化。"
            )
        }
        let week3 = (15...21).map { day in
            DailyChallengeTask(
                challengeId: challengeId,
                dayNumber: day,
                title: "第\(day)天 · 鞏固習慣",
                description: "習慣正在成為你的一部分",
                estimatedMinutes: 10,
                aiTip: "最後一週！你正在把這個行為變成自己的一部分。"
            )
        }
        return week1 + week2 + week3
    }
}
