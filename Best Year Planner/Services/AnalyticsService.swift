import Foundation

/// 進階數據分析服務 — 維度趨勢、目標完成率時間線、習慣養成曲線
final class AnalyticsService {
    static let shared = AnalyticsService()
    private let database = DatabaseManager.shared
    private init() {}

    // MARK: - 維度趨勢數據

    struct DimensionTrend: Codable, Identifiable {
        var id: String { "\(dimension.rawValue)_\(weekIndex)" }
        var dimension: GoalDimension
        var weekIndex: Int      // 第幾週（從年初起算）
        var completionRate: Double
        var checkInCount: Int
    }

    func getDimensionTrends(year: Int? = nil) -> [DimensionTrend] {
        let calendar = Calendar.current
        let year = year ?? calendar.component(.year, from: Date())
        let goals = GoalService.shared.getAllGoals()
        let checkIns = CheckInService.shared.getAllCheckIns()

        var trends: [DimensionTrend] = []
        for dimension in GoalDimension.allCases {
            let dimGoals = goals.filter { $0.dimension == dimension }
            let dimGoalIds = Set(dimGoals.map { $0.id })
            let dimCheckIns = checkIns.filter { ci in
                if let taskId = ci.taskId as String?, !taskId.isEmpty {
                    let task = TaskService.shared.getTask(byId: taskId)
                    return dimGoalIds.contains(task?.goalId ?? "")
                }
                return false
            }

            // 按週分組
            var weekData: [Int: (count: Int, total: Int)] = [:]
            for checkIn in dimCheckIns {
                let weekOfYear = calendar.component(.weekOfYear, from: checkIn.date)
                weekData[weekOfYear, default: (0, 0)].total += 1
                if checkIn.status == .completed {
                    weekData[weekOfYear, default: (0, 0)].count += 1
                }
            }

            for (weekIndex, data) in weekData.sorted(by: { $0.key < $1.key }) {
                let rate = data.total > 0 ? Double(data.count) / Double(data.total) : 0
                trends.append(DimensionTrend(
                    dimension: dimension,
                    weekIndex: weekIndex,
                    completionRate: rate,
                    checkInCount: data.count
                ))
            }
        }
        return trends
    }

    // MARK: - 目標完成率時間線

    struct GoalCompletionTimeline: Codable, Identifiable {
        var id: String { goalId }
        var goalId: String
        var goalTitle: String
        var dimension: GoalDimension
        var createdAt: Date
        var completedAt: Date?     // 使用 updatedAt 當 status == .completed
        var completionDays: Int?
        var taskCompletionRate: Double
    }

    func getGoalCompletionTimeline() -> [GoalCompletionTimeline] {
        let goals = GoalService.shared.getAllGoals()
        let allTasks = TaskService.shared.getAllTasks()

        return goals.map { goal in
            let goalTasks = allTasks.filter { $0.goalId == goal.id }
            let completedTasks = goalTasks.filter { $0.status == .completed }
            let rate = goalTasks.isEmpty ? 0 : Double(completedTasks.count) / Double(goalTasks.count)

            let completedAt: Date? = goal.status == .completed ? goal.updatedAt : nil
            let completionDays: Int? = {
                guard let completed = completedAt else { return nil }
                let days = Calendar.current.dateComponents([.day], from: goal.createdAt, to: completed).day
                return days
            }()

            return GoalCompletionTimeline(
                goalId: goal.id,
                goalTitle: goal.title,
                dimension: goal.dimension,
                createdAt: goal.createdAt,
                completedAt: completedAt,
                completionDays: completionDays,
                taskCompletionRate: rate
            )
        }
        .sorted { $0.createdAt > $1.createdAt }
    }

    // MARK: - 習慣養成曲線（打卡連續性分析）

    struct HabitCurve: Codable, Identifiable {
        var id: String { taskId }
        var taskId: String
        var taskTitle: String
        var goalId: String
        var totalCheckIns: Int
        var longestStreak: Int
        var currentStreak: Int
        var weeklyPattern: [Int: Int]  // weekday(1-7) → 打卡次數
        var consistency30Day: Double   // 近30天打卡率
    }

    func getHabitCurves() -> [HabitCurve] {
        let tasks = TaskService.shared.getAllTasks()
        let checkIns = CheckInService.shared.getAllCheckIns()
        let calendar = Calendar.current

        return tasks.filter { $0.status == .inProgress || $0.status == .completed }.map { task in
            let taskCheckIns = checkIns.filter { $0.taskId == task.id }
            let completed = taskCheckIns.filter { $0.status == .completed }

            // 週幾分佈
            var weeklyPattern: [Int: Int] = [:]
            for ci in completed {
                let weekday = calendar.component(.weekday, from: ci.date)
                weeklyPattern[weekday, default: 0] += 1
            }

            // 近30天打卡率
            let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            let recentCheckIns = completed.filter { $0.date >= thirtyDaysAgo }
            let consistency30Day = 30.0 > 0 ? Double(recentCheckIns.count) / 30.0 : 0

            return HabitCurve(
                taskId: task.id,
                taskTitle: task.title,
                goalId: task.goalId,
                totalCheckIns: completed.count,
                longestStreak: task.currentStreak,  // 簡化：實際應從 check_ins 計算
                currentStreak: task.currentStreak,
                weeklyPattern: weeklyPattern,
                consistency30Day: min(consistency30Day, 1.0)
            )
        }
        .sorted { $0.totalCheckIns > $1.totalCheckIns }
    }

    // MARK: - 總覽統計

    struct OverviewStats: Codable {
        var totalGoals: Int
        var completedGoals: Int
        var totalTasks: Int
        var completedTasks: Int
        var totalCheckIns: Int
        var averageStreak: Double
        var bestDimension: GoalDimension?
        var completionRateByDimension: [String: Double]
    }

    func getOverviewStats() -> OverviewStats {
        let goals = GoalService.shared.getAllGoals()
        let tasks = TaskService.shared.getAllTasks()
        let checkIns = CheckInService.shared.getAllCheckIns()

        let completedGoals = goals.filter { $0.status == .completed }
        let completedTasks = tasks.filter { $0.status == .completed }
        let completedCheckIns = checkIns.filter { $0.status == .completed }

        // 按維度計算完成率
        var rateByDimension: [String: Double] = [:]
        var bestDim: GoalDimension?
        var bestRate: Double = 0

        for dim in GoalDimension.allCases {
            let dimGoals = goals.filter { $0.dimension == dim }
            let dimCompleted = dimGoals.filter { $0.status == .completed }
            let rate = dimGoals.isEmpty ? 0 : Double(dimCompleted.count) / Double(dimGoals.count)
            rateByDimension[dim.rawValue] = rate
            if rate > bestRate {
                bestRate = rate
                bestDim = dim
            }
        }

        let streaks = tasks.map { $0.currentStreak }
        let avgStreak = streaks.isEmpty ? 0 : Double(streaks.reduce(0, +)) / Double(streaks.count)

        return OverviewStats(
            totalGoals: goals.count,
            completedGoals: completedGoals.count,
            totalTasks: tasks.count,
            completedTasks: completedTasks.count,
            totalCheckIns: completedCheckIns.count,
            averageStreak: avgStreak,
            bestDimension: bestDim,
            completionRateByDimension: rateByDimension
        )
    }
}
