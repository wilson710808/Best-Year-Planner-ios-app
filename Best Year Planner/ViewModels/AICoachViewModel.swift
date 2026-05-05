import Foundation
import Combine

@MainActor
final class AICoachViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var currentReminder: String?
    @Published var currentReview: Review?
    @Published var welcomeMessage: String = ""

    // 對話持久化
    private var currentConversation: AIConversation?
    private let database = DatabaseManager.shared

    private let reviewService = ReviewService.shared
    private let checkInService = CheckInService.shared
    private let taskService = TaskService.shared
    private let authService = AuthService.shared
    private let goalService = GoalService.shared

    // MARK: - Service Locator (Pluggable AI)
    private var aiProvider: any AIProvider { ServiceLocator.shared.aiProvider }

    /// 加載個性化歡迎消息 + 恢復歷史對話
    func loadWelcomeMessage() async {
        print("[AICoachViewModel] Loading welcome message...")

        // 恢復歷史對話
        restoreConversation()

        if messages.isEmpty {
            guard let currentUser = authService.getCurrentUser() else {
                print("[AICoachViewModel] No current user found, using default welcome message")
                welcomeMessage = "嗨！我是你的AI教練。根據《規劃最好的一年》原則，我會幫助你設定目標、追蹤進度、克服拖延。有什麼我可以幫助你的嗎？"
                let welcome = AIMessage(content: welcomeMessage, isFromUser: false)
                messages.append(welcome)
                saveCurrentConversation()
                return
            }

            print("[AICoachViewModel] Current user: \(currentUser.id)")
            let userData = await getUserDataForPersonalization()
            print("[AICoachViewModel] User data: \(userData)")

            let personalizedWelcome = await aiProvider.query(
                userId: currentUser.id,
                query: "請給我一句溫暖的歡迎消息，提及你是一位專業的AI教練"
            )
            print("[AICoachViewModel] Received welcome message: \(personalizedWelcome)")
            welcomeMessage = personalizedWelcome

            let welcome = AIMessage(content: welcomeMessage, isFromUser: false)
            messages.append(welcome)
            saveCurrentConversation()
        } else {
            // 已有歷史對話，直接使用
            welcomeMessage = messages.first?.content ?? ""
            print("[AICoachViewModel] Restored \(messages.count) messages from history")
        }
    }

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        print("[AICoachViewModel] Sending message...")

        let userMessage = AIMessage(content: inputText, isFromUser: true)
        messages.append(userMessage)
        let userInput = inputText
        inputText = ""
        isLoading = true

        let response = await generateResponse(to: userInput)
        print("[AICoachViewModel] Received response: \(response)")

        let aiMessage = AIMessage(content: response, isFromUser: false)
        messages.append(aiMessage)
        isLoading = false

        // 持久化對話
        saveCurrentConversation()
    }

    private func generateResponse(to userInput: String) async -> String {
        guard let currentUser = authService.getCurrentUser() else {
            print("[AICoachViewModel] No current user found")
            return "請先登入後再與AI教練對話。"
        }

        print("[AICoachViewModel] Generating response for user: \(currentUser.id), query: \(userInput)")

        // 調用 AI Provider，傳遞完整對話歷史以支持上下文理解
        let response = await aiProvider.getCoachResponse(
            userId: currentUser.id,
            query: userInput,
            conversationHistory: messages
        )
        return response
    }

    // MARK: - Conversation Persistence

    /// 恢復最近的對話歷史
    private func restoreConversation() {
        guard let userId = authService.getCurrentUser()?.id else { return }
        let conversations = database.getConversations(forUserId: userId, type: "coach")
        if let latest = conversations.first {
            currentConversation = latest
            messages = latest.messages
            print("[AICoachViewModel] Restored conversation \(latest.id) with \(latest.messages.count) messages")
        }
    }

    /// 保存當前對話到數據庫
    private func saveCurrentConversation() {
        guard let userId = authService.getCurrentUser()?.id else { return }

        if var conversation = currentConversation {
            conversation.messages = messages
            conversation.updatedAt = Date()
            _ = database.saveConversation(conversation)
            currentConversation = conversation
        } else {
            let newConversation = AIConversation(
                userId: userId,
                type: .coach,
                messages: messages
            )
            _ = database.saveConversation(newConversation)
            currentConversation = newConversation
        }
    }

    /// 清除對話歷史（開始新對話）
    func clearConversation() {
        if let conversation = currentConversation {
            _ = database.deleteConversation(byId: conversation.id)
        }
        currentConversation = nil
        messages = []
        welcomeMessage = ""
        Task {
            await loadWelcomeMessage()
        }
    }

    /// 獲取用戶數據用於個性化
    private func getUserDataForPersonalization() async -> [String: Any] {
        guard let currentUser = authService.getCurrentUser() else { return [:] }

        let checkIns = checkInService.getAllCheckIns()
        let completedCheckIns = checkIns.filter { $0.status == .completed }
        let currentStreak = completedCheckIns.first?.streakDay ?? 0
        let totalCheckIns = completedCheckIns.count

        let goals = goalService.getAllGoals()
        let completedGoals = goals.filter { $0.status == .completed }
        let activeGoals = goals.filter { $0.status == .active }

        let tasks = taskService.getAllTasks()
        let completedTasks = tasks.filter { $0.status == .completed }

        var recentAchievement: String?
        if completedCheckIns.first != nil {
            recentAchievement = "最近打卡記錄"
        } else if !goals.isEmpty {
            recentAchievement = "已設定 \(goals.count) 個目標"
        }

        return [
            "nickname": currentUser.nickname,
            "account": currentUser.account,
            "current_streak": currentStreak,
            "total_check_ins": totalCheckIns,
            "goals_count": goals.count,
            "completed_goals": completedGoals.count,
            "active_goals": activeGoals.count,
            "completed_tasks": completedTasks.count,
            "recent_achievement": recentAchievement ?? "開始規劃最好的一年"
        ]
    }

    func checkAndSendTrackDeviationReminder() {
        let checkIns = checkInService.getAllCheckIns()
        let missedDays = checkIns.filter { $0.date.daysBetween(Date()) > 1 && $0.status == .missed }.count
        if missedDays >= 2 {
            let data: [String: Any] = ["missedDays": missedDays]
            let message = generateLocalReminder(forSituation: "trackDeviation", userData: data)
            currentReminder = message
        }
    }

    func checkAndSendStreakReminder() {
        let checkIns = checkInService.getAllCheckIns()
        let completedCheckIns = checkIns.filter { $0.status == .completed }
        if let streak = completedCheckIns.first?.streakDay, streak > 0 {
            let data: [String: Any] = ["streak": streak]
            let message = generateLocalReminder(forSituation: "streakMaintenance", userData: data)
            currentReminder = message
        }
    }

    // MARK: - Local Reminder Generator (not via AI)
    private func generateLocalReminder(forSituation situation: String, userData: [String: Any]) -> String {
        switch situation {
        case "trackDeviation":
            guard let missedDays = userData["missedDays"] as? Int else {
                return "我注意到你的進度有些落後了。不用擔心，讓我們一起找出原因並調整計劃。"
            }
            return "你已經連續 \(missedDays) 天沒有打卡了。這是完全正常的！讓我們重新調整目標和節奏，確保計劃切實可行。"

        case "streakMaintenance":
            guard let streak = userData["streak"] as? Int else {
                return "保持這個勢頭！你做得很好。"
            }
            if streak >= 7 {
                return "太棒了！你已經連續打卡 \(streak) 天了。這種持續性正是成功習慣的關鍵。建議設定下一個里程碑來維持動力！"
            } else {
                return "你已經連續打卡 \(streak) 天了！保持這個好習慣，每天進步一點點。"
            }

        default:
            return "有什麼我可以幫助你的嗎？無論是目標設定、克服拖延還是時間管理，我都在這裡支持你。"
        }
    }

    func loadWeeklyReview() {
        currentReview = reviewService.createWeeklyReview()
    }

    func loadMonthlyReview() {
        currentReview = reviewService.createMonthlyReview()
    }
}
