import Foundation

// MARK: - 成長夥伴狀態
enum BuddyStatus: String, Codable {
    case justStarted = "just_started"      // 剛開始
    case inProgress = "in_progress"       // 進行中
    case completed = "completed"         // 已完成
    case notStarted = "not_started"      // 尚未開始
}

// MARK: - 成長夥伴
struct GrowthBuddy: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var avatar: String          // SF Symbol 名稱
    var status: BuddyStatus
    var challengeDay: Int       // 當前任務天數
    var totalDays: Int          // 任務總天數
    var streak: Int             // 連續天數
    var lastActiveDate: Date
    var sharedExperience: String?  // 分享的經驗（已完成夥伴）
    var inspirationalMessage: String?  // 激勵訊息
    
    // MARK: - 掉鏈子相關屬性
    var missProbability: Double   // 掉鏈子機率 (0.0-1.0)，僅影響中/進行中夥伴
    var missedDays: Int           // 累計漏打卡天數
    var lastMissDate: Date?       // 最近一次漏打卡時間
    var isCurrentlySlacking: Bool // 是否正在掉鏈子狀態
    var slackingStartDate: Date?  // 掉鏈子開始時間
    
    init(
        id: String = UUID().uuidString,
        name: String,
        avatar: String = "person.circle.fill",
        status: BuddyStatus,
        challengeDay: Int = 1,
        totalDays: Int = 21,
        streak: Int = 0,
        lastActiveDate: Date = Date(),
        sharedExperience: String? = nil,
        inspirationalMessage: String? = nil,
        missProbability: Double = 0.0,
        missedDays: Int = 0,
        lastMissDate: Date? = nil,
        isCurrentlySlacking: Bool = false,
        slackingStartDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.avatar = avatar
        self.status = status
        self.challengeDay = challengeDay
        self.totalDays = totalDays
        self.streak = streak
        self.lastActiveDate = lastActiveDate
        self.sharedExperience = sharedExperience
        self.inspirationalMessage = inspirationalMessage
        self.missProbability = missProbability
        self.missedDays = missedDays
        self.lastMissDate = lastMissDate
        self.isCurrentlySlacking = isCurrentlySlacking
        self.slackingStartDate = slackingStartDate
    }
    
    // 進度百分比
    var progressPercentage: Double {
        Double(challengeDay) / Double(totalDays)
    }
    
    // 掉鏈子嚴重程度文字
    var slackingLevel: String {
        if missedDays <= 0 { return "無" }
        if missedDays <= 2 { return "輕微" }
        if missedDays <= 5 { return "中等" }
        return "嚴重"
    }
    
    // 掉鏈子天數文字
    var slackingDaysText: String {
        guard let startDate = slackingStartDate else { return "" }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: Date()).day ?? 0
        if days <= 0 { return "" }
        return "已掉鏈\(days)天"
    }
    
    // 漏打卡天數文字（統計用）
    var missedDaysText: String {
        if missedDays <= 0 { return "從未漏卡" }
        return "漏打卡\(missedDays)天"
    }
    
    // 狀態文字
    var statusText: String {
        switch status {
        case .justStarted:
            return "和新夥伴一起開始了！"
        case .inProgress:
            return "持續努力中 💪"
        case .completed:
            return "已完成挑戰 ✨"
        case .notStarted:
            return "準備開始 🌱"
        }
    }
    
    static func == (lhs: GrowthBuddy, rhs: GrowthBuddy) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 夥伴群組
struct BuddyGroup: Codable, Identifiable {
    var id: String
    var userId: String
    var buddies: [GrowthBuddy]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        id: String = UUID().uuidString,
        userId: String,
        buddies: [GrowthBuddy] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.buddies = buddies
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // 獲取特定狀態的夥伴
    func buddies(withStatus status: BuddyStatus) -> [GrowthBuddy] {
        buddies.filter { $0.status == status }
    }
    
    // 獲取已完成可以分享經驗的夥伴
    var experiencedBuddy: GrowthBuddy? {
        buddies.first { $0.status == .completed && $0.sharedExperience != nil }
    }
    
    // 獲取待影響的夥伴
    var pendingBuddy: GrowthBuddy? {
        buddies.first { $0.status == .notStarted }
    }
    
    // 更新夥伴狀態
    mutating func updateBuddy(_ buddy: GrowthBuddy) {
        if let index = buddies.firstIndex(where: { $0.id == buddy.id }) {
            buddies[index] = buddy
            updatedAt = Date()
        }
    }
}

// MARK: - 夥伴生成配置
struct BuddyConfiguration {
    // 固定夥伴名單
    static let buddyNames = [
        "小明", "小美", "阿志", "婷妹", "大雄"
    ]
    
    static let buddyAvatars = [
        "person.circle.fill",
        "face.smiling.inverse",
        "person.circle",
        "star.circle.fill",
        "moon.circle.fill"
    ]
    
    // 生成預設夥伴群組
    static func createDefaultGroup(userId: String, challengeDay: Int = 1) -> BuddyGroup {
        var buddies: [GrowthBuddy] = []
        
        // 2位新開始的夥伴（各自有不同的掉鏈子機率）
        let missProbs = [0.15, 0.25]  // 15% 和 25% 的漏打卡機率
        for i in 0..<2 {
            let buddy = GrowthBuddy(
                name: buddyNames[i],
                avatar: buddyAvatars[i],
                status: .justStarted,
                challengeDay: challengeDay,
                streak: challengeDay > 0 ? 1 : 0,
                lastActiveDate: Date(),
                missProbability: missProbs[i]
            )
            buddies.append(buddy)
        }
        
        // 1位已完成並分享經驗（從不漏卡）
        let experienceBuddy = GrowthBuddy(
            name: buddyNames[2],
            avatar: buddyAvatars[2],
            status: .completed,
            challengeDay: 21,
            totalDays: 21,
            streak: 21,
            lastActiveDate: Date().addingTimeInterval(-86400),
            sharedExperience: "坚持21天的关键是把大目标拆成小任务，每天完成一点点就够！",
            inspirationalMessage: "你也可以做到的！",
            missProbability: 0.0  // 完成者不會漏卡
        )
        buddies.append(experienceBuddy)
        
        // 1位尚未開始的夥伴（較高漏卡機率，消極型）
        let pendingBuddy = GrowthBuddy(
            name: buddyNames[3],
            avatar: buddyAvatars[3],
            status: .notStarted,
            challengeDay: 0,
            streak: 0,
            lastActiveDate: Date().addingTimeInterval(-86400 * 2),
            inspirationalMessage: "看到你这么努力，我也想试试看！",
            missProbability: 0.35  // 消極型，容易放棄
        )
        buddies.append(pendingBuddy)
        
        return BuddyGroup(userId: userId, buddies: buddies)
    }
    
    // 根據用戶挑戰進度更新夥伴
    static func updateGroupWithProgress(_ group: inout BuddyGroup, userDay: Int) {
        // 更新新開始的夥伴進度
        for i in 0..<group.buddies.count {
            if group.buddies[i].status == .justStarted {
                group.buddies[i].challengeDay = userDay
                group.buddies[i].streak = userDay
                group.buddies[i].lastActiveDate = Date()
                
                // 如果用户进度够多，夥伴也开始进行中了
                if userDay > 3 {
                    group.buddies[i].status = .inProgress
                }
            }
        }
        
        // 更新待影響夥伴的狀態
        if let pendingIndex = group.buddies.firstIndex(where: { $0.status == .notStarted }) {
            // 根据用户连续打卡天数影响夥伴
            let influenceLevel = min(userDay / 5, 3) // 每5天提升一级
            if influenceLevel >= 2 {
                group.buddies[pendingIndex].status = .justStarted
                group.buddies[pendingIndex].challengeDay = 1
                group.buddies[pendingIndex].inspirationalMessage = "看你堅持了\(userDay)天，我也想試試！"
            }
        }
        
        group.updatedAt = Date()
    }
}