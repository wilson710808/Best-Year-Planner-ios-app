import Testing
import Foundation
@testable import Best_Year_Planner

// MARK: - Goal 模型測試
@Suite("Goal 模型測試")
struct GoalTests {

    // MARK: - GoalDimension
    @Test("GoalDimension displayName")
    func goalDimensionDisplayNames() {
        #expect(GoalDimension.career.displayName == "事業/財富")
        #expect(GoalDimension.relationship.displayName == "人際關係")
        #expect(GoalDimension.growth.displayName == "自我成長")
    }

    @Test("GoalDimension color hex")
    func goalDimensionColors() {
        #expect(GoalDimension.career.color == "3498DB")
        #expect(GoalDimension.relationship.color == "E74C8C")
        #expect(GoalDimension.growth.color == "27AE60")
    }

    @Test("GoalDimension icon")
    func goalDimensionIcons() {
        #expect(GoalDimension.career.icon == "briefcase.fill")
        #expect(GoalDimension.relationship.icon == "person.2.fill")
        #expect(GoalDimension.growth.icon == "leaf.fill")
    }

    @Test("GoalDimension CaseIterable 有3個")
    func goalDimensionCount() {
        #expect(GoalDimension.allCases.count == 3)
    }

    // MARK: - GoalLevel
    @Test("GoalLevel displayName")
    func goalLevelDisplayNames() {
        #expect(GoalLevel.sevenDayLaunch.displayName == "7天啟動")
        #expect(GoalLevel.twentyOneDayChallenge.displayName == "21天挑戰")
        #expect(GoalLevel.yearly.displayName == "年度")
    }

    // MARK: - Priority
    @Test("Priority sortOrder")
    func prioritySortOrder() {
        #expect(Priority.high.sortOrder < Priority.medium.sortOrder)
        #expect(Priority.medium.sortOrder < Priority.low.sortOrder)
    }

    @Test("Priority displayName")
    func priorityDisplayNames() {
        #expect(Priority.high.displayName == "高")
        #expect(Priority.medium.displayName == "中")
        #expect(Priority.low.displayName == "低")
    }

    // MARK: - GoalStatus
    @Test("GoalStatus displayName")
    func goalStatusDisplayNames() {
        #expect(GoalStatus.active.displayName == "進行中")
        #expect(GoalStatus.paused.displayName == "已暫停")
        #expect(GoalStatus.completed.displayName == "已完成")
        #expect(GoalStatus.cancelled.displayName == "已取消")
    }

    // MARK: - Goal
    @Test("Goal 預設值")
    func goalDefaults() {
        let goal = Goal(title: "測試目標")
        #expect(goal.dimension == .growth)
        #expect(goal.level == .yearly)
        #expect(goal.priority == .medium)
        #expect(goal.status == .active)
        #expect(goal.progress == 0.0)
        #expect(goal.parentGoalId == nil)
        #expect(goal.description == "")
    }

    @Test("Goal 自定義值")
    func goalCustomValues() {
        let goal = Goal(
            title: "學習Swift",
            description: "每天學1小時",
            dimension: .career,
            level: .sevenDayLaunch,
            priority: .high
        )
        #expect(goal.title == "學習Swift")
        #expect(goal.dimension == .career)
        #expect(goal.level == .sevenDayLaunch)
        #expect(goal.priority == .high)
    }

    @Test("Goal Equatable - 同 id 相等")
    func goalEquality() {
        let id = UUID().uuidString
        let goal1 = Goal(id: id, title: "A")
        let goal2 = Goal(id: id, title: "B")
        #expect(goal1 == goal2)
    }

    @Test("Goal Equatable - 不同 id 不相等")
    func goalInequality() {
        let goal1 = Goal(title: "A")
        let goal2 = Goal(title: "A")
        #expect(goal1 != goal2)
    }
}
