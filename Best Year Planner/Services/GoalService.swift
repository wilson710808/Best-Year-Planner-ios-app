import Foundation

final class GoalService {
    static let shared = GoalService()

    private let database = DatabaseManager.shared

    private init() {}

    func createGoal(_ goal: Goal) -> Result<Goal, GoalError> {
        if goal.title.isEmpty {
            return .failure(.invalidTitle)
        }

        if database.saveGoal(goal) {
            return .success(goal)
        } else {
            return .failure(.saveFailed)
        }
    }

    func updateGoal(_ goal: Goal) -> Result<Goal, GoalError> {
        var updatedGoal = goal
        updatedGoal.updatedAt = Date()

        if database.saveGoal(updatedGoal) {
            return .success(updatedGoal)
        } else {
            return .failure(.saveFailed)
        }
    }

    func deleteGoal(_ goalId: String) -> Result<Void, GoalError> {
        if database.deleteGoal(byId: goalId) {
            return .success(())
        } else {
            return .failure(.deleteFailed)
        }
    }

    func getGoal(byId id: String) -> Goal? {
        return database.getGoal(byId: id)
    }

    func getAllGoals() -> [Goal] {
        return database.getAllGoals()
    }

    func getGoals(byDimension dimension: GoalDimension) -> [Goal] {
        return database.getGoals(byDimension: dimension)
    }

    func getYearlyGoals() -> [Goal] {
        return database.getAllGoals().filter { $0.level == .yearly }
    }

    func getQuarterlyGoals() -> [Goal] {
        return database.getAllGoals().filter { $0.level == .quarterly }
    }

    func getMonthlyGoals() -> [Goal] {
        return database.getAllGoals().filter { $0.level == .monthly }
    }

    func getWeeklyGoals() -> [Goal] {
        return database.getAllGoals().filter { $0.level == .weekly }
    }

    func getDailyGoals() -> [Goal] {
        return database.getAllGoals().filter { $0.level == .daily }
    }

    func updateGoalProgress(_ goalId: String, progress: Double) -> Result<Goal, GoalError> {
        guard var goal = database.getGoal(byId: goalId) else {
            return .failure(.notFound)
        }

        goal.progress = min(max(progress, 0), 1)
        goal.updatedAt = Date()

        if goal.progress >= 1.0 {
            goal.status = .completed
        }

        if database.saveGoal(goal) {
            return .success(goal)
        } else {
            return .failure(.saveFailed)
        }
    }

    func pauseGoal(_ goalId: String) -> Result<Goal, GoalError> {
        guard var goal = database.getGoal(byId: goalId) else {
            return .failure(.notFound)
        }

        goal.status = .paused
        goal.updatedAt = Date()

        if database.saveGoal(goal) {
            return .success(goal)
        } else {
            return .failure(.saveFailed)
        }
    }

    func resumeGoal(_ goalId: String) -> Result<Goal, GoalError> {
        guard var goal = database.getGoal(byId: goalId) else {
            return .failure(.notFound)
        }

        goal.status = .active
        goal.updatedAt = Date()

        if database.saveGoal(goal) {
            return .success(goal)
        } else {
            return .failure(.saveFailed)
        }
    }

    func getOverallProgress() -> Double {
        let activeGoals = database.getAllGoals().filter { $0.status == .active }
        guard !activeGoals.isEmpty else { return 0 }

        let totalProgress = activeGoals.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(activeGoals.count)
    }

    func getDimensionProgress(_ dimension: GoalDimension) -> Double {
        let dimensionGoals = database.getGoals(byDimension: dimension).filter { $0.status == .active }
        guard !dimensionGoals.isEmpty else { return 0 }

        let totalProgress = dimensionGoals.reduce(0.0) { $0 + $1.progress }
        return totalProgress / Double(dimensionGoals.count)
    }
}

enum GoalError: Error, LocalizedError {
    case invalidTitle
    case saveFailed
    case deleteFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "目標標題不能為空"
        case .saveFailed:
            return "保存目標失敗"
        case .deleteFailed:
            return "刪除目標失敗"
        case .notFound:
            return "目標不存在"
        }
    }
}
