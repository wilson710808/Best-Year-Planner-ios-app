import Testing
import Foundation
@testable import Best_Year_Planner

// MARK: - Questionnaire 模型測試
@Suite("Questionnaire 模型測試")
struct QuestionnaireTests {

    @Test("SimpleOnboardingQuestion 有3個預設問題")
    func allQuestionsCount() {
        #expect(SimpleOnboardingQuestion.allQuestions.count == 3)
    }

    @Test("每個問題都有 id、question、placeholder")
    func questionFieldsNotEmpty() {
        for q in SimpleOnboardingQuestion.allQuestions {
            #expect(!q.id.isEmpty)
            #expect(!q.question.isEmpty)
            #expect(!q.placeholder.isEmpty)
        }
    }

    @Test("問題 ID 分別是 q1, q2, q3")
    func questionIds() {
        let ids = SimpleOnboardingQuestion.allQuestions.map(\.id)
        #expect(ids == ["q1", "q2", "q3"])
    }

    @Test("OnboardingAnswers init 和 Codable")
    func onboardingAnswersCodable() throws {
        let answers = OnboardingAnswers(
            answer1: "健康",
            answer2: "每天運動",
            answer3: "更健康"
        )
        #expect(answers.answer1 == "健康")
        #expect(answers.answer2 == "每天運動")
        #expect(answers.answer3 == "更健康")
        #expect(answers.generatedPlanTitle == nil)

        // Codable 測試
        let data = try JSONEncoder().encode(answers)
        let decoded = try JSONDecoder().decode(OnboardingAnswers.self, from: data)
        #expect(decoded.answer1 == "健康")
        #expect(decoded.answer2 == "每天運動")
        #expect(decoded.answer3 == "更健康")
    }

    @Test("OnboardingAnswers 含 generatedPlanTitle")
    func onboardingAnswersWithPlanTitle() {
        let answers = OnboardingAnswers(
            answer1: "事業",
            answer2: "每天閱讀",
            answer3: "更成功",
            generatedPlanTitle: "事業啟動計畫"
        )
        #expect(answers.generatedPlanTitle == "事業啟動計畫")
    }
}
