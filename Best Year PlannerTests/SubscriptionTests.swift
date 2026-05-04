import Testing
import Foundation
@testable import Best_Year_Planner

// MARK: - Subscription 模型測試
@Suite("Subscription 模型測試")
struct SubscriptionTests {

    @Test("免費用戶 isPremium 為 false")
    func freeIsNotPremium() {
        let state = SubscriptionState(tier: .free)
        #expect(state.isPremium == false)
    }

    @Test("高級用戶 isPremium 為 true")
    func premiumIsPremium() {
        let state = SubscriptionState(tier: .premium)
        #expect(state.isPremium == true)
    }

    @Test("免費用戶 - 未達上限可創建挑戰")
    func freeCanCreateUnderLimit() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 2)
        #expect(state.canCreateNewChallenge == true)
    }

    @Test("免費用戶 - 達上限不可創建挑戰")
    func freeCannotCreateAtLimit() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 3)
        #expect(state.canCreateNewChallenge == false)
    }

    @Test("免費用戶 - 超過上限不可創建")
    func freeCannotCreateOverLimit() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 5)
        #expect(state.canCreateNewChallenge == false)
    }

    @Test("高級用戶 - 無論多少挑戰都可創建")
    func premiumCanAlwaysCreate() {
        let state = SubscriptionState(tier: .premium, activeChallengeCount: 100)
        #expect(state.canCreateNewChallenge == true)
    }

    @Test("remainingFreeChallenges - 正常計算")
    func remainingFreeChallenges() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 1)
        #expect(state.remainingFreeChallenges == 2)
    }

    @Test("remainingFreeChallenges - 已達上限為0")
    func remainingFreeChallengesZero() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 3)
        #expect(state.remainingFreeChallenges == 0)
    }

    @Test("remainingFreeChallenges - 超過上限仍為0（不為負）")
    func remainingFreeChallengesNotNegative() {
        let state = SubscriptionState(tier: .free, activeChallengeCount: 5)
        #expect(state.remainingFreeChallenges == 0)
    }

    @Test("SubscriptionFeature 所有 case 都有標題和描述")
    func subscriptionFeatures() {
        for feature in SubscriptionFeature.allCases {
            #expect(!feature.title.isEmpty)
            #expect(!feature.description.isEmpty)
        }
        #expect(SubscriptionFeature.unlimitedChallenges.title == "無限挑戰")
    }
}
