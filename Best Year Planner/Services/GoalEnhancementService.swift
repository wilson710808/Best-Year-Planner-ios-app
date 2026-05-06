import Foundation
import os.log

/// 目標增強服務 — 「總結過去」+「找到為什麼」+ SMARTER評分 + 領先/滯後指標 + 取捨工具
@MainActor
final class GoalEnhancementService {
    static let shared = GoalEnhancementService()
    private let database = DatabaseManager.shared
    private let logger = AppLogger.log

    private init() {}

    // MARK: - 限制性信念

    func getCommonLimitingBeliefs() -> [LimitingBelief] {
        let common = [
            "我做不到 — 因為我以前試過都失敗",
            "我沒時間 — 因為太忙了",
            "我不夠好 — 因為別人比我強",
            "太難了 — 因為這超出我的能力",
            "這沒用 — 因為試了也不會改變",
            "我總是放棄 — 因為我缺乏毅力",
            "我不配擁有好的結果 — 因為我不夠努力",
            "現在開始太晚了 — 因為別人早就起步了",
            "我需要完美準備 — 否則不值得開始",
            "如果失敗了 — 別人會看不起我"
        ]
        return common.map { LimitingBelief(text: $0) }
    }

    func saveLimitingBeliefs(_ beliefs: [LimitingBelief], userId: String) -> Bool {
        let data = (try? JSONEncoder().encode(beliefs)) ?? Data()
        return database.saveOnboardingData(userId: userId, key: "limiting_beliefs", data: data)
    }

    func loadLimitingBeliefs(userId: String) -> [LimitingBelief] {
        guard let data = database.loadOnboardingData(userId: userId, key: "limiting_beliefs"),
              let beliefs = try? JSONDecoder().decode([LimitingBelief].self, from: data) else { return [] }
        return beliefs
    }

    // MARK: - 年度回顧（「總結過去」步驟）

    func saveYearlyReview(_ review: YearlyReview) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO yearly_reviews (id, year, top_achievements, regrets, lessons_learned, ai_report, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (review.id as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 2, Int32(review.year))

        if let data = try? JSONEncoder().encode(review.topAchievements),
           let str = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 3, (str as NSString).utf8String, -1, nil)
        }
        if let data = try? JSONEncoder().encode(review.regrets),
           let str = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 4, (str as NSString).utf8String, -1, nil)
        }
        if let data = try? JSONEncoder().encode(review.lessonsLearned),
           let str = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 5, (str as NSString).utf8String, -1, nil)
        }
        if let report = review.aiExperienceReport {
            sqlite3_bind_text(stmt, 6, (report as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 6)
        }
        sqlite3_bind_double(stmt, 7, review.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getYearlyReview(year: Int) -> YearlyReview? {
        let sql = "SELECT * FROM yearly_reviews WHERE year = ? ORDER BY created_at DESC LIMIT 1"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_int(stmt, 1, Int32(year))

        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return yearlyReviewFromStatement(stmt)
    }

    // MARK: - 目標動機（「找到為什麼」）

    func saveGoalMotivation(_ motivation: GoalMotivation) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO goal_motivations (id, goal_id, whys, ai_motivation_card, created_at)
        VALUES (?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (motivation.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (motivation.goalId as NSString).utf8String, -1, nil)

        if let data = try? JSONEncoder().encode(motivation.whys),
           let str = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 3, (str as NSString).utf8String, -1, nil)
        }
        if let card = motivation.aiMotivationCard {
            sqlite3_bind_text(stmt, 4, (card as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 4)
        }
        sqlite3_bind_double(stmt, 5, motivation.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getGoalMotivation(goalId: String) -> GoalMotivation? {
        let sql = "SELECT * FROM goal_motivations WHERE goal_id = ? ORDER BY created_at DESC LIMIT 1"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (goalId as NSString).utf8String, -1, nil)

        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return goalMotivationFromStatement(stmt)
    }

    // MARK: - SMARTER 評分

    func saveSMARTERScore(_ score: SMARTERScore) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO smarter_scores (id, goal_id, specific, measurable, actionable, risky, time_keyed, exciting, relevant, ai_suggestions, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (score.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (score.goalId as NSString).utf8String, -1, nil)
        sqlite3_bind_int(stmt, 3, Int32(score.specific))
        sqlite3_bind_int(stmt, 4, Int32(score.measurable))
        sqlite3_bind_int(stmt, 5, Int32(score.actionable))
        sqlite3_bind_int(stmt, 6, Int32(score.risky))
        sqlite3_bind_int(stmt, 7, Int32(score.timeKeyed))
        sqlite3_bind_int(stmt, 8, Int32(score.exciting))
        sqlite3_bind_int(stmt, 9, Int32(score.relevant))

        if let data = try? JSONEncoder().encode(score.aiSuggestions ?? []),
           let str = String(data: data, encoding: .utf8) {
            sqlite3_bind_text(stmt, 10, (str as NSString).utf8String, -1, nil)
        } else {
            sqlite3_bind_null(stmt, 10)
        }
        sqlite3_bind_double(stmt, 11, score.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getSMARTERScore(goalId: String) -> SMARTERScore? {
        let sql = "SELECT * FROM smarter_scores WHERE goal_id = ? ORDER BY created_at DESC LIMIT 1"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return nil }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (goalId as NSString).utf8String, -1, nil)

        guard sqlite3_step(stmt) == SQLITE_ROW else { return nil }
        return smarterScoreFromStatement(stmt)
    }

    func getSMARTERScoreHistory(goalId: String) -> [SMARTERScore] {
        let sql = "SELECT * FROM smarter_scores WHERE goal_id = ? ORDER BY created_at ASC"
        var stmt: OpaquePointer?
        var scores: [SMARTERScore] = []
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (goalId as NSString).utf8String, -1, nil)

        while sqlite3_step(stmt) == SQLITE_ROW {
            if let score = smarterScoreFromStatement(stmt) {
                scores.append(score)
            }
        }
        return scores
    }

    // MARK: - 領先/滯後指標

    func saveGoalIndicator(_ indicator: GoalIndicator) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO goal_indicators (id, goal_id, type, title, description, target_value, current_value, unit, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (indicator.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (indicator.goalId as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 3, (indicator.type.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (indicator.title as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 5, (indicator.description as NSString).utf8String, -1, nil)

        if let target = indicator.targetValue {
            sqlite3_bind_double(stmt, 6, target)
        } else { sqlite3_bind_null(stmt, 6) }
        if let current = indicator.currentValue {
            sqlite3_bind_double(stmt, 7, current)
        } else { sqlite3_bind_null(stmt, 7) }
        if let unit = indicator.unit {
            sqlite3_bind_text(stmt, 8, (unit as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 8) }

        sqlite3_bind_double(stmt, 9, indicator.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getGoalIndicators(goalId: String) -> [GoalIndicator] {
        let sql = "SELECT * FROM goal_indicators WHERE goal_id = ? ORDER BY type, created_at"
        var stmt: OpaquePointer?
        var indicators: [GoalIndicator] = []
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (goalId as NSString).utf8String, -1, nil)

        while sqlite3_step(stmt) == SQLITE_ROW {
            if let indicator = goalIndicatorFromStatement(stmt) {
                indicators.append(indicator)
            }
        }
        return indicators
    }

    // MARK: - 待棄清單

    func saveAbandonItem(_ item: AbandonItem) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO abandon_items (id, title, reason, freed_up_time, created_at)
        VALUES (?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (item.id as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 2, (item.title as NSString).utf8String, -1, nil)
        if let reason = item.reason {
            sqlite3_bind_text(stmt, 3, (reason as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 3) }
        if let freed = item.freedUpTime {
            sqlite3_bind_text(stmt, 4, (freed as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 4) }
        sqlite3_bind_double(stmt, 5, item.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getAbandonItems() -> [AbandonItem] {
        let sql = "SELECT * FROM abandon_items ORDER BY created_at DESC"
        var stmt: OpaquePointer?
        var items: [AbandonItem] = []
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = String(cString: sqlite3_column_text(stmt, 0))
            let title = String(cString: sqlite3_column_text(stmt, 1))
            let reason: String? = sqlite3_column_text(stmt, 2).map { String(cString: $0) }
            let freedUpTime: String? = sqlite3_column_text(stmt, 3).map { String(cString: $0) }
            let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))

            items.append(AbandonItem(id: id, title: title, reason: reason, freedUpTime: freedUpTime, createdAt: createdAt))
        }
        return items
    }

    func deleteAbandonItem(id: String) -> Bool {
        let sql = "DELETE FROM abandon_items WHERE id = ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (id as NSString).utf8String, -1, nil)
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    // MARK: - 里程碑

    func saveMilestone(_ milestone: Milestone) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO milestones (id, goal_id, title, description, achieved_at, category, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (milestone.id as NSString).utf8String, -1, nil)
        if let goalId = milestone.goalId {
            sqlite3_bind_text(stmt, 2, (goalId as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 2) }
        sqlite3_bind_text(stmt, 3, (milestone.title as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (milestone.description as NSString).utf8String, -1, nil)
        sqlite3_bind_double(stmt, 5, milestone.achievedAt.timeIntervalSince1970)
        if let category = milestone.category {
            sqlite3_bind_text(stmt, 6, (category as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 6) }
        sqlite3_bind_double(stmt, 7, milestone.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getMilestones() -> [Milestone] {
        let sql = "SELECT * FROM milestones ORDER BY achieved_at DESC"
        var stmt: OpaquePointer?
        var milestones: [Milestone] = []
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }

        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = String(cString: sqlite3_column_text(stmt, 0))
            let goalId: String? = sqlite3_column_text(stmt, 1).map { String(cString: $0) }
            let title = String(cString: sqlite3_column_text(stmt, 2))
            let desc = String(cString: sqlite3_column_text(stmt, 3))
            let achievedAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))
            let category: String? = sqlite3_column_text(stmt, 5).map { String(cString: $0) }
            let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 6))

            milestones.append(Milestone(id: id, goalId: goalId, title: title, description: desc, achievedAt: achievedAt, category: category, createdAt: createdAt))
        }
        return milestones
    }

    // MARK: - AI 生成

    /// AI 生成賦能回應
    func generateEmpoweringResponses(beliefs: [LimitingBelief]) async -> [LimitingBelief] {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let selectedBeliefs = beliefs.filter { $0.isSelected }.map { $0.text }.joined(separator: "、")
        guard !selectedBeliefs.isEmpty else { return beliefs }

        let prompt = """
        以下是用戶勾選的限制性信念：
        \(selectedBeliefs)

        請為每個信念生成一個「賦能回應」——不是否定它，而是提供一個讓用戶能重新行動的視角。
        格式：每行一個回應，用「→」分隔原信念和回應。
        例如：我做不到 → 你曾經有過類似想法，後來卻做到了的經驗嗎？
        """

        let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
        let response = await aiProvider.query(userId: userId, query: prompt)

        var result = beliefs
        let lines = response.components(separatedBy: "\n").filter { $0.contains("→") }
        for (index, line) in lines.enumerated() {
            let parts = line.components(separatedBy: "→")
            if parts.count >= 2, index < result.count {
                result[index].empoweringResponse = parts.dropFirst().joined(separator: "→").trimmingCharacters(in: .whitespaces)
            }
        }
        return result
    }

    /// AI 生成「經驗萃取報告」
    func generateExperienceReport(review: YearlyReview) async -> String {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let prompt = """
        用戶回顧了過去，整理了以下內容：
        最大的成就：\(review.topAchievements.joined(separator: "、"))
        遺憾或挑戰：\(review.regrets.joined(separator: "、"))
        學到的教訓：\(review.lessonsLearned.joined(separator: "、"))

        請生成一份「經驗萃取報告」，包含：
        1. 核心洞察：從這些經歷中，用戶最重要的3個發現
        2. 重複模式：有什麼行為模式在成就和遺憾中都出現了？
        3. 未來指引：這些經驗如何指引下一年的目標設定？
        語氣溫暖但有深度，像一個智慧的朋友在和你對話。
        """

        let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
        return await aiProvider.query(userId: userId, query: prompt)
    }

    /// AI 生成動機卡片
    func generateMotivationCard(whys: [String], goalTitle: String) async -> String {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let prompt = """
        用戶的目標：「\(goalTitle)」
        為什麼要完成：\(whys.enumerated().map { "第\($0+1)個原因：\($1)" }.joined(separator: "；"))

        請生成一張「動機卡片」——一句能激勵用戶在困難時刻堅持下去的話。
        要求：
        - 結合用戶的「為什麼」
        - 不要用空洞的加油，而是具體提醒他為什麼出發
        - 30字以內
        - 像一張可以放在桌上的小卡片
        """

        let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
        return await aiProvider.query(userId: userId, query: prompt)
    }

    /// AI 生成 SMARTER 改進建議
    func generateSMARTERSuggestions(score: SMARTERScore, goalTitle: String) async -> [String] {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let lowScores: [String] = [
            score.specific < 6 ? "具體性(\(score.specific)/10)" : nil,
            score.measurable < 6 ? "可衡量性(\(score.measurable)/10)" : nil,
            score.actionable < 6 ? "可執行性(\(score.actionable)/10)" : nil,
            score.risky < 6 ? "風險度(\(score.risky)/10) — 目標可能太安全" : nil,
            score.timeKeyed < 6 ? "時限性(\(score.timeKeyed)/10)" : nil,
            score.exciting < 6 ? "興奮度(\(score.exciting)/10) — 目標可能不夠激動人心" : nil,
            score.relevant < 6 ? "相關性(\(score.relevant)/10)" : nil
        ].compactMap { $0 }

        guard !lowScores.isEmpty else { return ["你的目標在所有維度都得分不錯！繼續保持。"] }

        let prompt = """
        用戶的目標：「\(goalTitle)」
        SMARTER評分較低的維度：\(lowScores.joined(separator: "、"))
        請為每個低分維度生成一條具體的改進建議，幫助用戶強化目標。
        格式：每行一條建議，對應一個維度。
        """

        let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
        let response = await aiProvider.query(userId: userId, query: prompt)
        return response.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    // MARK: - Statement Parsers

    private func yearlyReviewFromStatement(_ stmt: OpaquePointer?) -> YearlyReview? {
        guard let stmt = stmt else { return nil }
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let year = Int(sqlite3_column_int(stmt, 1))
        let achievementsStr = sqlite3_column_text(stmt, 2).map { String(cString: $0) } ?? "[]"
        let regretsStr = sqlite3_column_text(stmt, 3).map { String(cString: $0) } ?? "[]"
        let lessonsStr = sqlite3_column_text(stmt, 4).map { String(cString: $0) } ?? "[]"
        let aiReport: String? = sqlite3_column_text(stmt, 5).map { String(cString: $0) }
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 6))

        let achievements = (try? JSONDecoder().decode([String].self, from: Data(achievementsStr.utf8))) ?? []
        let regrets = (try? JSONDecoder().decode([String].self, from: Data(regretsStr.utf8))) ?? []
        let lessons = (try? JSONDecoder().decode([String].self, from: Data(lessonsStr.utf8))) ?? []

        return YearlyReview(id: id, year: year, topAchievements: achievements, regrets: regrets, lessonsLearned: lessons, aiExperienceReport: aiReport, createdAt: createdAt)
    }

    private func goalMotivationFromStatement(_ stmt: OpaquePointer?) -> GoalMotivation? {
        guard let stmt = stmt else { return nil }
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let goalId = String(cString: sqlite3_column_text(stmt, 1))
        let whysStr = sqlite3_column_text(stmt, 2).map { String(cString: $0) } ?? "[]"
        let aiCard: String? = sqlite3_column_text(stmt, 3).map { String(cString: $0) }
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 4))

        let whys = (try? JSONDecoder().decode([String].self, from: Data(whysStr.utf8))) ?? []
        return GoalMotivation(id: id, goalId: goalId, whys: whys, aiMotivationCard: aiCard, createdAt: createdAt)
    }

    private func smarterScoreFromStatement(_ stmt: OpaquePointer?) -> SMARTERScore? {
        guard let stmt = stmt else { return nil }
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let goalId = String(cString: sqlite3_column_text(stmt, 1))
        let specific = Int(sqlite3_column_int(stmt, 2))
        let measurable = Int(sqlite3_column_int(stmt, 3))
        let actionable = Int(sqlite3_column_int(stmt, 4))
        let risky = Int(sqlite3_column_int(stmt, 5))
        let timeKeyed = Int(sqlite3_column_int(stmt, 6))
        let exciting = Int(sqlite3_column_int(stmt, 7))
        let relevant = Int(sqlite3_column_int(stmt, 8))
        let suggestionsStr: String? = sqlite3_column_text(stmt, 9).map { String(cString: $0) }
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 10))

        let suggestions = suggestionsStr.flatMap { try? JSONDecoder().decode([String].self, from: Data($0.utf8)) }

        return SMARTERScore(id: id, goalId: goalId, specific: specific, measurable: measurable,
                            actionable: actionable, risky: risky, timeKeyed: timeKeyed,
                            exciting: exciting, relevant: relevant, aiSuggestions: suggestions, createdAt: createdAt)
    }

    private func goalIndicatorFromStatement(_ stmt: OpaquePointer?) -> GoalIndicator? {
        guard let stmt = stmt else { return nil }
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let goalId = String(cString: sqlite3_column_text(stmt, 1))
        let typeRaw = String(cString: sqlite3_column_text(stmt, 2))
        let title = String(cString: sqlite3_column_text(stmt, 3))
        let desc = String(cString: sqlite3_column_text(stmt, 4))
        let targetValue: Double? = sqlite3_column_type(stmt, 5) != SQLITE_NULL ? sqlite3_column_double(stmt, 5) : nil
        let currentValue: Double? = sqlite3_column_type(stmt, 6) != SQLITE_NULL ? sqlite3_column_double(stmt, 6) : nil
        let unit: String? = sqlite3_column_text(stmt, 7).map { String(cString: $0) }
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 8))

        guard let type = GoalIndicatorType(rawValue: typeRaw) else { return nil }
        return GoalIndicator(id: id, goalId: goalId, type: type, title: title, description: desc,
                             targetValue: targetValue, currentValue: currentValue, unit: unit, createdAt: createdAt)
    }

    // MARK: - 信念轉化記錄

    func saveBeliefRecord(_ record: BeliefRecord) -> Bool {
        let sql = """
        INSERT OR REPLACE INTO belief_records (id, user_id, limiting_belief, reframed_belief, category, status, action_taken, action_date, is_verified, verified_at, ai_guidance, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
        """
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        sqlite3_bind_text(stmt, 1, (record.id as NSString).utf8String, -1, nil)
        if let userId = record.userId {
            sqlite3_bind_text(stmt, 2, (userId as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 2) }
        sqlite3_bind_text(stmt, 3, (record.limitingBelief as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 4, (record.reframedBelief as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 5, (record.category.rawValue as NSString).utf8String, -1, nil)
        sqlite3_bind_text(stmt, 6, (record.status.rawValue as NSString).utf8String, -1, nil)

        if let action = record.actionTaken {
            sqlite3_bind_text(stmt, 7, (action as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 7) }

        if let actionDate = record.actionDate {
            sqlite3_bind_double(stmt, 8, actionDate.timeIntervalSince1970)
        } else { sqlite3_bind_null(stmt, 8) }

        sqlite3_bind_int(stmt, 9, record.isVerified ? 1 : 0)

        if let verifiedAt = record.verifiedAt {
            sqlite3_bind_double(stmt, 10, verifiedAt.timeIntervalSince1970)
        } else { sqlite3_bind_null(stmt, 10) }

        if let guidance = record.aiGuidance {
            sqlite3_bind_text(stmt, 11, (guidance as NSString).utf8String, -1, nil)
        } else { sqlite3_bind_null(stmt, 11) }

        sqlite3_bind_double(stmt, 12, record.createdAt.timeIntervalSince1970)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getBeliefRecords(userId: String) -> [BeliefRecord] {
        let sql = "SELECT * FROM belief_records WHERE user_id = ? OR user_id IS NULL ORDER BY created_at DESC"
        var stmt: OpaquePointer?
        var records: [BeliefRecord] = []
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (userId as NSString).utf8String, -1, nil)

        while sqlite3_step(stmt) == SQLITE_ROW {
            if let record = beliefRecordFromStatement(stmt) {
                records.append(record)
            }
        }
        return records
    }

    func updateBeliefStatus(id: String, status: BeliefStatus, actionTaken: String? = nil) -> Bool {
        var sql = "UPDATE belief_records SET status = ?"
        if actionTaken != nil { sql += ", action_taken = ?, action_date = ?" }
        if status == .verified { sql += ", is_verified = 1, verified_at = ?" }
        sql += " WHERE id = ?"

        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }

        var paramIndex: Int32 = 1
        sqlite3_bind_text(stmt, paramIndex, (status.rawValue as NSString).utf8String, -1, nil)
        paramIndex += 1

        if let action = actionTaken {
            sqlite3_bind_text(stmt, paramIndex, (action as NSString).utf8String, -1, nil)
            paramIndex += 1
            sqlite3_bind_double(stmt, paramIndex, Date().timeIntervalSince1970)
            paramIndex += 1
        }

        if status == .verified {
            sqlite3_bind_double(stmt, paramIndex, Date().timeIntervalSince1970)
            paramIndex += 1
        }

        sqlite3_bind_text(stmt, paramIndex, (id as NSString).utf8String, -1, nil)

        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func deleteBeliefRecord(id: String) -> Bool {
        let sql = "DELETE FROM belief_records WHERE id = ?"
        var stmt: OpaquePointer?
        guard sqlite3_prepare_v2(database.db, sql, -1, &stmt, nil) == SQLITE_OK else { return false }
        defer { sqlite3_finalize(stmt) }
        sqlite3_bind_text(stmt, 1, (id as NSString).utf8String, -1, nil)
        return sqlite3_step(stmt) == SQLITE_DONE
    }

    func getBeliefStats(userId: String) -> (total: Int, verified: Int, active: Int, topCategory: BeliefCategory) {
        let records = getBeliefRecords(userId: userId)
        let verified = records.filter { $0.isVerified }.count
        let active = records.filter { $0.status == .active }.count

        // Find most common category
        var categoryCounts: [BeliefCategory: Int] = [:]
        for record in records {
            categoryCounts[record.category, default: 0] += 1
        }
        let topCategory = categoryCounts.max(by: { $0.value < $1.value })?.key ?? .general

        return (total: records.count, verified: verified, active: active, topCategory: topCategory)
    }

    private func beliefRecordFromStatement(_ stmt: OpaquePointer?) -> BeliefRecord? {
        guard let stmt = stmt else { return nil }
        let id = String(cString: sqlite3_column_text(stmt, 0))
        let userId: String? = sqlite3_column_text(stmt, 1).map { String(cString: $0) }
        let limitingBelief = String(cString: sqlite3_column_text(stmt, 2))
        let reframedBelief = String(cString: sqlite3_column_text(stmt, 3))
        let categoryRaw = String(cString: sqlite3_column_text(stmt, 4))
        let statusRaw = String(cString: sqlite3_column_text(stmt, 5))
        let actionTaken: String? = sqlite3_column_text(stmt, 6).map { String(cString: $0) }
        let actionDate: Date? = sqlite3_column_type(stmt, 7) != SQLITE_NULL ? Date(timeIntervalSince1970: sqlite3_column_double(stmt, 7)) : nil
        let isVerified = sqlite3_column_int(stmt, 8) == 1
        let verifiedAt: Date? = sqlite3_column_type(stmt, 9) != SQLITE_NULL ? Date(timeIntervalSince1970: sqlite3_column_double(stmt, 9)) : nil
        let aiGuidance: String? = sqlite3_column_text(stmt, 10).map { String(cString: $0) }
        let createdAt = Date(timeIntervalSince1970: sqlite3_column_double(stmt, 11))

        guard let category = BeliefCategory(rawValue: categoryRaw),
              let status = BeliefStatus(rawValue: statusRaw) else { return nil }

        return BeliefRecord(
            id: id, userId: userId,
            limitingBelief: limitingBelief, reframedBelief: reframedBelief,
            category: category, status: status,
            actionTaken: actionTaken, actionDate: actionDate,
            isVerified: isVerified, verifiedAt: verifiedAt,
            aiGuidance: aiGuidance, createdAt: createdAt
        )
    }
}
