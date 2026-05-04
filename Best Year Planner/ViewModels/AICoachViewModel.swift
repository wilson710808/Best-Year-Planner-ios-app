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

    private let reviewService = ReviewService.shared
    private let checkInService = CheckInService.shared
    private let taskService = TaskService.shared
    private let authService = AuthService.shared
    private let goalService = GoalService.shared
    
    // MARK: - Service Locator (Pluggable AI)
    private var aiProvider: any AIProvider {
        ServiceLocator.shared.aiProvider
    }
    
    /// Direct AIService access for local methods not in protocol
    private var aiService: AIService {
        AIService.shared
    }

    /// 加载个性化欢迎消息
    func loadWelcomeMessage() async {
        print("[AICoachViewModel] Loading welcome message...")
        
        if messages.isEmpty {
            guard let currentUser = authService.getCurrentUser() else {
                print("[AICoachViewModel] No current user found, using default welcome message")
                welcomeMessage = "嗨！我是你的AI教練。根據《規劃最好的一年》原則，我會幫助你設定目標、追蹤進度、克服拖延。有什麼我可以幫助你的嗎？"
                let welcome = AIMessage(content: welcomeMessage, isFromUser: false)
                messages.append(welcome)
                return
            }
            
            print("[AICoachViewModel] Current user: \(currentUser.id)")

            // 获取用户数据用于个性化欢迎消息
            let userData = await getUserDataForPersonalization()
            print("[AICoachViewModel] User data: \(userData)")

            // 从 AI Gateway 获取个性化欢迎消息
            print("[AICoachViewModel] Fetching welcome message from AI Gateway...")
            let personalizedWelcome = await aiProvider.query(
                userId: currentUser.id,
                query: "請給我一句溫暖的歡迎消息，提及你是一位專業的AI教練"
            )
            
            print("[AICoachViewModel] Received welcome message: \(personalizedWelcome)")

            welcomeMessage = personalizedWelcome
            let welcome = AIMessage(content: welcomeMessage, isFromUser: false)
            messages.append(welcome)
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
    }

    private func generateResponse(to userInput: String) async -> String {
        guard let currentUser = authService.getCurrentUser() else {
            print("[AICoachViewModel] No current user found")
            return "請先登入後再與AI教練對話。"
        }
        
        print("[AICoachViewModel] Generating response for user: \(currentUser.id), query: \(userInput)")

        // 调用 AI Gateway API 获取回复
        let response = await aiProvider.getCoachResponse(
            userId: currentUser.id,
            query: userInput,
            conversationHistory: messages
        )
        
        return response
    }

    /// 获取用户数据用于个性化
    private func getUserDataForPersonalization() async -> [String: Any] {
        guard let currentUser = authService.getCurrentUser() else {
            return [:]
        }

        // 获取用户最近的成就数据
        let checkIns = checkInService.getAllCheckIns()
        let completedCheckIns = checkIns.filter { $0.status == .completed }
        let currentStreak = completedCheckIns.first?.streakDay ?? 0
        let totalCheckIns = completedCheckIns.count

        // 获取目标完成情况
        let goals = goalService.getAllGoals()
        let completedGoals = goals.filter { $0.status == .completed }
        let activeGoals = goals.filter { $0.status == .active }

        // 获取任务完成情况
        let tasks = taskService.getAllTasks()
        let completedTasks = tasks.filter { $0.status == .completed }

        // 获取最近的小成就
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

        let missedDays = checkIns.filter {
            $0.date.daysBetween(Date()) > 1 && $0.status == .missed
        }.count

        if missedDays >= 2 {
            let data: [String: Any] = ["missedDays": missedDays]
            let message = aiService.generateCoachMessage(forSituation: "trackDeviation", userData: data)
            currentReminder = message
        }
    }

    func checkAndSendStreakReminder() {
        let checkIns = checkInService.getAllCheckIns()
        let completedCheckIns = checkIns.filter { $0.status == .completed }

        if let streak = completedCheckIns.first?.streakDay,
           streak > 0 {
            let data: [String: Any] = ["streak": streak]
            let message = aiService.generateCoachMessage(forSituation: "streakMaintenance", userData: data)
            currentReminder = message
        }
    }

    func loadWeeklyReview() {
        currentReview = reviewService.createWeeklyReview()
    }

    func loadMonthlyReview() {
        currentReview = reviewService.createMonthlyReview()
    }
}
