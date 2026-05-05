import Foundation

/// 揪團成長服務 — 管理 AI 夥伴揪團的生命週期與互動
final class GrowthGroupService {
    static let shared = GrowthGroupService()
    private let database = DatabaseManager.shared
    private let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
    private init() {}

    // MARK: - 揪團 CRUD

    /// 創建揪團 — 根據目標自動生成 AI 夥伴陣容
    func createGroup(
        name: String,
        theme: String,
        dimension: GoalDimension,
        goalId: String? = nil,
        totalDays: Int = 21,
        includeCoach: Bool = false
    ) -> GrowthGroup {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        let group = GrowthGroup(
            name: name,
            theme: theme,
            dimension: dimension,
            goalId: goalId,
            memberIds: [userId],
            adminId: userId,
            totalDays: totalDays,
            aiPartners: includeCoach
                ? GrowthGroup.fullPartners(groupId: "", dimension: dimension)
                : GrowthGroup.defaultPartners(groupId: "", dimension: dimension)
        )

        // 更新夥伴的 groupId
        var updatedGroup = group
        updatedGroup.aiPartners = updatedGroup.aiPartners.map { partner in
            var p = partner
            p.groupId = group.id
            return p
        }

        _ = database.saveGrowthGroup(updatedGroup)
        return updatedGroup
    }

    /// 獲取所有揪團
    func getAllGroups() -> [GrowthGroup] {
        return database.getAllGrowthGroups()
    }

    /// 獲取揪團詳情
    func getGroup(byId id: String) -> GrowthGroup? {
        return database.getGrowthGroup(byId: id)
    }

    /// 更新揪團
    func updateGroup(_ group: GrowthGroup) -> Bool {
        return database.saveGrowthGroup(group)
    }

    /// 刪除揪團
    func deleteGroup(_ groupId: String) -> Bool {
        return database.deleteGrowthGroup(byId: groupId)
    }

    // MARK: - 夥伴互動

    /// 獲取 AI 夥伴在揪團動態中的回覆
    func getPartnerResponses(
        groupId: String,
        userMessage: String,
        activityType: GroupActivityType
    ) async -> [GroupActivity] {
        guard let group = getGroup(byId: groupId) else { return [] }
        var responses: [GroupActivity] = []

        for partner in group.aiPartners {
            // 根據角色和活動類型決定是否回覆
            guard shouldPartnerRespond(partner: partner, activityType: activityType, userMessage: userMessage) else {
                continue
            }

            let response = await generatePartnerResponse(
                partner: partner,
                group: group,
                userMessage: userMessage,
                activityType: activityType
            )

            let activity = GroupActivity(
                groupId: groupId,
                partnerId: partner.id,
                authorName: partner.name,
                authorEmoji: partner.avatarEmoji,
                activityType: appropriateActivityType(for: partner.role, triggeredBy: activityType),
                content: response,
                createdAt: Date().addingTimeInterval(Double.random(in: 30...300)) // 模擬自然回覆間隔
            )
            responses.append(activity)
        }

        // 按時間排序
        return responses.sorted { $0.createdAt < $1.createdAt }
    }

    /// 用戶打卡後觸發夥伴互動
    func triggerCheckInInteraction(groupId: String, checkInNote: String?) async -> [GroupActivity] {
        let note = checkInNote ?? "完成了今天的打卡！"
        return await getPartnerResponses(
            groupId: groupId,
            userMessage: note,
            activityType: .checkIn
        )
    }

    /// 用戶分享經驗後觸發夥伴互動
    func triggerSharingInteraction(groupId: String, sharingContent: String) async -> [GroupActivity] {
        return await getPartnerResponses(
            groupId: groupId,
            userMessage: sharingContent,
            activityType: .sharing
        )
    }

    /// 獲取夥伴的日常動態（打卡/分享/提問）— 每日生成
    func generateDailyPartnerActivities(groupId: String) async -> [GroupActivity] {
        guard let group = getGroup(byId: groupId) else { return [] }
        var activities: [GroupActivity] = []

        for partner in group.aiPartners {
            let activity = await generateDailyActivity(partner: partner, group: group)
            activities.append(activity)
        }

        return activities.sorted { $0.createdAt < $1.createdAt }
    }

    // MARK: - 私人 AI 夥伴對話

    /// 與特定 AI 夥伴私下對話
    func chatWithPartner(
        partnerId: String,
        groupId: String,
        userMessage: String,
        conversationHistory: [AIMessage]
    ) async -> String {
        guard let group = getGroup(byId: groupId),
              let partner = group.aiPartners.first(where: { $0.id == partnerId }) else {
            return "找不到這位夥伴。"
        }

        let contextPrompt = """
        你是\(partner.name)，角色是「\(partner.role.displayName)」。
        \(partner.role.personalityPrompt)

        你的背景：\(partner.backstory)
        你的性格：\(partner.personality)
        目前狀態：\(partner.currentStatus)

        揪團「\(group.name)」正在進行第\(group.dayNumber)天/共\(group.totalDays)天。
        主題：\(group.theme)

        請以\(partner.name)的身份回覆用戶的訊息，保持角色一致性。
        """

        // 構建帶角色 context 的查詢
        let fullQuery = "\(contextPrompt)\n\n用戶說：\(userMessage)"
        let userId = UserDefaultsManager.shared.currentUserId ?? ""

        return await aiProvider.query(userId: userId, query: fullQuery)
    }

    // MARK: - 夥伴狀態更新

    /// 推進夥伴的進度狀態（每日調用）
    func advancePartnerStatus(groupId: String) {
        guard var group = getGroup(byId: groupId) else { return }

        group.dayNumber = min(group.dayNumber + 1, group.totalDays)

        for index in group.aiPartners.indices {
            let partner = group.aiPartners[index]
            group.aiPartners[index].currentStatus = updatedStatus(
                for: partner.role,
                dayNumber: group.dayNumber,
                totalDays: group.totalDays
            )
        }

        // 更新里程碑
        group.groupMilestone = milestoneMessage(dayNumber: group.dayNumber, totalDays: group.totalDays)

        if group.dayNumber >= group.totalDays {
            group.isActive = false
        }

        _ = updateGroup(group)
    }

    // MARK: - Private Helpers

    private func shouldPartnerRespond(
        partner: AIPartner,
        activityType: GroupActivityType,
        userMessage: String
    ) -> Bool {
        // 教練只在特定時刻介入
        if partner.role == .coach {
            switch activityType {
            case .milestone, .question, .reflection:
                return true
            default:
                return Bool.random() && Double.random(in: 0...1) < 0.3 // 30% 機率回覆一般打卡
            }
        }

        // 過來人更常在分享和提問時回覆
        if partner.role == .experiencedGuide {
            switch activityType {
            case .sharing, .question, .reflection:
                return true
            default:
                return Double.random(in: 0...1) < 0.7
            }
        }

        // 新手更常在看到鼓勵和打卡時回覆
        if partner.role == .inspiredBeginner {
            switch activityType {
            case .encouragement, .checkIn, .milestone:
                return true
            default:
                return Double.random(in: 0...1) < 0.5
            }
        }

        // 同行者幾乎總是回覆
        return Double.random(in: 0...1) < 0.85
    }

    private func appropriateActivityType(for role: AIPartnerRole, triggeredBy: GroupActivityType) -> GroupActivityType {
        switch role {
        case .fellowStarter:
            switch triggeredBy {
            case .checkIn: return .checkIn
            case .sharing: return .sharing
            case .question: return .sharing
            default: return .encouragement
            }
        case .experiencedGuide:
            switch triggeredBy {
            case .checkIn: return .sharing
            case .question: return .sharing
            default: return .reflection
            }
        case .inspiredBeginner:
            switch triggeredBy {
            case .checkIn: return .encouragement
            case .sharing: return .question
            default: return .checkIn
            }
        case .coach:
            return .reflection
        }
    }

    private func generatePartnerResponse(
        partner: AIPartner,
        group: GrowthGroup,
        userMessage: String,
        activityType: GroupActivityType
    ) async -> String {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let prompt = """
        你是\(partner.name)（\(partner.role.displayName)），在揪團「\(group.name)」中。
        \(partner.role.personalityPrompt)
        背景：\(partner.backstory)
        性格：\(partner.personality)
        狀態：\(partner.currentStatus)
        揪團進度：第\(group.dayNumber)天/共\(group.totalDays)天

        用戶\(activityType == .checkIn ? "打卡了" : activityType == .sharing ? "分享了" : "發了訊息")：
        「\(userMessage)」

        請以\(partner.name)的身份簡短回覆（30-80字），保持角色語氣和個性。
        不要重複用戶說過的話，要有自己的觀點和感受。
        """

        return await aiProvider.query(userId: userId, query: prompt)
    }

    private func generateDailyActivity(partner: AIPartner, group: GrowthGroup) async -> GroupActivity {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""

        let activityPrompt: String
        switch partner.role {
        case .fellowStarter:
            activityPrompt = """
            你是\(partner.name)（同行者），第\(group.dayNumber)天。
            簡短分享你今天的一個小動作或感受（20-50字），像發一條朋友圈。
            """
        case .experiencedGuide:
            activityPrompt = """
            你是\(partner.name)（過來人），第\(group.dayNumber)天。
            分享一個當初在第\(group.dayNumber)天時的小心得（20-50字）。
            """
        case .inspiredBeginner:
            activityPrompt = """
            你是\(partner.name)（新手），剛開始不久。
            分享你今天的一個小嘗試或疑惑（20-50字），語氣謙虛好奇。
            """
        case .coach:
            activityPrompt = """
            你是\(partner.name)（教練），觀察第\(group.dayNumber)天的進度。
            給一句簡短的提醒或鼓勵（15-30字）。
            """
        }

        let content = await aiProvider.query(userId: userId, query: activityPrompt)

        let activityType: GroupActivityType
        switch partner.role {
        case .fellowStarter: activityType = .checkIn
        case .experiencedGuide: activityType = .sharing
        case .inspiredBeginner: activityType = .checkIn
        case .coach: activityType = .encouragement
        }

        return GroupActivity(
            groupId: group.id,
            partnerId: partner.id,
            authorName: partner.name,
            authorEmoji: partner.avatarEmoji,
            activityType: activityType,
            content: content,
            createdAt: Date().addingTimeInterval(Double.random(in: -3600...0)) // 過去 1 小時內隨機
        )
    }

    private func updatedStatus(for role: AIPartnerRole, dayNumber: Int, totalDays: Int) -> String {
        let progress = Double(dayNumber) / Double(totalDays)
        switch role {
        case .fellowStarter:
            if progress < 0.3 { return "和你一起剛起步，還在找節奏" }
            else if progress < 0.7 { return "逐漸找到節奏了！" }
            else { return "快到終點了，堅持住！" }
        case .experiencedGuide:
            return "已完成挑戰，持續分享經驗中"
        case .inspiredBeginner:
            if progress < 0.2 { return "被你影響剛開始，有點緊張" }
            else if progress < 0.5 { return "慢慢上手了，謝謝你的鼓勵" }
            else { return "越來越有信心了！" }
        case .coach:
            return "觀察小組動態，適時引導"
        }
    }

    private func milestoneMessage(dayNumber: Int, totalDays: Int) -> String {
        let progress = Double(dayNumber) / Double(totalDays)
        if dayNumber == 1 { return "🎉 揪團啟動！一起邁出第一步" }
        else if dayNumber == 7 { return "💪 第一週完成！習慣正在養成" }
        else if dayNumber == 14 { return "🔥 過半了！最後一週衝刺" }
        else if dayNumber == 21 { return "🏆 21天挑戰完成！你們做到了！" }
        else if progress >= 1.0 { return "🎊 揪團圓滿結束！" }
        else { return "第\(dayNumber)天 — 穩步前進中" }
    }
}
