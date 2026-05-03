import Foundation
import Combine

@MainActor
final class OnboardingViewModel: ObservableObject {
    @Published var currentStep: Int = 0
    @Published var careerAnswers: [String: String] = [:]
    @Published var relationshipAnswers: [String: String] = [:]
    @Published var growthAnswers: [String: String] = [:]

    @Published var generatedGoals: [Goal] = []
    @Published var directionalSuggestions: [DirectionalSuggestion] = []
    @Published var isLoading: Bool = false
    @Published var isGeneratingGoals: Bool = false

    private let aiService = AIService.shared

    let careerQuestions: [QuestionnaireQuestion] = [
        QuestionnaireQuestion(dimension: .career, question: "你目前的工作狀態是？", options: ["全職工作", "自由工作者", "創業者", "學生"]),
        QuestionnaireQuestion(dimension: .career, question: "你對目前的收入滿意嗎？", options: ["非常滿意", "滿意", "一般", "不滿意", "非常不滿意"]),
        QuestionnaireQuestion(dimension: .career, question: "你希望在事業上達到什麼目標？", options: ["創業當老闆", "晋升加薪", "技能提升", "轉行發展", "工作生活平衡"]),
        QuestionnaireQuestion(dimension: .career, question: "你每個月願意投入多少時間學習新技能？", options: ["不到5小時", "5-10小時", "10-20小時", "20小時以上"]),
        QuestionnaireQuestion(dimension: .career, question: "你對目前的工作環境滿意嗎？", options: ["非常滿意", "滿意", "一般", "不滿意", "非常不滿意"], requiresTextInput: true)
    ]

    let relationshipQuestions: [QuestionnaireQuestion] = [
        QuestionnaireQuestion(dimension: .relationship, question: "你目前的感情狀態是？", options: ["單身", "戀愛中", "已婚", "離異", "不願透露"]),
        QuestionnaireQuestion(dimension: .relationship, question: "你與家人的關係如何？", options: ["非常親密", "親密", "一般", "較為疏遠", "非常疏遠"]),
        QuestionnaireQuestion(dimension: .relationship, question: "你每週花多少時間社交？", options: ["很少", "1-5小時", "5-10小時", "10小時以上"]),
        QuestionnaireQuestion(dimension: .relationship, question: "你希望在人際關係上改善什麼？", options: ["家庭關係", "伴侶關係", "友情關係", "職場人脈", "社交技巧"]),
        QuestionnaireQuestion(dimension: .relationship, question: "你對目前的人際關係滿意嗎？", options: ["非常滿意", "滿意", "一般", "不滿意", "非常不滿意"], requiresTextInput: true)
    ]

    let growthQuestions: [QuestionnaireQuestion] = [
        QuestionnaireQuestion(dimension: .growth, question: "你目前的健康狀況如何？", options: ["非常好", "良好", "一般", "較差", "很差"]),
        QuestionnaireQuestion(dimension: .growth, question: "你每週運動多少次？", options: ["幾乎不", "1-2次", "3-4次", "5次以上"]),
        QuestionnaireQuestion(dimension: .growth, question: "你每年閱讀多少本書？", options: ["幾乎不讀", "1-5本", "6-12本", "12本以上"]),
        QuestionnaireQuestion(dimension: .growth, question: "你希望在自我成長上專注什麼？", options: ["健康健身", "心智成長", "情緒管理", "興趣培養", "全面發展"]),
        QuestionnaireQuestion(dimension: .growth, question: "你對目前的生活品質滿意嗎？", options: ["非常滿意", "滿意", "一般", "不滿意", "非常不滿意"], requiresTextInput: true)
    ]

    var totalSteps: Int { 5 }

    var canProceedToNext: Bool {
        switch currentStep {
        case 1: return careerAnswers.count >= 3
        case 2: return relationshipAnswers.count >= 3
        case 3: return growthAnswers.count >= 3
        default: return true
        }
    }

    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }

    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }

    func saveAnswer(questionId: String, dimension: GoalDimension, answer: String) {
        switch dimension {
        case .career:
            careerAnswers[questionId] = answer
        case .relationship:
            relationshipAnswers[questionId] = answer
        case .growth:
            growthAnswers[questionId] = answer
        }
    }

    func generateGoals() async {
        isGeneratingGoals = true

        var allAnswers: [QuestionnaireAnswer] = []

        for (questionId, answer) in careerAnswers {
            allAnswers.append(QuestionnaireAnswer(questionId: questionId, dimension: .career, answer: answer))
        }
        for (questionId, answer) in relationshipAnswers {
            allAnswers.append(QuestionnaireAnswer(questionId: questionId, dimension: .relationship, answer: answer))
        }
        for (questionId, answer) in growthAnswers {
            allAnswers.append(QuestionnaireAnswer(questionId: questionId, dimension: .growth, answer: answer))
        }

        generatedGoals = aiService.generateGoalsFromQuestionnaire(answers: allAnswers)
        directionalSuggestions = aiService.generateDirectionalSuggestions(from: allAnswers)

        isGeneratingGoals = false
    }

    func saveGeneratedGoals() {
        for goal in generatedGoals {
            _ = GoalService.shared.createGoal(goal)
        }
    }

    func updateGoal(_ goal: Goal) {
        if let index = generatedGoals.firstIndex(where: { $0.id == goal.id }) {
            generatedGoals[index] = goal
        }
    }

    func addGoal(_ goal: Goal) {
        generatedGoals.append(goal)
    }

    func removeGoal(at index: Int) {
        guard index < generatedGoals.count else { return }
        generatedGoals.remove(at: index)
    }
}
