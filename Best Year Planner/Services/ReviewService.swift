import Foundation

final class ReviewService: Sendable {
    static let shared = ReviewService()

    private let database = DatabaseManager.shared
    private let checkInService = CheckInService.shared
    private let taskService = TaskService.shared
    private let goalService = GoalService.shared
    
    // MARK: - Service Locator (Pluggable AI)
    private var aiProvider: any AIProvider {
        ServiceLocator.shared.aiProvider
    }

    private init() {}

    func createWeeklyReview() async -> Review {
        let now = Date()
        let period = now.weekYearString

        let existingReviews = database.getReviews(byType: .weekly)
        if let existing = existingReviews.first(where: { $0.period == period }) {
            return existing
        }

        let weeklySummary = checkInService.getWeeklySummary()
        let allTasks = taskService.getAllTasks()
        let pendingTasks = allTasks.filter { $0.status == .pending || $0.status == .inProgress }
        let completedTasks = allTasks.filter { $0.status == .completed }

        var achievements: [String] = []
        if weeklySummary.completionRate >= 0.7 {
            achievements.append("本週完成率達到 \(String(format: "%.0f", weeklySummary.completionRate * 100))%")
        }
        if weeklySummary.streakDays >= 3 {
            achievements.append("連續打卡 \(weeklySummary.streakDays) 天")
        }
        if !completedTasks.isEmpty {
            achievements.append("完成了 \(completedTasks.count) 個任務")
        }

        var improvements: [String] = []
        if weeklySummary.completionRate < 0.5 {
            improvements.append("需要提高任務完成率")
        }
        if pendingTasks.count > 10 {
            improvements.append("任務數量過多，需要精簡")
        }

        let data: [String: Any] = ["completionRate": weeklySummary.completionRate]
        let aiSuggestions = await aiProvider.generateAISuggestion(forType: .weekly, data: data)

        let review = Review(
            type: .weekly,
            period: period,
            summary: "本週完成率 \(String(format: "%.0f", weeklySummary.completionRate * 100))%，總打卡 \(weeklySummary.totalCheckIns) 次",
            achievements: achievements,
            improvements: improvements,
            nextWeekFocus: nil,
            aiSuggestions: aiSuggestions
        )

        _ = database.saveReview(review)
        return review
    }

    func createMonthlyReview() async -> Review {
        let now = Date()
        let period = now.monthYearString

        let existingReviews = database.getReviews(byType: .monthly)
        if let existing = existingReviews.first(where: { $0.period == period }) {
            return existing
        }

        let monthlyProgress = goalService.getOverallProgress()
        let allGoals = goalService.getAllGoals()
        let completedGoals = allGoals.filter { $0.status == .completed }.count
        let activeGoals = allGoals.filter { $0.status == .active }.count

        let allCheckIns = checkInService.getAllCheckIns()
        let monthlyCheckIns = allCheckIns.filter { $0.date.isThisMonth }
        let completedCheckIns = monthlyCheckIns.filter { $0.status == .completed }.count

        var achievements: [String] = []
        if completedGoals > 0 {
            achievements.append("本月完成了 \(completedGoals) 個目標")
        }
        if completedCheckIns > 0 {
            achievements.append("共打卡 \(completedCheckIns) 次")
        }

        var improvements: [String] = []
        if monthlyProgress < 0.5 {
            improvements.append("建議調整下月目標難度")
        }
        if activeGoals > 10 {
            improvements.append("目標數量較多，建議聚焦核心目標")
        }

        let data: [String: Any] = ["monthProgress": monthlyProgress]
        let aiSuggestions = await aiProvider.generateAISuggestion(forType: .monthly, data: data)

        let review = Review(
            type: .monthly,
            period: period,
            summary: "月度進度 \(String(format: "%.0f", monthlyProgress * 100))%，完成 \(completedGoals) 個目標",
            achievements: achievements,
            improvements: improvements,
            nextWeekFocus: nil,
            aiSuggestions: aiSuggestions
        )

        _ = database.saveReview(review)
        return review
    }

    func createYearlyReview() async -> Review {
        let year = Date().yearNumber
        let period = "\(year)"

        let existingReviews = database.getReviews(byType: .yearly)
        if let existing = existingReviews.first(where: { $0.period == period }) {
            return existing
        }

        let yearlyProgress = goalService.getOverallProgress()
        let allGoals = goalService.getAllGoals()
        let completedGoals = allGoals.filter { $0.status == .completed }.count
        let careerGoals = allGoals.filter { $0.dimension == .career }
        let relationshipGoals = allGoals.filter { $0.dimension == .relationship }
        let growthGoals = allGoals.filter { $0.dimension == .growth }

        let allCheckIns = checkInService.getAllCheckIns()
        let yearlyCheckIns = allCheckIns.filter { $0.date.isThisYear }
        let completedCheckIns = yearlyCheckIns.filter { $0.status == .completed }.count
        let longestStreak = yearlyCheckIns.map { $0.streakDay }.max() ?? 0

        var achievements: [String] = []
        achievements.append("年度目標完成率達到 \(String(format: "%.0f", yearlyProgress * 100))%")
        if completedGoals > 0 {
            achievements.append("共完成了 \(completedGoals) 個目標")
        }
        achievements.append("年度打卡總次數 \(completedCheckIns) 次")
        if longestStreak > 0 {
            achievements.append("最長連續打卡 \(longestStreak) 天")
        }

        var improvements: [String] = []
        if careerGoals.filter({ $0.status == .completed }).count == 0 {
            improvements.append("事業/財富維度目標需要加強")
        }
        if relationshipGoals.filter({ $0.status == .completed }).count == 0 {
            improvements.append("人際關係維度目標需要加強")
        }
        if growthGoals.filter({ $0.status == .completed }).count == 0 {
            improvements.append("自我成長維度目標需要加強")
        }

        let data: [String: Any] = [:]
        let aiSuggestions = await aiProvider.generateAISuggestion(forType: .yearly, data: data)

        let review = Review(
            type: .yearly,
            period: period,
            summary: "年度進度 \(String(format: "%.0f", yearlyProgress * 100))%，完成 \(completedGoals) 個目標",
            achievements: achievements,
            improvements: improvements,
            nextWeekFocus: nil,
            aiSuggestions: aiSuggestions
        )

        _ = database.saveReview(review)
        return review
    }

    func getWeeklyReviews() -> [Review] {
        return database.getReviews(byType: .weekly)
    }

    func getMonthlyReviews() -> [Review] {
        return database.getReviews(byType: .monthly)
    }

    func getYearlyReviews() -> [Review] {
        return database.getReviews(byType: .yearly)
    }

    func getLatestReview(byType type: ReviewType) -> Review? {
        return database.getReviews(byType: type).first
    }
}