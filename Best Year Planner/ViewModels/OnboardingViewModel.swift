import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var answer1: String = ""
    @Published var answer2: String = ""
    @Published var answer3: String = ""
    @Published var isGeneratingPlan: Bool = false
    @Published var generatedPlan: SevenDayLaunchPlan?
    @Published var errorMessage: String?

    let questions = SimpleOnboardingQuestion.allQuestions

    var totalSteps: Int { 4 }  // Welcome → Q1 → Q2+Q3 → Plan Preview

    var canProceed: Bool {
        switch currentStep {
        case 1: return !answer1.trimmingCharacters(in: .whitespaces).isEmpty
        case 2: return !answer2.trimmingCharacters(in: .whitespaces).isEmpty
                    && !answer3.trimmingCharacters(in: .whitespaces).isEmpty
        default: return true
        }
    }

    private let aiService = AIService.shared

    func nextStep() {
        withAnimation {
            if currentStep < totalSteps - 1 {
                currentStep += 1
            }
        }
    }

    func previousStep() {
        withAnimation {
            if currentStep > 0 {
                currentStep -= 1
            }
        }
    }

    func generateLaunchPlan() async {
        isGeneratingPlan = true
        errorMessage = nil

        let prompt = """
        用戶回答了三個問題：
        1. 今年最想提升的是：\(answer1)
        2. 願意從小事開始：\(answer2)
        3. 一年後想成為：\(answer3)

        請根據這些回答，為用戶設計一個7天啟動計畫，每天一個5分鐘可完成的小任務，目標是讓用戶體驗到「我真的可以堅持」。

        請嚴格按照以下JSON格式返回，不要包含其他文字：
        {"title":"計畫標題","tasks":[{"day":1,"title":"任務標題","description":"任務描述","tip":"AI小建議"}]}
        """

        let response = await aiService.queryAIGateway(userId: "onboarding_\(UUID().uuidString.prefix(8))", query: prompt)

        // Try to parse JSON from response
        if let plan = parsePlanFromResponse(response) {
            generatedPlan = plan
        } else {
            // Fallback: generate a simple plan from user answers
            generatedPlan = generateFallbackPlan()
        }

        isGeneratingPlan = false
    }

    private func parsePlanFromResponse(_ response: String) -> SevenDayLaunchPlan? {
        return JSONParser.parseLaunchPlan(from: response)
    }

    private func generateFallbackPlan() -> SevenDayLaunchPlan {
        let focusArea = answer1
        let smallAction = answer2
        let futureSelf = answer3

        return SevenDayLaunchPlan(
            title: "我的\(focusArea)啟動計畫",
            tasks: [
                DailyChallengeTask(dayNumber: 1, title: "寫下你的目標", description: "把「\(futureSelf)」寫在紙上或手機備忘錄，放在每天能看到的地方", estimatedMinutes: 3, aiTip: "寫下來的目標，實現率提升42%。今天就從這一步開始！"),
                DailyChallengeTask(dayNumber: 2, title: "5分鐘微行動", description: "做「\(smallAction)」的最小版本，只要5分鐘", estimatedMinutes: 5, aiTip: "不需要完美，只需要開始。5分鐘的行動勝過0分鐘的計畫。"),
                DailyChallengeTask(dayNumber: 3, title: "記錄你的感受", description: "做完微行動後，花1分鐘寫下你的感受", estimatedMinutes: 2, aiTip: "記錄感受能強化正向回饋，讓大腦記住「做到」的感覺。"),
                DailyChallengeTask(dayNumber: 4, title: "找人分享", description: "跟一位朋友或家人分享你這幾天的改變", estimatedMinutes: 5, aiTip: "分享目標的人，成功率高出65%。你不需要一個人走。"),
                DailyChallengeTask(dayNumber: 5, title: "加一點難度", description: "把微行動增加2分鐘，感受進步", estimatedMinutes: 7, aiTip: "你已經堅持到第5天了！適度增加難度是成長的信號。"),
                DailyChallengeTask(dayNumber: 6, title: "回顧這一週", description: "寫下這5天最讓你驕傲的一件事", estimatedMinutes: 5, aiTip: "回顧不是自誇，是讓自己看見：我真的可以堅持。"),
                DailyChallengeTask(dayNumber: 7, title: "慶祝你的堅持", description: "為自己準備一個小獎勵，然後準備迎接21天挑戰！", estimatedMinutes: 5, aiTip: "🎉 你做到了！7天不間斷，這就是改變的開始。")
            ]
        )
    }

    func savePlanAndComplete() {
        guard let plan = generatedPlan else { return }

        // Save onboarding answers
        let answers = OnboardingAnswers(
            answer1: answer1,
            answer2: answer2,
            answer3: answer3,
            generatedPlanTitle: plan.title
        )
        UserDefaultsManager.shared.onboardingAnswers = answers

        // Create a Goal for this launch plan
        let goal = Goal(
            title: plan.title,
            description: "7天啟動計畫：\(answer1)",
            dimension: inferDimension(from: answer1),
            level: .sevenDayLaunch,
            priority: .high
        )
        _ = GoalService.shared.createGoal(goal)

        // Create Challenge with daily tasks
        let challenge = Challenge(
            goalId: goal.id,
            phase: .sevenDayLaunch,
            totalDays: AppConstants.Challenge.launchDays,
            dailyTasks: plan.tasks.map { task in
                var t = task
                t.challengeId = goal.id
                return t
            }
        )

        // Save challenge to database
        _ = DatabaseManager.shared.saveChallenge(challenge)

        // Update app state
        AppState.shared.completeOnboarding()
        AppState.shared.incrementActiveChallengeCount()
    }

    private func inferDimension(from text: String) -> GoalDimension {
        let lower = text.lowercased()
        let careerKeywords = ["事業", "工作", "財富", "收入", "升職", "創業", "技能", "career", "job", "money"]
        let relationshipKeywords = ["人際", "關係", "家庭", "朋友", "伴侶", "社交", "relationship", "family"]

        for keyword in careerKeywords where lower.contains(keyword) { return .career }
        for keyword in relationshipKeywords where lower.contains(keyword) { return .relationship }
        return .growth
    }
}
