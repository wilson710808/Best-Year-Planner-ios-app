import Foundation
import SQLite3

final class DatabaseManager {
    static let shared = DatabaseManager()

    private var db: OpaquePointer?
    private let dbPath: String

    private init() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        dbPath = documentsPath.appendingPathComponent("bestyearplanner.sqlite3").path
        openDatabase()
        createTables()
    }

    deinit {
        sqlite3_close(db)
    }

    private func openDatabase() {
        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("Error opening database")
        }
    }

    private func createTables() {
        createUsersTable()
        createGoalsTable()
        createTasksTable()
        createCheckInsTable()
        createConversationsTable()
        createReviewsTable()
        createCommunityTables()
        createChallengesTable()
        createDailyChallengeTasksTable()
    }

    private func createUsersTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS users (
                id TEXT PRIMARY KEY,
                account TEXT NOT NULL UNIQUE,
                password_hash TEXT NOT NULL,
                nickname TEXT NOT NULL,
                avatar_url TEXT,
                gender TEXT,
                birth_year INTEGER,
                created_at REAL NOT NULL,
                personality_tags TEXT,
                is_onboarding_completed INTEGER DEFAULT 0
            );
        """
        executeSQL(createTable)
    }

    private func createGoalsTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS goals (
                id TEXT PRIMARY KEY,
                title TEXT NOT NULL,
                description TEXT,
                dimension TEXT NOT NULL,
                level TEXT NOT NULL,
                parent_goal_id TEXT,
                priority TEXT NOT NULL,
                status TEXT NOT NULL,
                deadline REAL,
                progress REAL DEFAULT 0,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL,
                FOREIGN KEY (parent_goal_id) REFERENCES goals(id)
            );
        """
        executeSQL(createTable)
    }

    private func createTasksTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS tasks (
                id TEXT PRIMARY KEY,
                goal_id TEXT NOT NULL,
                title TEXT NOT NULL,
                description TEXT,
                check_in_count INTEGER DEFAULT 0,
                current_streak INTEGER DEFAULT 0,
                longest_streak INTEGER DEFAULT 0,
                priority TEXT NOT NULL,
                status TEXT NOT NULL,
                deadline REAL,
                reminder_time REAL,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL,
                FOREIGN KEY (goal_id) REFERENCES goals(id)
            );
        """
        executeSQL(createTable)
    }

    private func createCheckInsTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS check_ins (
                id TEXT PRIMARY KEY,
                task_id TEXT NOT NULL,
                date REAL NOT NULL,
                status TEXT NOT NULL,
                note TEXT,
                streak_day INTEGER DEFAULT 1,
                created_at REAL NOT NULL,
                FOREIGN KEY (task_id) REFERENCES tasks(id)
            );
        """
        executeSQL(createTable)
    }

    private func createConversationsTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS conversations (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                messages TEXT NOT NULL,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL
            );
        """
        executeSQL(createTable)
    }

    private func createReviewsTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS reviews (
                id TEXT PRIMARY KEY,
                type TEXT NOT NULL,
                period TEXT NOT NULL,
                summary TEXT,
                achievements TEXT,
                improvements TEXT,
                next_week_focus TEXT,
                ai_suggestions TEXT,
                created_at REAL NOT NULL
            );
        """
        executeSQL(createTable)
    }

    private func createCommunityTables() {
        let createGroupsTable = """
            CREATE TABLE IF NOT EXISTS community_groups (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                theme TEXT NOT NULL,
                group_description TEXT,
                member_ids TEXT,
                admin_id TEXT NOT NULL,
                created_at REAL NOT NULL,
                daily_check_in_goal INTEGER DEFAULT 1,
                is_active INTEGER DEFAULT 1
            );
        """
        executeSQL(createGroupsTable)

        let createPostsTable = """
            CREATE TABLE IF NOT EXISTS community_posts (
                id TEXT PRIMARY KEY,
                group_id TEXT NOT NULL,
                author_id TEXT NOT NULL,
                author_nickname TEXT NOT NULL,
                content TEXT NOT NULL,
                image_urls TEXT,
                likes TEXT,
                comments TEXT,
                created_at REAL NOT NULL,
                FOREIGN KEY (group_id) REFERENCES community_groups(id)
            );
        """
        executeSQL(createPostsTable)
    }

    private func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Error executing SQL: \(sql)")
            }
        }
        sqlite3_finalize(statement)
    }

    func saveUser(_ user: User) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO users (id, account, password_hash, nickname, avatar_url, gender, birth_year, created_at, personality_tags, is_onboarding_completed)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (user.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (user.account as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (user.passwordHash as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (user.nickname as NSString).utf8String, -1, nil)

        if let avatarURL = user.avatarURL {
            sqlite3_bind_text(statement, 5, (avatarURL as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 5)
        }

        if let gender = user.gender {
            sqlite3_bind_text(statement, 6, (gender.rawValue as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 6)
        }

        if let birthYear = user.birthYear {
            sqlite3_bind_int(statement, 7, Int32(birthYear))
        } else {
            sqlite3_bind_null(statement, 7)
        }

        sqlite3_bind_double(statement, 8, user.createdAt.timeIntervalSince1970)

        let tagsData = try? JSONEncoder().encode(user.personalityTags)
        let tagsString = tagsData.flatMap { String(data: $0, encoding: .utf8) }
        if let tags = tagsString {
            sqlite3_bind_text(statement, 9, (tags as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 9)
        }

        sqlite3_bind_int(statement, 10, user.isOnboardingCompleted ? 1 : 0)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func getUser(byId id: String) -> User? {
        let sql = "SELECT * FROM users WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        return userFromStatement(statement)
    }

    func getUser(byAccount account: String) -> User? {
        let sql = "SELECT * FROM users WHERE account = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (account as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        return userFromStatement(statement)
    }

    private func userFromStatement(_ statement: OpaquePointer?) -> User? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let account = String(cString: sqlite3_column_text(statement, 1))
        let passwordHash = String(cString: sqlite3_column_text(statement, 2))
        let nickname = String(cString: sqlite3_column_text(statement, 3))

        let avatarURL: String? = sqlite3_column_text(statement, 4).map { String(cString: $0) }

        let genderString: String? = sqlite3_column_text(statement, 5).map { String(cString: $0) }
        let gender = genderString.flatMap { Gender(rawValue: $0) }

        let birthYear: Int? = sqlite3_column_type(statement, 6) != SQLITE_NULL ? Int(sqlite3_column_int(statement, 6)) : nil

        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))

        let tagsString: String? = sqlite3_column_text(statement, 8).map { String(cString: $0) }
        let personalityTags = tagsString.flatMap { str in
            str.data(using: .utf8).flatMap { try? JSONDecoder().decode([String].self, from: $0) }
        } ?? []

        let isOnboardingCompleted = sqlite3_column_int(statement, 9) == 1

        return User(
            id: id,
            account: account,
            passwordHash: passwordHash,
            nickname: nickname,
            avatarURL: avatarURL,
            gender: gender,
            birthYear: birthYear,
            createdAt: createdAt,
            personalityTags: personalityTags,
            isOnboardingCompleted: isOnboardingCompleted
        )
    }

    func saveGoal(_ goal: Goal) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO goals (id, title, description, dimension, level, parent_goal_id, priority, status, deadline, progress, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (goal.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (goal.title as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (goal.description as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (goal.dimension.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (goal.level.rawValue as NSString).utf8String, -1, nil)

        if let parentGoalId = goal.parentGoalId {
            sqlite3_bind_text(statement, 6, (parentGoalId as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 6)
        }

        sqlite3_bind_text(statement, 7, (goal.priority.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 8, (goal.status.rawValue as NSString).utf8String, -1, nil)

        if let deadline = goal.deadline {
            sqlite3_bind_double(statement, 9, deadline.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(statement, 9)
        }

        sqlite3_bind_double(statement, 10, goal.progress)
        sqlite3_bind_double(statement, 11, goal.createdAt.timeIntervalSince1970)
        sqlite3_bind_double(statement, 12, goal.updatedAt.timeIntervalSince1970)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func getAllGoals() -> [Goal] {
        let sql = "SELECT * FROM goals ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var goals: [Goal] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        while sqlite3_step(statement) == SQLITE_ROW {
            if let goal = goalFromStatement(statement) {
                goals.append(goal)
            }
        }

        return goals
    }

    func getGoals(byDimension dimension: GoalDimension) -> [Goal] {
        let sql = "SELECT * FROM goals WHERE dimension = ? ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var goals: [Goal] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (dimension.rawValue as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let goal = goalFromStatement(statement) {
                goals.append(goal)
            }
        }

        return goals
    }

    func getGoal(byId id: String) -> Goal? {
        let sql = "SELECT * FROM goals WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        return goalFromStatement(statement)
    }

    private func goalFromStatement(_ statement: OpaquePointer?) -> Goal? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let title = String(cString: sqlite3_column_text(statement, 1))
        let description = String(cString: sqlite3_column_text(statement, 2))
        let dimensionRaw = String(cString: sqlite3_column_text(statement, 3))
        let levelRaw = String(cString: sqlite3_column_text(statement, 4))

        let parentGoalId: String? = sqlite3_column_text(statement, 5).map { String(cString: $0) }

        let priorityRaw = String(cString: sqlite3_column_text(statement, 6))
        let statusRaw = String(cString: sqlite3_column_text(statement, 7))

        let deadline: Date? = sqlite3_column_type(statement, 8) != SQLITE_NULL ?
            Date(timeIntervalSince1970: sqlite3_column_double(statement, 8)) : nil

        let progress = sqlite3_column_double(statement, 9)
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 10))
        let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 11))

        guard let dimension = GoalDimension(rawValue: dimensionRaw),
              let level = GoalLevel(rawValue: levelRaw),
              let priority = Priority(rawValue: priorityRaw),
              let status = GoalStatus(rawValue: statusRaw) else { return nil }

        return Goal(
            id: id,
            title: title,
            description: description,
            dimension: dimension,
            level: level,
            parentGoalId: parentGoalId,
            priority: priority,
            status: status,
            deadline: deadline,
            progress: progress,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func deleteGoal(byId id: String) -> Bool {
        let sql = "DELETE FROM goals WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func saveTask(_ task: Task) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO tasks (id, goal_id, title, description, check_in_count, current_streak, longest_streak, priority, status, deadline, reminder_time, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (task.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (task.goalId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (task.title as NSString).utf8String, -1, nil)

        if let description = task.description {
            sqlite3_bind_text(statement, 4, (description as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 4)
        }

        sqlite3_bind_int(statement, 5, Int32(task.checkInCount))
        sqlite3_bind_int(statement, 6, Int32(task.currentStreak))
        sqlite3_bind_int(statement, 7, Int32(task.longestStreak))
        sqlite3_bind_text(statement, 8, (task.priority.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 9, (task.status.rawValue as NSString).utf8String, -1, nil)

        if let deadline = task.deadline {
            sqlite3_bind_double(statement, 10, deadline.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(statement, 10)
        }

        if let reminderTime = task.reminderTime {
            sqlite3_bind_double(statement, 11, reminderTime.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(statement, 11)
        }

        sqlite3_bind_double(statement, 12, task.createdAt.timeIntervalSince1970)
        sqlite3_bind_double(statement, 13, task.updatedAt.timeIntervalSince1970)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func getTasks(byGoalId goalId: String) -> [Task] {
        let sql = "SELECT * FROM tasks WHERE goal_id = ? ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var tasks: [Task] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (goalId as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let task = taskFromStatement(statement) {
                tasks.append(task)
            }
        }

        return tasks
    }

    func getAllTasks() -> [Task] {
        let sql = "SELECT * FROM tasks ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var tasks: [Task] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        while sqlite3_step(statement) == SQLITE_ROW {
            if let task = taskFromStatement(statement) {
                tasks.append(task)
            }
        }

        return tasks
    }

    func getTask(byId id: String) -> Task? {
        let sql = "SELECT * FROM tasks WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        return taskFromStatement(statement)
    }

    private func taskFromStatement(_ statement: OpaquePointer?) -> Task? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let goalId = String(cString: sqlite3_column_text(statement, 1))
        let title = String(cString: sqlite3_column_text(statement, 2))
        let description: String? = sqlite3_column_text(statement, 3).map { String(cString: $0) }
        let checkInCount = Int(sqlite3_column_int(statement, 4))
        let currentStreak = Int(sqlite3_column_int(statement, 5))
        let longestStreak = Int(sqlite3_column_int(statement, 6))
        let priorityRaw = String(cString: sqlite3_column_text(statement, 7))
        let statusRaw = String(cString: sqlite3_column_text(statement, 8))

        let deadline: Date? = sqlite3_column_type(statement, 9) != SQLITE_NULL ?
            Date(timeIntervalSince1970: sqlite3_column_double(statement, 9)) : nil

        let reminderTime: Date? = sqlite3_column_type(statement, 10) != SQLITE_NULL ?
            Date(timeIntervalSince1970: sqlite3_column_double(statement, 10)) : nil

        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 11))
        let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 12))

        guard let priority = Priority(rawValue: priorityRaw),
              let status = TaskStatus(rawValue: statusRaw) else { return nil }

        return Task(
            id: id,
            goalId: goalId,
            title: title,
            description: description,
            checkInCount: checkInCount,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            priority: priority,
            status: status,
            deadline: deadline,
            reminderTime: reminderTime,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }

    func deleteTask(byId id: String) -> Bool {
        let sql = "DELETE FROM tasks WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func saveCheckIn(_ checkIn: CheckIn) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO check_ins (id, task_id, date, status, note, streak_day, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (checkIn.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (checkIn.taskId as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 3, checkIn.date.timeIntervalSince1970)
        sqlite3_bind_text(statement, 4, (checkIn.status.rawValue as NSString).utf8String, -1, nil)

        if let note = checkIn.note {
            sqlite3_bind_text(statement, 5, (note as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 5)
        }

        sqlite3_bind_int(statement, 6, Int32(checkIn.streakDay))
        sqlite3_bind_double(statement, 7, checkIn.createdAt.timeIntervalSince1970)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func getCheckIns(forTaskId taskId: String) -> [CheckIn] {
        let sql = "SELECT * FROM check_ins WHERE task_id = ? ORDER BY date DESC;"
        var statement: OpaquePointer?
        var checkIns: [CheckIn] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (taskId as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let checkIn = checkInFromStatement(statement) {
                checkIns.append(checkIn)
            }
        }

        return checkIns
    }

    func getCheckIns(forDate date: Date) -> [CheckIn] {
        let startOfDay = date.startOfDay.timeIntervalSince1970
        let endOfDay = date.endOfDay.timeIntervalSince1970

        let sql = "SELECT * FROM check_ins WHERE date >= ? AND date <= ? ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var checkIns: [CheckIn] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_double(statement, 1, startOfDay)
        sqlite3_bind_double(statement, 2, endOfDay)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let checkIn = checkInFromStatement(statement) {
                checkIns.append(checkIn)
            }
        }

        return checkIns
    }

    func getAllCheckIns() -> [CheckIn] {
        let sql = "SELECT * FROM check_ins ORDER BY date DESC;"
        var statement: OpaquePointer?
        var checkIns: [CheckIn] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        while sqlite3_step(statement) == SQLITE_ROW {
            if let checkIn = checkInFromStatement(statement) {
                checkIns.append(checkIn)
            }
        }

        return checkIns
    }

    private func checkInFromStatement(_ statement: OpaquePointer?) -> CheckIn? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let taskId = String(cString: sqlite3_column_text(statement, 1))
        let date = Date(timeIntervalSince1970: sqlite3_column_double(statement, 2))
        let statusRaw = String(cString: sqlite3_column_text(statement, 3))
        let note: String? = sqlite3_column_text(statement, 4).map { String(cString: $0) }
        let streakDay = Int(sqlite3_column_int(statement, 5))
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 6))

        guard let status = CheckInStatus(rawValue: statusRaw) else { return nil }

        return CheckIn(
            id: id,
            taskId: taskId,
            date: date,
            status: status,
            note: note,
            streakDay: streakDay,
            createdAt: createdAt
        )
    }

    func saveReview(_ review: Review) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO reviews (id, type, period, summary, achievements, improvements, next_week_focus, ai_suggestions, created_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (review.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (review.type.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (review.period as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 4, (review.summary as NSString).utf8String, -1, nil)

        let achievementsData = try? JSONEncoder().encode(review.achievements)
        let achievementsString = achievementsData.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        sqlite3_bind_text(statement, 5, (achievementsString as NSString).utf8String, -1, nil)

        let improvementsData = try? JSONEncoder().encode(review.improvements)
        let improvementsString = improvementsData.flatMap { String(data: $0, encoding: .utf8) } ?? "[]"
        sqlite3_bind_text(statement, 6, (improvementsString as NSString).utf8String, -1, nil)

        let nextWeekFocusData = review.nextWeekFocus.flatMap { try? JSONEncoder().encode($0) }
        let nextWeekFocusString = nextWeekFocusData.flatMap { String(data: $0, encoding: .utf8) }
        if let focus = nextWeekFocusString {
            sqlite3_bind_text(statement, 7, (focus as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 7)
        }

        sqlite3_bind_text(statement, 8, (review.aiSuggestions as NSString).utf8String, -1, nil)
        sqlite3_bind_double(statement, 9, review.createdAt.timeIntervalSince1970)

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func getReviews(byType type: ReviewType) -> [Review] {
        let sql = "SELECT * FROM reviews WHERE type = ? ORDER BY created_at DESC;"
        var statement: OpaquePointer?
        var reviews: [Review] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (type.rawValue as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let review = reviewFromStatement(statement) {
                reviews.append(review)
            }
        }

        return reviews
    }

    private func reviewFromStatement(_ statement: OpaquePointer?) -> Review? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let typeRaw = String(cString: sqlite3_column_text(statement, 1))
        let period = String(cString: sqlite3_column_text(statement, 2))
        let summary = String(cString: sqlite3_column_text(statement, 3))

        let achievementsString = String(cString: sqlite3_column_text(statement, 4))
        let achievements = (try? JSONDecoder().decode([String].self, from: achievementsString.data(using: .utf8)!)) ?? []

        let improvementsString = String(cString: sqlite3_column_text(statement, 5))
        let improvements = (try? JSONDecoder().decode([String].self, from: improvementsString.data(using: .utf8)!)) ?? []

        let nextWeekFocusString: String? = sqlite3_column_text(statement, 6).map { String(cString: $0) }
        let nextWeekFocus = nextWeekFocusString.flatMap { str in
            str.data(using: .utf8).flatMap { try? JSONDecoder().decode([String].self, from: $0) }
        }

        let aiSuggestions = String(cString: sqlite3_column_text(statement, 7))
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 8))

        guard let type = ReviewType(rawValue: typeRaw) else { return nil }

        return Review(
            id: id,
            type: type,
            period: period,
            summary: summary,
            achievements: achievements,
            improvements: improvements,
            nextWeekFocus: nextWeekFocus,
            aiSuggestions: aiSuggestions,
            createdAt: createdAt
        )
    }

    // MARK: - Challenges

    private func createChallengesTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS challenges (
                id TEXT PRIMARY KEY,
                goal_id TEXT NOT NULL,
                phase TEXT NOT NULL,
                total_days INTEGER NOT NULL,
                completed_days INTEGER DEFAULT 0,
                start_date REAL NOT NULL,
                is_unlocked INTEGER DEFAULT 0,
                created_at REAL NOT NULL,
                updated_at REAL NOT NULL,
                FOREIGN KEY (goal_id) REFERENCES goals(id)
            );
        """
        executeSQL(createTable)
    }

    private func createDailyChallengeTasksTable() {
        let createTable = """
            CREATE TABLE IF NOT EXISTS daily_challenge_tasks (
                id TEXT PRIMARY KEY,
                challenge_id TEXT NOT NULL,
                day_number INTEGER NOT NULL,
                title TEXT NOT NULL,
                description TEXT NOT NULL,
                estimated_minutes INTEGER DEFAULT 5,
                is_completed INTEGER DEFAULT 0,
                completed_at REAL,
                ai_tip TEXT,
                FOREIGN KEY (challenge_id) REFERENCES challenges(id)
            );
        """
        executeSQL(createTable)
    }

    func saveChallenge(_ challenge: Challenge) -> Bool {
        // Save challenge record
        let sql = """
            INSERT OR REPLACE INTO challenges (id, goal_id, phase, total_days, completed_days, start_date, is_unlocked, created_at, updated_at)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (challenge.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (challenge.goalId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 3, (challenge.phase.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 4, Int32(challenge.totalDays))
        sqlite3_bind_int(statement, 5, Int32(challenge.completedDays))
        sqlite3_bind_double(statement, 6, challenge.startDate.timeIntervalSince1970)
        sqlite3_bind_int(statement, 7, challenge.isUnlocked ? 1 : 0)
        sqlite3_bind_double(statement, 8, challenge.createdAt.timeIntervalSince1970)
        sqlite3_bind_double(statement, 9, challenge.updatedAt.timeIntervalSince1970)

        guard sqlite3_step(statement) == SQLITE_DONE else { return false }

        // Save daily tasks
        for task in challenge.dailyTasks {
            _ = saveDailyChallengeTask(task)
        }

        return true
    }

    func saveDailyChallengeTask(_ task: DailyChallengeTask) -> Bool {
        let sql = """
            INSERT OR REPLACE INTO daily_challenge_tasks (id, challenge_id, day_number, title, description, estimated_minutes, is_completed, completed_at, ai_tip)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (task.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 2, (task.challengeId as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 3, Int32(task.dayNumber))
        sqlite3_bind_text(statement, 4, (task.title as NSString).utf8String, -1, nil)
        sqlite3_bind_text(statement, 5, (task.description as NSString).utf8String, -1, nil)
        sqlite3_bind_int(statement, 6, Int32(task.estimatedMinutes))
        sqlite3_bind_int(statement, 7, task.isCompleted ? 1 : 0)

        if let completedAt = task.completedAt {
            sqlite3_bind_double(statement, 8, completedAt.timeIntervalSince1970)
        } else {
            sqlite3_bind_null(statement, 8)
        }

        if let tip = task.aiTip {
            sqlite3_bind_text(statement, 9, (tip as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(statement, 9)
        }

        return sqlite3_step(statement) == SQLITE_DONE
    }

    func getChallenge(byId id: String) -> Challenge? {
        let sql = "SELECT * FROM challenges WHERE id = ?;"
        var statement: OpaquePointer?

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (id as NSString).utf8String, -1, nil)

        guard sqlite3_step(statement) == SQLITE_ROW else { return nil }

        return challengeFromStatement(statement)
    }

    func getAllChallenges() -> [Challenge] {
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

    private func challengeFromStatement(_ statement: OpaquePointer?) -> Challenge? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let goalId = String(cString: sqlite3_column_text(statement, 1))
        let phaseRaw = String(cString: sqlite3_column_text(statement, 2))
        let totalDays = Int(sqlite3_column_int(statement, 3))
        let completedDays = Int(sqlite3_column_int(statement, 4))
        let startDate = Date(timeIntervalSince1970: sqlite3_column_double(statement, 5))
        let isUnlocked = sqlite3_column_int(statement, 6) == 1
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 7))
        let updatedAt = Date(timeIntervalSince1970: sqlite3_column_double(statement, 8))

        guard let phase = ChallengePhase(rawValue: phaseRaw) else { return nil }

        // Load daily tasks for this challenge
        let dailyTasks = getDailyChallengeTasks(forChallengeId: id)

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

    private func getDailyChallengeTasks(forChallengeId challengeId: String) -> [DailyChallengeTask] {
        let sql = "SELECT * FROM daily_challenge_tasks WHERE challenge_id = ? ORDER BY day_number ASC;"
        var statement: OpaquePointer?
        var tasks: [DailyChallengeTask] = []

        guard sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(statement) }

        sqlite3_bind_text(statement, 1, (challengeId as NSString).utf8String, -1, nil)

        while sqlite3_step(statement) == SQLITE_ROW {
            if let task = dailyChallengeTaskFromStatement(statement) {
                tasks.append(task)
            }
        }

        return tasks
    }

    private func dailyChallengeTaskFromStatement(_ statement: OpaquePointer?) -> DailyChallengeTask? {
        guard let statement = statement else { return nil }

        let id = String(cString: sqlite3_column_text(statement, 0))
        let challengeId = String(cString: sqlite3_column_text(statement, 1))
        let dayNumber = Int(sqlite3_column_int(statement, 2))
        let title = String(cString: sqlite3_column_text(statement, 3))
        let description = String(cString: sqlite3_column_text(statement, 4))
        let estimatedMinutes = Int(sqlite3_column_int(statement, 5))
        let isCompleted = sqlite3_column_int(statement, 6) == 1

        let completedAt: Date? = sqlite3_column_type(statement, 7) != SQLITE_NULL ?
            Date(timeIntervalSince1970: sqlite3_column_double(statement, 7)) : nil

        let aiTip: String? = sqlite3_column_text(statement, 8).map { String(cString: $0) }

        return DailyChallengeTask(
            id: id,
            challengeId: challengeId,
            dayNumber: dayNumber,
            title: title,
            description: description,
            estimatedMinutes: estimatedMinutes,
            isCompleted: isCompleted,
            completedAt: completedAt,
            aiTip: aiTip
        )
    }
}
