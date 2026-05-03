import Foundation
import Combine

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var overallProgress: Double = 0
    @Published var careerProgress: Double = 0
    @Published var relationshipProgress: Double = 0
    @Published var growthProgress: Double = 0

    @Published var weeklyCompletionRate: Double = 0
    @Published var weeklyTotalCheckIns: Int = 0
    @Published var weeklyStreakDays: Int = 0

    @Published var todayTasks: [Task] = []
    @Published var pendingTasks: [Task] = []
    @Published var todayCheckIns: [CheckIn] = []

    @Published var totalCheckInCount: Int = 0
    @Published var longestStreak: Int = 0

    private let goalService = GoalService.shared
    private let taskService = TaskService.shared
    private let checkInService = CheckInService.shared

    func loadDashboardData() {
        overallProgress = goalService.getOverallProgress()
        careerProgress = goalService.getDimensionProgress(.career)
        relationshipProgress = goalService.getDimensionProgress(.relationship)
        growthProgress = goalService.getDimensionProgress(.growth)

        let weeklySummary = checkInService.getWeeklySummary()
        weeklyCompletionRate = weeklySummary.completionRate
        weeklyTotalCheckIns = weeklySummary.totalCheckIns
        weeklyStreakDays = weeklySummary.streakDays

        todayTasks = taskService.getTodaysTasks()
        pendingTasks = taskService.getPendingTasks()
        todayCheckIns = checkInService.getTodayCheckIns()

        totalCheckInCount = checkInService.getTotalCheckInCount()

        var maxStreak = 0
        for task in todayTasks {
            let streak = checkInService.getCurrentStreak(forTaskId: task.id)
            if streak > maxStreak {
                maxStreak = streak
            }
        }
        longestStreak = maxStreak
    }

    func getCompletedTasksToday() -> Int {
        todayCheckIns.filter { $0.status == .completed }.count
    }

    func getPartialTasksToday() -> Int {
        todayCheckIns.filter { $0.status == .partial }.count
    }

    func getMissedTasksToday() -> Int {
        let completedTaskIds = Set(todayCheckIns.map { $0.taskId })
        return todayTasks.filter { !completedTaskIds.contains($0.id) && $0.status != .completed }.count
    }

    func getTodayCompletionRate() -> Double {
        guard !todayTasks.isEmpty else { return 0 }
        let completed = getCompletedTasksToday()
        let partial = getPartialTasksToday()
        return Double(completed + partial * 50) / Double(todayTasks.count * 100)
    }

    func getWeeklyCompletionRates() -> [Double] {
        checkInService.getMonthlyCompletionRates()
    }
}
