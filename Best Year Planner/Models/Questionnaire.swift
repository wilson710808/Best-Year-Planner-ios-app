import Foundation

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
        self.growthAnswers = growthAnswers
        self.generatedGoals = generatedGoals
        self.isCompleted = isCompleted
    }
}
