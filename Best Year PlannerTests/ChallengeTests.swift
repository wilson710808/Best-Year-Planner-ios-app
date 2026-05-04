import Testing
import Foundation
@testable import Best_Year_Planner

// MARK: - Challenge 模型測試
@Suite("Challenge 模型測試")
struct ChallengeTests {

    @Test("Challenge 進度計算 - 已完成0天")
    func progressZero() {
        let challenge = Challenge(goalId: "test", totalDays: 7, completedDays: 0)
        #expect(challenge.progress == 0.0)
    }

    @Test("Challenge 進度計算 - 完成3/7天")
    func progressPartial() {
        let challenge = Challenge(goalId: "test", totalDays: 7, completedDays: 3)
        #expect(abs(challenge.progress - 3.0/7.0) < 0.001)
    }

    @Test("Challenge 進度計算 - 全部完成")
    func progressComplete() {
        let challenge = Challenge(goalId: "test", totalDays: 7, completedDays: 7)
        #expect(challenge.progress == 1.0)
    }

    @Test("Challenge 進度計算 - totalDays為0時回傳0")
    func progressZeroTotal() {
        let challenge = Challenge(goalId: "test", totalDays: 0, completedDays: 0)
        #expect(challenge.progress == 0.0)
    }

    @Test("Challenge isCompleted - 已完成天數 >= 總天數")
    func isCompletedTrue() {
        let challenge = Challenge(goalId: "test", totalDays: 7, completedDays: 7)
        #expect(challenge.isCompleted == true)
    }

    @Test("Challenge isCompleted - 未完成")
    func isCompletedFalse() {
        let challenge = Challenge(goalId: "test", totalDays: 7, completedDays: 5)
        #expect(challenge.isCompleted == false)
    }

    @Test("ChallengePhase 所有 case 都有 displayName")
    func challengePhaseDisplayNames() {
        for phase in ChallengePhase.allCases {
            #expect(!phase.displayName.isEmpty)
        }
        #expect(ChallengePhase.sevenDayLaunch.displayName == "7天啟動")
        #expect(ChallengePhase.twentyOneDayChallenge.displayName == "21天挑戰")
        #expect(ChallengePhase.completed.displayName == "已完成")
    }

    @Test("DailyChallengeTask 預設值")
    func dailyTaskDefaults() {
        let task = DailyChallengeTask(challengeId: "c1", dayNumber: 1, title: "測試", description: "描述")
        #expect(task.isCompleted == false)
        #expect(task.completedAt == nil)
        #expect(task.aiTip == nil)
        #expect(task.estimatedMinutes == 5)
    }

    @Test("ChallengeProgress 進度計算")
    func challengeProgressCalculation() {
        let progress = ChallengeProgress(totalDays: 21, completedDays: 7)
        #expect(abs(progress.progress - 1.0/3.0) < 0.001)
        #expect(progress.isCompleted == false)
    }

    @Test("ChallengeProgress isCompleted")
    func challengeProgressCompleted() {
        let progress = ChallengeProgress(totalDays: 21, completedDays: 21)
        #expect(progress.isCompleted == true)
    }

    @Test("SevenDayLaunchPlan 包含7個任務")
    func sevenDayPlanTasks() {
        let tasks = (1...7).map { DailyChallengeTask(challengeId: "c1", dayNumber: $0, title: "第\($0)天", description: "") }
        let plan = SevenDayLaunchPlan(title: "測試計畫", tasks: tasks)
        #expect(plan.tasks.count == 7)
        #expect(plan.title == "測試計畫")
    }
}
