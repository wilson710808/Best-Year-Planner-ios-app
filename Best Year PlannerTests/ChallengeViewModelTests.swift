import Testing
import Foundation
@testable import Best_Year_Planner

// MARK: - AppConstants 測試
@Suite("AppConstants 測試")
struct AppConstantsTests {

    @Test("挑戰常量正確")
    func challengeConstants() {
        #expect(AppConstants.Challenge.launchDays == 7)
        #expect(AppConstants.Challenge.challengeDays == 21)
        #expect(AppConstants.Challenge.maxFreeChallenges == 3)
        #expect(AppConstants.Challenge.defaultTaskMinutes == 5)
    }

    @Test("AI Gateway 配置正確")
    func aiGatewayConfig() {
        #expect(AppConstants.AI.gatewayBaseURL == "https://www.herelai.fun")
        #expect(AppConstants.AI.gatewayEndpoint == "/ws/05-ai-gateway/api/query")
        #expect(AppConstants.AI.appId == "bestyearplanner")
    }

    @Test("Bundle ID 正確")
    func bundleId() {
        #expect(AppConstants.bundleId == "com.bestyear.planner")
    }

    @Test("UserDefaultsKeys 不為空")
    func userDefaultsKeys() {
        #expect(!AppConstants.UserDefaultsKeys.isOnboardingCompleted.isEmpty)
        #expect(!AppConstants.UserDefaultsKeys.subscriptionTier.isEmpty)
        #expect(!AppConstants.UserDefaultsKeys.onboardingAnswers.isEmpty)
    }
}

// MARK: - ChallengeViewModel 測試
@Suite("ChallengeViewModel 測試")
struct ChallengeViewModelTests {

    @Test("免費用戶達上限不可開始21天挑戰")
    func freeCannotStartChallenge() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 3)
        #expect(state.canCreateNewChallenge == false)
    }

    @Test("免費用戶未達上限可開始21天挑戰")
    func freeCanStartChallenge() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 2)
        #expect(state.canCreateNewChallenge == true)
    }

    @Test("高級用戶可開始21天挑戰")
    func premiumCanStartChallenge() {
        let state = SubscriptionState(tier: .premium, activeChallengeCount: 10)
        #expect(state.canCreateNewChallenge == true)
    }

    @Test("21天挑戰進度計算")
    func twentyOneDayProgress() {
        let challenge = Challenge(goalId: "g1", phase: .twentyOneDayChallenge, totalDays: 21, completedDays: 14)
        #expect(abs(challenge.progress - 14.0/21.0) < 0.001)
        #expect(challenge.isCompleted == false)
    }

    @Test("7天挑戰完成後 isCompleted")
    func sevenDayChallengeCompleted() {
        let challenge = Challenge(goalId: "g1", phase: .sevenDayLaunch, totalDays: 7, completedDays: 7)
        #expect(challenge.isCompleted == true)
        #expect(challenge.progress == 1.0)
    }
}
