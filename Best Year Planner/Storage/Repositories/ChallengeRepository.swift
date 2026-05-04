import Foundation
import SQLite3

/// Challenge Repository - 封裝挑戰相關的數據訪問邏輯
final class ChallengeRepository {
    static let shared = ChallengeRepository()
    
    private var db: OpaquePointer?
    
    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let dbPath = documentsPath.appendingPathComponent("bestyearplanner.sqlite3").path
        sqlite3_open(dbPath, &db)
    }
    
    deinit {
        sqlite3_close(db)
    }
    
    // MARK: - Challenge CRUD
    
    func save(_ challenge: Challenge) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO challenges (id, goal_id, phase, total_days, completed_days, start_date, is_unlocked, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }
        
        SQLiteHelper.bindString(statement, 1, challenge.id)
        SQLiteHelper.bindString(statement, 2, challenge.goalId)
        SQLiteHelper.bindEnum(statement, 3, challenge.phase)
        SQLiteHelper.bindInt(statement, 4, challenge.totalDays)
        SQLiteHelper.bindInt(statement, 5, challenge.completedDays)
        SQLiteHelper.bindDate(statement, 6, challenge.startDate)
        SQLiteHelper.bindBool(statement, 7, challenge.isUnlocked)
        SQLiteHelper.bindDate(statement, 8, challenge.createdAt)
        SQLiteHelper.bindDate(statement, 9, challenge.updatedAt)
        
        guard sqlite3_step(statement) == SQLITE_DONE else { return false }
        
        // Save daily tasks
        for task in challenge.dailyTasks {
            _ = saveTask(task)
        }
        
        return true
    }
    
    func get(byId id: String) -> Challenge? {
        let sql = "SELECT * FROM challenges WHERE id = ?;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }
        
        SQLiteHelper.bindString(statement, 1, id)
        
        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }
        
        return challengeFromStatement(statement)
    }
    
    func getAll() -> [Challenge] {
        let sql = "SELECT * FROM challenges ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var challenges: [Challenge] = []
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let challenge = challengeFromStatement(statement) {
                challenges.append(challenge)
            }
        }
        
        return challenges
    }
    
    func delete(byId id: String) -> Bool {
        let sql = "DELETE FROM challenges WHERE id = ?;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }
        
        SQLiteHelper.bindString(statement, 1, id)
        
        return sqlite3_step(statement) == SQLITE_DONE
    }
    
    // MARK: - Daily Task CRUD
    
    func saveTask(_ task: DailyChallengeTask) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO daily_challenge_tasks (id, challenge_id, day_number, title, description, estimated_minutes, is_completed, completed_at, ai_tip)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }
        
        SQLiteHelper.bindString(statement, 1, task.id)
        SQLiteHelper.bindString(statement, 2, task.challengeId)
        SQLiteHelper.bindInt(statement, 3, task.dayNumber)
        SQLiteHelper.bindString(statement, 4, task.title)
        SQLiteHelper.bindString(statement, 5, task.description)
        SQLiteHelper.bindInt(statement, 6, task.estimatedMinutes)
        SQLiteHelper.bindBool(statement, 7, task.isCompleted)
        SQLiteHelper.bindOptionalDate(statement, 8, task.completedAt)
        SQLiteHelper.bindOptionalString(statement, 9, task.aiTip)
        
        return sqlite3_step(statement) == SQLITE_DONE
    }
    
    func getTasks(forChallengeId challengeId: String) -> [DailyChallengeTask] {
        let sql = "SELECT * FROM daily_challenge_tasks WHERE challenge_id = ? ORDER BY day_number ASC;"
        var statement: OpaquePointer?
        var tasks: [DailyChallengeTask] = []
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }
        
        SQLiteHelper.bindString(statement, 1, challengeId)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            if let task = dailyTaskFromStatement(statement) {
                tasks.append(task)
            }
        }
        
        return tasks
    }
    
    func updateTaskCompletion(taskId: String, isCompleted: Bool) -> Bool {
        let sql = "UPDATE daily_challenge_tasks SET is_completed = ?, completed_at = ? WHERE id = ?;"
        var statement: OpaquePointer?
        
        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }
        
        SQLiteHelper.bindBool(statement, 1, isCompleted)
        SQLiteHelper.bindOptionalDate(statement, 2, isCompleted ? Date() : nil)
        SQLiteHelper.bindString(statement, 3, taskId)
        
        return sqlite3_step(statement) == SQLITE_DONE
    }
    
    // MARK: - Private Helpers
    
    private func challengeFromStatement(_ statement: OpaquePointer?) -> Challenge? {
        guard let statement = statement else { return nil }
        
        let id = SQLiteHelper.readString(statement, 0)
        let goalId = SQLiteHelper.readString(statement, 1)
        let phaseRaw = SQLiteHelper.readString(statement, 2)
        let totalDays = SQLiteHelper.readInt(statement, 3)
        let completedDays = SQLiteHelper.readInt(statement, 4)
        let startDate = SQLiteHelper.readDate(statement, 5)
        let isUnlocked = SQLiteHelper.readBool(statement, 6)
        let createdAt = SQLiteHelper.readDate(statement, 7)
        let updatedAt = SQLiteHelper.readDate(statement, 8)
        
        guard let phase = ChallengePhase(rawValue: phaseRaw) else { return nil }
        
        let dailyTasks = getTasks(forChallengeId: id)
        
        return Challenge(
            id: id,
            goalId: goalId,
            phase: phase,
            totalDays: totalDays,
            completedDays: completedDays,
            startDate: startDate,
            isUnlocked: isUnlocked,
            dailyTasks: dailyTasks,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    private func dailyTaskFromStatement(_ statement: OpaquePointer?) -> DailyChallengeTask? {
        guard let statement = statement else { return nil }
        
        return DailyChallengeTask(
            id: SQLiteHelper.readString(statement, 0),
            challengeId: SQLiteHelper.readString(statement, 1),
            dayNumber: SQLiteHelper.readInt(statement, 2),
            title: SQLiteHelper.readString(statement, 3),
            description: SQLiteHelper.readString(statement, 4),
            estimatedMinutes: SQLiteHelper.readInt(statement, 5),
            isCompleted: SQLiteHelper.readBool(statement, 6),
            completedAt: SQLiteHelper.readOptionalDate(statement, 7),
            aiTip: SQLiteHelper.readOptionalString(statement, 8)
        )
    }
}