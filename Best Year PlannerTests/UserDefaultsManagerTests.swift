import Testing
import Foundation
@testable import Best_Year_Planner

// MARK: - UserDefaultsManager 測試
@Suite("UserDefaultsManager 測試")
struct UserDefaultsManagerTests {

    private let testSuiteName = "test.bestyearplanner"

    /// 測試 OnboardingAnswers 存取
    @Test("OnboardingAnswers 存取")
    func onboardingAnswersStorage() {
        let defaults = UserDefaults(suiteName: testSuiteName)!
        defer { defaults.removePersistentDomain(forName: testSuiteName) }

        let key = "test_onboardingAnswers"
        let answers = OnboardingAnswers(
            answer1: "健康",
            answer2: "每天運動",
            answer3: "更健康",
            generatedPlanTitle: "測試計畫"
        )

        // Encode & Save
        if let data = try? JSONEncoder().encode(answers) {
            defaults.set(data, forKey: key)
        }

        // Read & Decode
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(OnboardingAnswers.self, from: data) {
            #expect(decoded.answer1 == "健康")
            #expect(decoded.answer2 == "每天運動")
            #expect(decoded.generatedPlanTitle == "測試計畫")
        } else {
            Issue.record("Failed to decode OnboardingAnswers")
        }
    }

    /// 測試 SubscriptionState 存取
    @Test("SubscriptionState 存取")
    func subscriptionStateStorage() {
        let defaults = UserDefaults(suiteName: testSuiteName)!
        defer { defaults.removePersistentDomain(forName: testSuiteName) }

        let key = "test_subscriptionState"
        let state = SubscriptionState(tier: .premium, activeChallengeCount: 5)

        // Encode & Save
        if let data = try? JSONEncoder().encode(state) {
            defaults.set(data, forKey: key)
        }

        // Read & Decode
        if let data = defaults.data(forKey: key),
           let decoded = try? JSONDecoder().decode(SubscriptionState.self, from: data) {
            #expect(decoded.tier == .premium)
            #expect(decoded.activeChallengeCount == 5)
            #expect(decoded.isPremium == true)
        } else {
            Issue.record("Failed to decode SubscriptionState")
        }
    }

    /// 測試 ThemeMode 存取
    @Test("ThemeMode 存取")
    func themeModeStorage() {
        let defaults = UserDefaults(suiteName: testSuiteName)!
        defer { defaults.removePersistentDomain(forName: testSuiteName) }

        let key = "test_themeMode"

        // 存 dark mode
        defaults.set(ThemeMode.dark.rawValue, forKey: key)

        let rawValue = defaults.integer(forKey: key)
        let mode = ThemeMode(rawValue: rawValue) ?? .system
        #expect(mode == .dark)
    }
}
