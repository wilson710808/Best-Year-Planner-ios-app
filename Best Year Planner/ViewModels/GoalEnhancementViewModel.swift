import Foundation
import SwiftUI

@MainActor
final class GoalEnhancementViewModel: ObservableObject {
    // 年度回顧
    @Published var yearlyReview: YearlyReview?
    @Published var topAchievements: [String] = ["", "", ""]
    @Published var regrets: [String] = ["", "", ""]
    @Published var lessonsLearned: [String] = ["", "", ""]

    // 限制性信念
    @Published var limitingBeliefs: [LimitingBelief] = []
    @Published var isGeneratingResponse = false

    // 目標動機
    @Published var goalMotivations: [GoalMotivation] = [:]
    @Published var currentGoalWhys: [String] = ["", "", ""]
    @Published var motivationCard: String?

    // SMARTER
    @Published var smarterScores: [String: SMARTERScore] = [:]
    @Published var currentSMARTER: SMARTERScore?
    @Published var smarterSuggestions: [String] = []
    @Published var smarterHistory: [SMARTERScore] = []

    // 領先/滯後指標
    @Published var goalIndicators: [String: [GoalIndicator]] = [:]

    // 待棄清單
    @Published var abandonItems: [AbandonItem] = []
    @Published var newAbandonTitle = ""
    @Published var newAbandonReason = ""

    // 里程碑
    @Published var milestones: [Milestone] = []

    // AI 教練風格
    @Published var coachStyle: CoachStyle = .warm

    // 目標上限提醒
    @Published var showGoalLimitWarning = false

    private let service = GoalEnhancementService.shared
    private let goalService = GoalService.shared

    // MARK: - 限制性信念

    func loadLimitingBeliefs() {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let saved = service.loadLimitingBeliefs(userId: userId)
        limitingBeliefs = saved.isEmpty ? service.getCommonLimitingBeliefs() : saved
    }

    func generateEmpoweringResponses() async {
        isGeneratingResponse = true
        let result = await service.generateEmpoweringResponses(beliefs: limitingBeliefs)
        limitingBeliefs = result
        isGeneratingResponse = false
    }

    func saveBeliefs() {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        _ = service.saveLimitingBeliefs(limitingBeliefs, userId: userId)
    }

    // MARK: - 年度回顧

    func loadYearlyReview() {
        let year = Calendar.current.component(.year, from: Date())
        yearlyReview = service.getYearlyReview(year: year)
        if let review = yearlyReview {
            topAchievements = review.topAchievements.count >= 3 ? review.topAchievements : ["", "", ""]
            regrets = review.regrets.count >= 3 ? review.regrets : ["", "", ""]
            lessonsLearned = review.lessonsLearned.count >= 3 ? review.lessonsLearned : ["", "", ""]
        }
    }

    func saveYearlyReview() async {
        let year = Calendar.current.component(.year, from: Date())
        var review = YearlyReview(
            year: year,
            topAchievements: topAchievements.filter { !$0.isEmpty },
            regrets: regrets.filter { !$0.isEmpty },
            lessonsLearned: lessonsLearned.filter { !$0.isEmpty }
        )

        // AI 生成經驗萃取報告
        let report = await service.generateExperienceReport(review: review)
        review.aiExperienceReport = report

        _ = service.saveYearlyReview(review)
        yearlyReview = review
    }

    // MARK: - 目標動機

    func loadGoalMotivation(goalId: String) {
        if let motivation = service.getGoalMotivation(goalId: goalId) {
            currentGoalWhys = motivation.whys.count >= 3 ? motivation.whys : ["", "", ""]
            motivationCard = motivation.aiMotivationCard
        } else {
            currentGoalWhys = ["", "", ""]
            motivationCard = nil
        }
    }

    func saveGoalMotivation(goalId: String, goalTitle: String) async {
        var motivation = GoalMotivation(
            goalId: goalId,
            whys: currentGoalWhys.filter { !$0.isEmpty }
        )

        // AI 生成動機卡片
        let card = await service.generateMotivationCard(whys: motivation.whys, goalTitle: goalTitle)
        motivation.aiMotivationCard = card

        _ = service.saveGoalMotivation(motivation)
        motivationCard = card
    }

    // MARK: - SMARTER 評分

    func loadSMARTERScore(goalId: String) {
        currentSMARTER = service.getSMARTERScore(goalId: goalId)
        smarterHistory = service.getSMARTERScoreHistory(goalId: goalId)
    }

    func saveSMARTERScore(goalId: String, goalTitle: String) async {
        guard var score = currentSMARTER else { return }
        score.goalId = goalId

        // AI 生成改進建議
        let suggestions = await service.generateSMARTERSuggestions(score: score, goalTitle: goalTitle)
        score.aiSuggestions = suggestions

        _ = service.saveSMARTERScore(score)
        smarterSuggestions = suggestions
    }

    // MARK: - 領先/滯後指標

    func loadGoalIndicators(goalId: String) {
        goalIndicators[goalId] = service.getGoalIndicators(goalId: goalId)
    }

    func saveGoalIndicator(_ indicator: GoalIndicator) {
        _ = service.saveGoalIndicator(indicator)
        loadGoalIndicators(goalId: indicator.goalId)
    }

    // MARK: - 待棄清單

    func loadAbandonItems() {
        abandonItems = service.getAbandonItems()
    }

    func addAbandonItem() {
        guard !newAbandonTitle.isEmpty else { return }
        let item = AbandonItem(title: newAbandonTitle, reason: newAbandonReason.isEmpty ? nil : newAbandonReason)
        _ = service.saveAbandonItem(item)
        abandonItems.insert(item, at: 0)
        newAbandonTitle = ""
        newAbandonReason = ""
    }

    func deleteAbandonItem(id: String) {
        _ = service.deleteAbandonItem(id: id)
        abandonItems.removeAll { $0.id == id }
    }

    // MARK: - 里程碑

    func loadMilestones() {
        milestones = service.getMilestones()
    }

    func addMilestone(title: String, description: String, goalId: String? = nil, category: String? = nil) {
        let milestone = Milestone(goalId: goalId, title: title, description: description, achievedAt: Date(), category: category)
        _ = service.saveMilestone(milestone)
        milestones.insert(milestone, at: 0)
    }

    // MARK: - 目標上限檢查

    func checkGoalLimit() {
        let activeGoals = goalService.getAllGoals().filter { $0.status == .active }
        showGoalLimitWarning = activeGoals.count > 5
    }

    // MARK: - AI 教練風格

    func loadCoachStyle() {
        if let rawValue = UserDefaults.standard.string(forKey: "coachStyle"),
           let style = CoachStyle(rawValue: rawValue) {
            coachStyle = style
        }
    }

    func saveCoachStyle(_ style: CoachStyle) {
        coachStyle = style
        UserDefaults.standard.set(style.rawValue, forKey: "coachStyle")
    }
}
