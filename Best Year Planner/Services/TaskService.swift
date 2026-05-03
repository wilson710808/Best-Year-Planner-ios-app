import Foundation

final class TaskService {
    static let shared = TaskService()

    private let database = DatabaseManager.shared
    private let goalService = GoalService.shared

    private init() {}

    func createTask(_ task: Task) -> Result<Task, TaskError> {
        if task.title.isEmpty {
            return .failure(.invalidTitle)
        }

        if database.saveTask(task) {
            return .success(task)
        } else {
            return .failure(.saveFailed)
        }
    }

    func updateTask(_ task: Task) -> Result<Task, TaskError> {
        var updatedTask = task
        updatedTask.updatedAt = Date()

        if database.saveTask(updatedTask) {
            return .success(updatedTask)
        } else {
            return .failure(.saveFailed)
        }
    }

    func deleteTask(_ taskId: String) -> Result<Void, TaskError> {
        if database.deleteTask(byId: taskId) {
            return .success(())
        } else {
            return .failure(.deleteFailed)
        }
    }

    func getTask(byId id: String) -> Task? {
        return database.getTask(byId: id)
    }

    func getTasks(forGoalId goalId: String) -> [Task] {
        return database.getTasks(byGoalId: goalId)
    }

    func getAllTasks() -> [Task] {
        return database.getAllTasks()
    }

    func getTodaysTasks() -> [Task] {
        let allTasks = database.getAllTasks()
        return allTasks.filter { task in
            guard task.status != .completed && task.status != .cancelled else { return false }
            if let deadline = task.deadline {
                return deadline.isToday || deadline >= Date().startOfDay
            }
            return true
        }
    }

    func getPendingTasks() -> [Task] {
        return database.getAllTasks().filter { $0.status == .pending || $0.status == .inProgress }
    }

    func updateTaskStreak(_ taskId: String, streak: Int) -> Result<Task, TaskError> {
        guard var task = database.getTask(byId: taskId) else {
            return .failure(.notFound)
        }

        task.currentStreak = streak
        if streak > task.longestStreak {
            task.longestStreak = streak
        }
        task.updatedAt = Date()

        if database.saveTask(task) {
            return .success(task)
        } else {
            return .failure(.saveFailed)
        }
    }

    func incrementCheckInCount(_ taskId: String) -> Result<Task, TaskError> {
        guard var task = database.getTask(byId: taskId) else {
            return .failure(.notFound)
        }

        task.checkInCount += 1
        task.updatedAt = Date()

        if database.saveTask(task) {
            return .success(task)
        } else {
            return .failure(.saveFailed)
        }
    }

    func completeTask(_ taskId: String) -> Result<Task, TaskError> {
        guard var task = database.getTask(byId: taskId) else {
            return .failure(.notFound)
        }

        task.status = .completed
        task.updatedAt = Date()

        if database.saveTask(task) {
            if let goalId = task.goalId as String? {
                _ = goalService.getGoal(byId: goalId).map { goal in
                    let tasks = getTasks(forGoalId: goalId)
                    let completedTasks = tasks.filter { $0.status == .completed }.count
                    let progress = tasks.isEmpty ? 0 : Double(completedTasks) / Double(tasks.count)
                    _ = goalService.updateGoalProgress(goalId, progress: progress)
                }
            }
            return .success(task)
        } else {
            return .failure(.saveFailed)
        }
    }

    func resetStreak(_ taskId: String) -> Result<Task, TaskError> {
        guard var task = database.getTask(byId: taskId) else {
            return .failure(.notFound)
        }

        task.currentStreak = 0
        task.updatedAt = Date()

        if database.saveTask(task) {
            return .success(task)
        } else {
            return .failure(.saveFailed)
        }
    }
}

enum TaskError: Error, LocalizedError {
    case invalidTitle
    case saveFailed
    case deleteFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .invalidTitle:
            return "任務標題不能為空"
        case .saveFailed:
            return "保存任務失敗"
        case .deleteFailed:
            return "刪除任務失敗"
        case .notFound:
            return "任務不存在"
        }
    }
}
