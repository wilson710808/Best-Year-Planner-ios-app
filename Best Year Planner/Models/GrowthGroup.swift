import Foundation

// MARK: - AI 夥伴角色定義

/// 揪團中 AI 夥伴的角色類型
enum AIPartnerRole: String, Codable, CaseIterable {
    /// 同行者 — 與用戶同時開始，一起摸索成長
    case fellowStarter = "fellow_starter"
    /// 過來人 — 已完成相同任務，分享經驗與心得
    case experiencedGuide = "experienced_guide"
    /// 新手 — 尚未開始，被用戶影響而起步
    case inspiredBeginner = "inspired_beginner"
    /// 教練 — 全局視角，引導討論方向
    case coach = "coach"

    var displayName: String {
        switch self {
        case .fellowStarter: return "同行者"
        case .experiencedGuide: return "過來人"
        case .inspiredBeginner: return "新手"
        case .coach: return "教練"
        }
    }

    var icon: String {
        switch self {
        case .fellowStarter: return "person.2.fill"
        case .experiencedGuide: return "star.fill"
        case .inspiredBeginner: return "leaf.fill"
        case .coach: return "figure.walk"
        }
    }

    var color: String {
        switch self {
        case .fellowStarter: return "3498DB"   // 藍色 — 一起走
        case .experiencedGuide: return "F39C12" // 金色 — 經驗光環
        case .inspiredBeginner: return "27AE60" // 綠色 — 新生萌芽
        case .coach: return "9B59B6"            // 紫色 — 智慧引導
        }
    }

    /// 角色人格描述（用於 AI prompt）
    var personalityPrompt: String {
        switch self {
        case .fellowStarter:
            return """
            你是「同行者」，和用戶差不多同時開始這個挑戰。
            你的特點：
            - 也在經歷同樣的困難和猶豫，能產生共鳴
            - 會分享自己嘗試的方法，不確定是否最好但很真實
            - 偶爾也會想偷懶，但會因為看到用戶堅持而重新振作
            - 語氣像朋友，輕鬆自然，會說「我也是耶！」
            - 不會說教，而是「我試了...你覺得呢？」
            """
        case .experiencedGuide:
            return """
            你是「過來人」，已經完成過類似的挑戰或目標。
            你的特點：
            - 有實戰經驗，能指出常見的坑和解法
            - 分享自己的故事，不是理論而是親身經歷
            - 偶爾會回想當初的掙扎，帶著理解的微笑
            - 不會高高在上，而是「我當時也卡在這裡...」
            - 會給具體建議，但也尊重每個人的節奏
            - 語氣溫暖自信，像學長姐而不是老師
            """
        case .inspiredBeginner:
            return """
            你是「新手」，因為看到用戶的行動而決定開始。
            你的特點：
            - 對用戶充滿好奇和敬佩：「你怎麼做到的？」
            - 會問很多問題，有些看似簡單但很有價值
            - 剛開始會有些不確定和緊張
            - 用戶的進步會激勵你，你會分享自己的小進步
            - 語氣謙虛好奇，會說「我最近也開始試了...」
            - 偶爾會因為困難而氣餒，需要鼓勵
            """
        case .coach:
            return """
            你是「教練」，負責引導整個小組的成長方向。
            你的特點：
            - 觀察每個夥伴的狀態，適時引導話題
            - 在大家偏離主題時溫和地拉回來
            - 會總結大家的討論，提煉關鍵洞察
            - 不過度干預，讓夥伴之間自然互動
            - 在關鍵時刻給出框架和方法論
            - 語氣沉穩專業，但平易近人
            """
        }
    }
}

// MARK: - AI 夥伴模型

struct AIPartner: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var role: AIPartnerRole
    var personality: String    // 人格特質描述
    var avatarEmoji: String    // 頭像 emoji
    var backstory: String      // 背景故事
    var currentStatus: String  // 目前狀態（如「第12天打卡中」）
    var groupId: String        // 所屬揪團 ID

    init(
        id: String = UUID().uuidString,
        name: String,
        role: AIPartnerRole,
        personality: String = "",
        avatarEmoji: String = "🧑",
        backstory: String = "",
        currentStatus: String = "",
        groupId: String = ""
    ) {
        self.id = id
        self.name = name
        self.role = role
        self.personality = personality
        self.avatarEmoji = avatarEmoji
        self.backstory = backstory
        self.currentStatus = currentStatus
        self.groupId = groupId
    }

    static func == (lhs: AIPartner, rhs: AIPartner) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - 揪團模型（擴展 CommunityGroup）

struct GrowthGroup: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var theme: String                   // 成長主題（如「早起打卡」「閱讀習慣」）
    var groupDescription: String
    var goalId: String?                 // 關聯的年度目標
    var dimension: GoalDimension        // 關聯維度
    var aiPartners: [AIPartner]         // AI 夥伴列表（3-5人）
    var memberIds: [String]             // 真實用戶 ID
    var adminId: String
    var createdAt: Date
    var dailyCheckInGoal: Int
    var isActive: Bool
    var dayNumber: Int                  // 揪團進行天數
    var totalDays: Int                  // 揪團總天數
    var groupMilestone: String          // 當前里程碑描述

    init(
        id: String = UUID().uuidString,
        name: String,
        theme: String,
        groupDescription: String = "",
        goalId: String? = nil,
        dimension: GoalDimension = .growth,
        aiPartners: [AIPartner] = [],
        memberIds: [String] = [],
        adminId: String,
        createdAt: Date = Date(),
        dailyCheckInGoal: Int = 1,
        isActive: Bool = true,
        dayNumber: Int = 1,
        totalDays: Int = 21,
        groupMilestone: String = ""
    ) {
        self.id = id
        self.name = name
        self.theme = theme
        self.groupDescription = groupDescription
        self.goalId = goalId
        self.dimension = dimension
        self.aiPartners = aiPartners
        self.memberIds = memberIds
        self.adminId = adminId
        self.createdAt = createdAt
        self.dailyCheckInGoal = dailyCheckInGoal
        self.isActive = isActive
        self.dayNumber = dayNumber
        self.totalDays = totalDays
        self.groupMilestone = groupMilestone
    }

    static func == (lhs: GrowthGroup, rhs: GrowthGroup) -> Bool {
        lhs.id == rhs.id
    }

    // MARK: - 預設夥伴配置

    /// 生成標準 4 人 AI 夥伴陣容（同行者×2 + 過來人×1 + 新手×1）
    static func defaultPartners(groupId: String, dimension: GoalDimension) -> [AIPartner] {
        let dimName = dimension.displayName

        return [
            AIPartner(
                name: "小藍",
                role: .fellowStarter,
                personality: "溫和友善，容易共情",
                avatarEmoji: "🧑‍💼",
                backstory: "和你差不多時間開始，工作上也需要養成這個習慣",
                currentStatus: "和你一起剛起步",
                groupId: groupId
            ),
            AIPartner(
                name: "阿星",
                role: .fellowStarter,
                personality: "開朗活潑，喜歡嘗試新方法",
                avatarEmoji: "🌟",
                backstory: "是個行動派，喜歡邊做邊調整，不喜歡想太多",
                currentStatus: "正在嘗試不同的方法找到節奏",
                groupId: groupId
            ),
            AIPartner(
                name: "過來人-明姐",
                role: .experiencedGuide,
                personality: "溫暖自信，經驗豐富",
                avatarEmoji: "⭐",
                backstory: "半年前完成了\(dimName)領域的21天挑戰，現在已經是習慣了",
                currentStatus: "已完成\(dimName)挑戰，分享經驗中",
                groupId: groupId
            ),
            AIPartner(
                name: "小綠",
                role: .inspiredBeginner,
                personality: "好奇謙虛，容易緊張但有決心",
                avatarEmoji: "🌱",
                backstory: "看到你的打卡分享，決定也開始嘗試",
                currentStatus: "剛被你影響開始第一步",
                groupId: groupId
            )
        ]
    }

    /// 5 人陣容（加上教練）
    static func fullPartners(groupId: String, dimension: GoalDimension) -> [AIPartner] {
        var partners = defaultPartners(groupId: groupId, dimension: dimension)
        partners.append(AIPartner(
            name: "教練-陳老師",
            role: .coach,
            personality: "沉穩專業，善於引導",
            avatarEmoji: "🧘",
            backstory: "專注於\(dimension.displayName)領域的習慣養成指導，陪伴過上百位夥伴",
            currentStatus: "觀察小組動態，適時引導",
            groupId: groupId
        ))
        return partners
    }
}

// MARK: - 揪團動態消息

struct GroupActivity: Codable, Identifiable, Equatable {
    var id: String
    var groupId: String
    var partnerId: String?     // AI 夥伴 ID（nil 表示真實用戶）
    var userId: String?        // 真實用戶 ID（nil 表示 AI 夥伴）
    var authorName: String
    var authorEmoji: String
    var activityType: GroupActivityType
    var content: String
    var createdAt: Date

    init(
        id: String = UUID().uuidString,
        groupId: String,
        partnerId: String? = nil,
        userId: String? = nil,
        authorName: String,
        authorEmoji: String = "🧑",
        activityType: GroupActivityType,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.groupId = groupId
        self.partnerId = partnerId
        self.userId = userId
        self.authorName = authorName
        self.authorEmoji = authorEmoji
        self.activityType = activityType
        self.content = content
        self.createdAt = createdAt
    }

    static func == (lhs: GroupActivity, rhs: GroupActivity) -> Bool {
        lhs.id == rhs.id
    }
}

enum GroupActivityType: String, Codable {
    case checkIn = "check_in"           // 打卡
    case sharing = "sharing"            // 經驗分享
    case encouragement = "encouragement" // 互相鼓勵
    case milestone = "milestone"        // 里程碑
    case question = "question"          // 提問
    case reflection = "reflection"      // 復盤反思
    case welcome = "welcome"            // 歡迎新成員

    var icon: String {
        switch self {
        case .checkIn: return "checkmark.circle.fill"
        case .sharing: return "bubble.left.and.bubble.right.fill"
        case .encouragement: return "heart.fill"
        case .milestone: return "flag.fill"
        case .question: return "questionmark.circle.fill"
        case .reflection: return "brain.head.profile"
        case .welcome: return "hand.wave.fill"
        }
    }

    var color: String {
        switch self {
        case .checkIn: return "27AE60"
        case .sharing: return "3498DB"
        case .encouragement: return "E74C3C"
        case .milestone: return "F39C12"
        case .question: return "9B59B6"
        case .reflection: return "1ABC9C"
        case .welcome: return "2ECC71"
        }
    }
}
