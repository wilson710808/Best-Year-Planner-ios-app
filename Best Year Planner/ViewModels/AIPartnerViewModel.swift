import Foundation
import Combine
import os.log

@MainActor
final class AIPartnerViewModel: ObservableObject {
    @Published var messages: [AIMessage] = []
    @Published var inputText: String = ""
    @Published var isLoading: Bool = false
    @Published var welcomeMessage: String = ""
    @Published var partnerName: String = ""
    @Published var errorMessage: String?

    private let authService = AuthService.shared
    private let checkInService = CheckInService.shared
    private let taskService = TaskService.shared
    private let goalService = GoalService.shared
    private let logger = Logger(subsystem: "com.bestyear.planner", category: "AIPartnerViewModel")
    
    // MARK: - Service Locator (Pluggable AI)
    private var aiProvider: any AIProvider {
        ServiceLocator.shared.aiProvider
    }

    /// 初始化伙伴名称
    init(partnerName: String = "小夥伴") {
        self.partnerName = partnerName
    }

    /// 加载个性化欢迎消息
    func loadWelcomeMessage() async {
        logger.info("Loading partner welcome message...")
        
        if messages.isEmpty {
            guard let currentUser = authService.getCurrentUser() else {
                logger.warning("No current user found, using default welcome message")
                welcomeMessage = "嗨！我是你的AI夥伴\(partnerName)。我會陪伴你一起成長，分享我的經驗來支持你。有什麼想聊的嗎？"
                let welcome = AIMessage(content: welcomeMessage, isFromUser: false)
                messages.append(welcome)
                return
            }
            
            logger.info("Current user: \(currentUser.id)")

            // 获取用户数据用于个性化欢迎消息
            let userData = await getUserDataForPersonalization()
            logger.info("User data: \(userData)")

            // 从 AI Gateway 获取个性化欢迎消息
            logger.info("Fetching welcome message from AI Gateway...")
            let personalizedWelcome = await aiProvider.query(
                userId: currentUser.id,
                partnerName: partnerName,
                userData: userData
            )
            
            logger.info("Received welcome message: \(personalizedWelcome)")

            welcomeMessage = personalizedWelcome
            let welcome = AIMessage(content: welcomeMessage, isFromUser: false)
            messages.append(welcome)
        }
    }

    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        logger.info("Sending message to partner...")

        let userMessage = AIMessage(content: inputText, isFromUser: true)
        messages.append(userMessage)

        let userInput = inputText
        inputText = ""
        isLoading = true
        errorMessage = nil

        let response = await generateResponse(to: userInput)
        
        logger.info("Received response: \(response)")

        let aiMessage = AIMessage(content: response, isFromUser: false)
        messages.append(aiMessage)

        isLoading = false
    }

    private func generateResponse(to userInput: String) async -> String {
        guard let currentUser = authService.getCurrentUser() else {
            logger.error("No current user found")
            return "請先登入後再與AI夥伴對話。"
        }
        
        logger.info("Generating response for user: \(currentUser.id), query: \(userInput)")

        // 调用 AI Gateway API 获取回复
        let response = await aiProvider.getPartnerResponse(
            userId: currentUser.id,
            query: userInput,
            partnerName: partnerName,
            conversationHistory: messages
        )
        
        if response.contains("網路連線失敗") || response.contains("服務暫時不可用") {
            errorMessage = response
        }
        
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
        if currentStreak > 0 {
            recentAchievement = "連續打卡 \(currentStreak) 天"
        } else if let _ = completedCheckIns.first {
            recentAchievement = "已開始打卡"
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

    /// 更换伙伴名称
    func updatePartnerName(_ newName: String) {
        partnerName = newName
    }

    /// 清空对话历史
    func clearConversation() {
        messages.removeAll()
        welcomeMessage = ""
    }
}
