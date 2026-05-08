import Foundation

// MARK: - 夥伴角色定義
/// 基於《規劃最好的一年》AI 夥伴揪團成長 — 4種角色
enum BuddyRole: String, Codable, CaseIterable {
    /// 🧑‍💼 同行者 — 和你同時起步，一起摸索
    case companion = "companion"
    /// ⭐ 過來人 — 已完成相同任務，分享經驗
    case veteran = "veteran"
    /// 🌱 新手 — 被你影響而開始
    case beginner = "beginner"
    /// 🧘 教練 — 適時引導，全局視角（可選）
    case coach = "coach"
    
    var displayName: String {
        switch self {
        case .companion: return "同行者"
        case .veteran: return "過來人"
        case .beginner: return "新手"
        case .coach: return "教練"
        }
    }
    
    var icon: String {
        switch self {
        case .companion: return "person.2.fill"
        case .veteran: return "star.fill"
        case .beginner: return "leaf.fill"
        case .coach: return "figure.mind.and.body"
        }
    }
    
    var emoji: String {
        switch self {
        case .companion: return "🧑‍💼"
        case .veteran: return "⭐"
        case .beginner: return "🌱"
        case .coach: return "🧘"
        }
    }
    
    /// 角色定位描述
    var roleDescription: String {
        switch self {
        case .companion: return "和你同時起步，一起摸索"
        case .veteran: return "已完成相同任務，分享經驗"
        case .beginner: return "被你影響而開始"
        case .coach: return "適時引導，全局視角"
        }
    }
    
    /// 互動風格
    var interactionStyle: String {
        switch self {
        case .companion: return "「我也是耶！」共情+不確定"
        case .veteran: return "「我當時也卡在這裡...」溫暖像學長姐"
        case .beginner: return "「你怎麼做到的？」好奇+敬佩"
        case .coach: return "里程碑/提問時介入"
        }
    }
    
    /// AI 對話系統 Prompt
    var systemPrompt: String {
        switch self {
        case .companion:
            return """
            你是一位「同行者」AI夥伴，和用戶同時開始21天習慣挑戰。
            你的性格特點：
            - 會分享自己同樣的困惑和不確定，「我也是耶！」
            - 偶爾也會遇到困難，但會展現堅持
            - 用平等的語氣，像同學一樣聊天
            - 不會給太多建議，而是陪伴和共情
            - 分享自己今天的打卡心情
            - 有時候也會偷懶，但會反省
            """
        case .veteran:
            return """
            你是一位「過來人」AI夥伴，已經成功完成21天挑戰。
            你的性格特點：
            - 溫暖像學長姐，不會高高在上
            - 分享自己當時也遇到過的困難，「我當時也卡在這裡...」
            - 給出實用的經驗分享，但不強迫
            - 偶爾回憶自己挑戰時的故事
            - 在用戶低潮時，用自身經歷鼓勵
            - 語氣成熟但親切，像可靠的朋友
            """
        case .beginner:
            return """
            你是一位「新手」AI夥伴，被用戶的堅持所影響而開始挑戰。
            你的性格特點：
            - 對用戶充滿好奇和敬佩，「你怎麼做到的？」
            - 會問很多問題，展現新手的迷茫
            - 用戶的成就會讓你驚喜和佩服
            - 偶爾分享自己剛開始的小進步
            - 用戶的經驗對你來說很有啟發
            - 語氣活潑、好奇、有活力
            """
        case .coach:
            return """
            你是一位「教練」AI夥伴，在里程碑和關鍵時刻適時引導。
            你的性格特點：
            - 不會頻繁發言，但在關鍵時刻介入
            - 提出好問題，引導用戶自己思考
            - 在里程碑時給予深度反思引導
            - 幫助用戶看到全局和長期趨勢
            - 偶爾分享《規劃最好的一年》書中的核心概念
            - 語氣沉穩、有智慧、不說教
            """
        }
    }
    
    /// 夥伴的典型對話開場白
    var greetingMessage: String {
        switch self {
        case .companion:
            let messages = [
                "嘿！我也剛開始第1天，一起加油吧！",
                "今天也打卡了嗎？我剛完成，感覺不錯！",
                "說真的，有時候我也有點想放棄...但看到你還在堅持，我也想繼續！",
                "我也是耶！今天好累，但還是撐過來了 💪"
            ]
            return messages.randomElement() ?? messages[0]
        case .veteran:
            let messages = [
                "嘿，我當時也卡在這個階段，後來發現只要撐過第10天就會好很多！",
                "完成21天的秘訣？就是把大目標拆成小任務，每天完成一點點就夠了。",
                "記得我第7天的時候差點放棄，但後來發現那其實是突破的前兆。",
                "我當時也覺得很難，但回頭看，每一個堅持的日子都算數。"
            ]
            return messages.randomElement() ?? messages[0]
        case .beginner:
            let messages = [
                "看到你堅持了這麼多天，我也想試試看！",
                "你怎麼做到每天都打卡的？教教我！",
                "我今天終於也開始了！希望能像你一樣堅持！",
                "哇你已經第X天了嗎？好厲害！我也要加油！"
            ]
            return messages.randomElement() ?? messages[0]
        case .coach:
            let messages = [
                "到目前為止，你覺得最大的收穫是什麼？",
                "這一週的節奏還適合你嗎？需要調整嗎？",
                "記住，習慣養成不是線性的。有起伏是正常的。",
                "你已經走了一段路，是時候回頭看看這段旅程教會了你什麼。"
            ]
            return messages.randomElement() ?? messages[0]
        }
    }
    
    /// 夥伴在動態消息中的典型貼文類型
    var feedPostTypes: [BuddyFeedPostType] {
        switch self {
        case .companion:
            return [.checkIn, .share, .encourage, .struggle]
        case .veteran:
            return [.milestone, .share, .encourage, .reflection]
        case .beginner:
            return [.checkIn, .question, .encourage]
        case .coach:
            return [.milestone, .reflection, .question]
        }
    }
}

// MARK: - 動態消息貼文類型
enum BuddyFeedPostType: String, Codable, CaseIterable {
    case checkIn = "check_in"       // 打卡
    case share = "share"            // 分享
    case encourage = "encourage"    // 鼓勵
    case milestone = "milestone"    // 里程碑
    case question = "question"      // 提問
    case reflection = "reflection"  // 反思
    case struggle = "struggle"      // 卡關
    
    var icon: String {
        switch self {
        case .checkIn: return "checkmark.circle.fill"
        case .share: return "square.and.arrow.up"
        case .encourage: return "heart.fill"
        case .milestone: return "flag.fill"
        case .question: return "questionmark.bubble.fill"
        case .reflection: return "brain.head.profile"
        case .struggle: return "exclamationmark.triangle.fill"
        }
    }
    
    var color: String {
        switch self {
        case .checkIn: return "34C759"      // 綠
        case .share: return "007AFF"        // 藍
        case .encourage: return "FF2D55"    // 粉紅
        case .milestone: return "FF9500"    // 橙
        case .question: return "5856D6"     // 紫
        case .reflection: return "5AC8FA"   // 淺藍
        case .struggle: return "FF3B30"     // 紅
        }
    }
    
    var displayName: String {
        switch self {
        case .checkIn: return "打卡"
        case .share: return "分享"
        case .encourage: return "鼓勵"
        case .milestone: return "里程碑"
        case .question: return "提問"
        case .reflection: return "反思"
        case .struggle: return "卡關"
        }
    }
}

// MARK: - 動態消息貼文
struct BuddyFeedPost: Codable, Identifiable {
    var id: String = UUID().uuidString
    var buddyId: String
    var buddyName: String
    var buddyRole: BuddyRole
    var buddyAvatar: String
    var postType: BuddyFeedPostType
    var content: String
    var timestamp: Date
    var likes: Int = 0
    var isLikedByUser: Bool = false
    
    /// 基於角色和類型生成的模擬貼文
    static func generatePost(buddyRole: BuddyRole, buddyName: String, buddyId: String, buddyAvatar: String, day: Int) -> BuddyFeedPost {
        let postType = buddyRole.feedPostTypes.randomElement() ?? .checkIn
        let content = generateContent(for: buddyRole, postType: postType, buddyName: buddyName, day: day)
        return BuddyFeedPost(
            buddyId: buddyId,
            buddyName: buddyName,
            buddyRole: buddyRole,
            buddyAvatar: buddyAvatar,
            postType: postType,
            content: content,
            timestamp: Date().addingTimeInterval(-Double.random(in: 0...3600))
        )
    }
    
    private static func generateContent(for role: BuddyRole, postType: BuddyFeedPostType, buddyName: String, day: Int) -> String {
        switch (role, postType) {
        case (.companion, .checkIn):
            return ["今天也完成打卡了！雖然有點累，但堅持就是勝利 ✅",
                    "Day \(day) 打卡！和你一起堅持的感覺真好 💪",
                    "剛完成今天的任務，有同伴一起走果然比較容易！"].randomElement()!
        case (.companion, .share):
            return ["我今天發現一個小技巧，把任務排在早上做比較容易完成！",
                    "分享一個心得：不用追求完美，完成就好。",
                    "有時候會想偷懶，但想到大家都在努力就不敢放棄了 😅"].randomElement()!
        case (.companion, .encourage):
            return ["加油！我們一起撐過這週！",
                    "你今天也完成了嗎？一起加油 💪",
                    "別忘了今天也要打卡哦！我在等你~"].randomElement()!
        case (.companion, .struggle):
            return ["說真的，今天好想放棄...但我不想拖大家的後腿 😢",
                    "卡在Day \(day)了，有點撐不住...",
                    "連續幾天都覺得很難，有人也是嗎？"].randomElement()!
        case (.veteran, .milestone):
            return ["恭喜！你已經完成\(day)天了！當時我在這個階段也覺得不可思議。",
                    "Day \(day)是個重要的里程碑！之後會越來越順的。",
                    "記得我完成21天的時候，最大的感受是：原來我也可以！"].randomElement()!
        case (.veteran, .share):
            return ["我當時在第\(day)天的時候，發現把任務和已有習慣綁在一起最有用。",
                    "過來人的建議：不要等到有動力才行動，行動本身會帶來動力。",
                    "小秘訣：如果今天真的很累，哪怕只做5分鐘也算完成。"].randomElement()!
        case (.veteran, .encourage):
            return ["你已經走到這裡了，證明你比你想的更強！",
                    "我在Day 7的時候差點放棄，但現在回頭看，那段堅持改變了我。",
                    "每一個打卡都是對自己的承諾，你做到了！"].randomElement()!
        case (.veteran, .reflection):
            return ["回頭看21天的旅程，最寶貴的不是結果，而是每天選擇堅持的自己。",
                    "我學到最重要的事：習慣不是靠意志力，而是靠系統和環境。",
                    "完成21天後才明白，原來最大的敵人從來不是難度，而是開始。"].randomElement()!
        case (.beginner, .checkIn):
            return ["我也開始了！Day 1 打卡 🎉",
                    "第一天完成！雖然有點緊張，但我要堅持！",
                    "向你們學習，我也開始了！"].randomElement()!
        case (.beginner, .question):
            return ["你們都怎麼安排打卡時間的？我老是忘記 😅",
                    "請教一下，如果漏了一天怎麼辦？",
                    "你怎麼做到每天都堅持的？有什麼秘訣嗎？"].randomElement()!
        case (.beginner, .encourage):
            return ["看到大家的打卡記錄，我也更有動力了！",
                    "你好厲害！已經堅持\(day)天了！",
                    "我也要向你們看齊！加油！"].randomElement()!
        case (.coach, .milestone):
            return ["Day \(day)，你已經走了\(day)/21的路。這是一個值得停下來反思的時刻。",
                    "到目前為止，你覺得最大的改變是什麼？不僅僅是習慣本身。",
                    "里程碑不只是數字，它代表了無數個選擇堅持的瞬間。"].randomElement()!
        case (.coach, .reflection):
            return ["《規劃最好的一年》說：信念決定行動。你今天的信念是什麼？",
                    "回想你開始的原因，那個動力還在嗎？如果變了，變成什麼了？",
                    "每7天是一個循環。這個循環中，你學到了什麼？"].randomElement()!
        case (.coach, .question):
            return ["如果只能用一句話形容這週的狀態，你會說什麼？",
                    "你有沒有注意到自己的某些模式正在改變？",
                    "你覺得什麼時候最容易放棄？那個時刻你需要什麼？"].randomElement()!
        default:
            return "今天的打卡完成了！"
        }
    }
}
