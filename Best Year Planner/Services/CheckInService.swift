import Foundation

final class CheckInService {
    static let shared = CheckInService()

    private let database = DatabaseManager.shared
    private let taskService = TaskService.shared

    private init() {}

    func checkIn(taskId: String, status: CheckInStatus, note: String? = nil) -> Result<CheckIn, CheckInError> {
        let today = Date().startOfDay

        let existingCheckIns = database.getCheckIns(forTaskId: taskId)
        if existingCheckIns.first(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) != nil {
            return .failure(.alreadyCheckedInToday)
        }

        let checkIns = existingCheckIns.filter { $0.status == .completed }
        let lastCheckIn = checkIns.first
        let yesterday = today.adding(days: -1)

        var streakDay = 1
        if let lastDate = lastCheckIn?.date {
            if Calendar.current.isDate(lastDate, inSameDayAs: yesterday) {
                streakDay = (lastCheckIn?.streakDay ?? 0) + 1
            } else if Calendar.current.isDate(lastDate, inSameDayAs: today) {
                streakDay = lastCheckIn?.streakDay ?? 1
            }
        }

        let checkIn = CheckIn(
            taskId: taskId,
            date: today,
            status: status,
            note: note,
            streakDay: streakDay
        )

        if database.saveCheckIn(checkIn) {
            switch status {
            case .completed:
                _ = taskService.incrementCheckInCount(taskId)
                _ = taskService.updateTaskStreak(taskId, streak: streakDay)
            case .partial:
                _ = taskService.updateTaskStreak(taskId, streak: 0)
            case .missed:
                _ = taskService.resetStreak(taskId)
            }

            return .success(checkIn)
        } else {
            return .failure(.saveFailed)
        }
    }

    // MARK: - 補卡機制

    /// 補卡 — 需要填寫「為什麼錯過」的反思
    func makeUpCheckIn(taskId: String, originalDate: Date, reason: String, reflection: String) -> Result<CheckIn, CheckInError> {
        let checkIn = CheckIn(
            taskId: taskId,
            date: originalDate,
            status: .completed,
            note: "【補卡】原因：\(reason)。反思：\(reflection)",
            streakDay: 1 // 補卡不計入連續天數
        )
        if database.saveCheckIn(checkIn) {
            _ = taskService.incrementCheckInCount(taskId)
            // 保存補卡記錄
            let makeUp = MakeUpCheckIn(originalDate: originalDate, reason: reason, reflection: reflection)
            saveMakeUpCheckIn(makeUp)
            return .success(checkIn)
        } else {
            return .failure(.saveFailed)
        }
    }

    // MARK: - 批量打卡

    /// 批量打卡 — 一次確認多個任務
    func batchCheckIn(taskIds: [String]) -> [(taskId: String, result: Result<CheckIn, CheckInError>)] {
        return taskIds.map { id in
            (taskId: id, result: checkIn(taskId: id, status: .completed))
        }
    }

    // MARK: - 動機耗盡提醒

    /// 連續 N 天未打卡時，返回該任務的動機卡片
    func getMotivationReminder(taskId: String, inactiveDays: Int = 3) -> String? {
        let checkIns = database.getCheckIns(forTaskId: taskId)
        let recentDates = checkIns.filter { $0.status == .completed }.map { $0.date.startOfDay }
        let today = Date().startOfDay

        // 計算最近一次打卡距今天數
        if let lastDate = recentDates.max() {
            let daysSince = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if daysSince >= inactiveDays {
                // 查找動機卡片
                if let motivation = GoalEnhancementService.shared.getGoalMotivation(goalId: taskId) {
                    return motivation.aiMotivationCard
                }
            }
        }
        return nil
    }

    // MARK: - Private

    private func saveMakeUpCheckIn(_ makeUp: MakeUpCheckIn) {
        let key = "makeUpCheckIns_\(UserDefaultsManager.shared.currentUserId ?? "")"
        var items: [MakeUpCheckIn] = []
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MakeUpCheckIn].self, from: data) {
            items = decoded
        }
        items.append(makeUp)
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func updateCheckIn(_ checkIn: CheckIn) -> Result<CheckIn, CheckInError> {
        if database.saveCheckIn(checkIn) {
            return .success(checkIn)
        } else {
            return .failure(.saveFailed)
        }
    }

    func getCheckIns(forTaskId taskId: String) -> [CheckIn] {
        return database.getCheckIns(forTaskId: taskId)
    }

    func getCheckIns(forDate date: Date) -> [CheckIn] {
        return database.getCheckIns(forDate: date)
    }

    func getAllCheckIns() -> [CheckIn] {
        return database.getAllCheckIns()
    }

    func getTodayCheckIns() -> [CheckIn] {
        return database.getCheckIns(forDate: Date())
    }

    func getTotalCheckInCount() -> Int {
        return database.getAllCheckIns().filter { $0.status == .completed }.count
    }

    func getCurrentStreak(forTaskId taskId: String) -> Int {
        let checkIns = database.getCheckIns(forTaskId: taskId).filter { $0.status == .completed }
        guard let lastCheckIn = checkIns.first else { return 0 }

        let today = Date().startOfDay
        let yesterday = today.adding(days: -1)

        if !Calendar.current.isDate(lastCheckIn.date, inSameDayAs: today) &&
           !Calendar.current.isDate(lastCheckIn.date, inSameDayAs: yesterday) {
            return 0
        }

        return lastCheckIn.streakDay
    }

    func getLongestStreak(forTaskId taskId: String) -> Int {
        let checkIns = database.getCheckIns(forTaskId: taskId)
        return checkIns.map { $0.streakDay }.max() ?? 0
    }

    /// 獲取最近 N 天的打卡記錄
    func getRecentCheckIns(days: Int) -> [CheckIn] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        return getAllCheckIns().filter { $0.date >= startDate }
    }

    func getCompletionRate(forTaskId taskId: String, days: Int = 30) -> Double {
        let startDate = Date().adding(days: -days)
        let checkIns = database.getCheckIns(forTaskId: taskId)
            .filter { $0.date >= startDate }

        guard !checkIns.isEmpty else { return 0 }

        let completedCount = checkIns.filter { $0.status == .completed || $0.status == .partial }.count
        return Double(completedCount) / Double(checkIns.count)
    }

    func getDailySummary(forDate date: Date) -> DailyCheckInSummary {
        let checkIns = database.getCheckIns(forDate: date)
        let tasks = taskService.getTodaysTasks()

        let completedTasks = checkIns.filter { $0.status == .completed }.count
        let partialTasks = checkIns.filter { $0.status == .partial }.count
        let missedTasks = checkIns.filter { $0.status == .missed }.count

        return DailyCheckInSummary(
            date: date,
            totalTasks: tasks.count,
            completedTasks: completedTasks,
            partialTasks: partialTasks,
            missedTasks: missedTasks
        )
    }

    func getWeeklySummary() -> (completionRate: Double, totalCheckIns: Int, streakDays: Int) {
        let startOfWeek = Date().startOfWeek
        let endOfWeek = Date().endOfWeek
        let checkIns = database.getAllCheckIns()
            .filter { $0.date >= startOfWeek && $0.date <= endOfWeek }

        let totalCheckIns = checkIns.count
        let completedCheckIns = checkIns.filter { $0.status == .completed || $0.status == .partial }.count
        let completionRate = totalCheckIns > 0 ? Double(completedCheckIns) / Double(totalCheckIns) : 0

        let allTasks = taskService.getPendingTasks()
        var maxStreak = 0
        for task in allTasks {
            let streak = getCurrentStreak(forTaskId: task.id)
            if streak > maxStreak {
                maxStreak = streak
            }
        }

        return (completionRate, totalCheckIns, maxStreak)
    }

    func getMonthlyCompletionRates() -> [Double] {
        var rates: [Double] = []
        let calendar = Calendar.current

        for i in 0..<4 {
            guard let weekStart = calendar.date(byAdding: .weekOfYear, value: -i, to: Date().startOfWeek) else { continue }
            let weekEnd = weekStart.adding(days: 6)

            let weekCheckIns = database.getAllCheckIns()
                .filter { $0.date >= weekStart && $0.date <= weekEnd }

            let total = weekCheckIns.count
            let completed = weekCheckIns.filter { $0.status == .completed || $0.status == .partial }.count
            rates.append(total > 0 ? Double(completed) / Double(total) : 0)
        }

        return rates.reversed()
    }
}

enum CheckInError: Error, LocalizedError {
    case alreadyCheckedInToday
    case saveFailed
    case notFound

    var errorDescription: String? {
        switch self {
        case .alreadyCheckedInToday:
            return "今日已打卡"
        case .saveFailed:
            return "打卡失敗"
        case .notFound:
            return "打卡記錄不存在"
        }
    }
}
