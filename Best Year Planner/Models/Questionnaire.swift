import Foundation

// MARK: - Simple Onboarding (3 Questions)
struct SimpleOnboardingQuestion: Identifiable {
    let id: String
    let question: String
    let placeholder: String
}

// MARK: - Predefined Questions
extension SimpleOnboardingQuestion {
    static let allQuestions: [SimpleOnboardingQuestion] = [
        SimpleOnboardingQuestion(
            id: "q1",
            question: "今年你最想提升的是什麼？",
            placeholder: "例如：健康、事業、人際關係..."
        ),
        SimpleOnboardingQuestion(
            id: "q2",
            question: "你願意先從一件小事開始嗎？",
            placeholder: "例如：每天早起10分鐘、每天閱讀5頁..."
        ),
        SimpleOnboardingQuestion(
            id: "q3",
            question: "一年後，你最想成為什麼樣的自己？",
            placeholder: "例如：更健康、更自信、更有條理..."
        )
    ]
}

// MARK: - Onboarding Data (Simplified)
struct OnboardingAnswers: Codable {
    var answer1: String  // 最想提升什麼
    var answer2: String  // 願意從什麼小事開始
    var answer3: String  // 一年後想成為什麼樣的自己
    var generatedPlanTitle: String?
    var createdAt: Date

    init(answer1: String, answer2: String, answer3: String, generatedPlanTitle: String? = nil) {
        self.answer1 = answer1
        self.answer2 = answer2
        self.answer3 = answer3
        self.generatedPlanTitle = generatedPlanTitle
        self.createdAt = Date()
    }
}

// MARK: - Legacy Support (kept for data migration)
struct QuestionnaireAnswer: Codable, Identifiable {
    var id: String = UUID().uuidString
    var questionId: String
    var dimension: GoalDimension
    var answer: String
    var createdAt: Date = Date()
}

struct QuestionnaireQuestion: Identifiable {
    let id: String
    let dimension: GoalDimension
    let question: String
    let options: [String]?
    let requiresTextInput: Bool

    init(
        id: String = UUID().uuidString,
        dimension: GoalDimension,
        question: String,
        options: [String]? = nil,
        requiresTextInput: Bool = false
    ) {
        self.id = id
        self.dimension = dimension
        self.question = question
        self.options = options
        self.requiresTextInput = requiresTextInput
    }
}

struct OnboardingData: Codable {
    var careerAnswers: [QuestionnaireAnswer]
    var relationshipAnswers: [QuestionnaireAnswer]
    var growthAnswers: [QuestionnaireAnswer]
    var generatedGoals: [Goal]
    var isCompleted: Bool

    init(
        careerAnswers: [QuestionnaireAnswer] = [],
        relationshipAnswers: [QuestionnaireAnswer] = [],
        growthAnswers: [QuestionnaireAnswer] = [],
        generatedGoals: [Goal] = [],
        isCompleted: Bool = false
    ) {
        self.careerAnswers = careerAnswers
        self.relationshipAnswers = relationshipAnswers
        self.generatedGoals = generatedGoals
        self.growthAnswers = growthAnswers
        self.isCompleted = isCompleted
    }
}
