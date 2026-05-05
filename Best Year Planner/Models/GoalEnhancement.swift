import Foundation

// MARK: - 限制性信念清單

/// 用戶勾選的限制性信念 + AI 生成的賦能回應
struct LimitingBelief: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var text: String               // 原始限制性信念
    var isSelected: Bool = false   // 用戶是否勾選
    var empoweringResponse: String? // AI 生成的賦能回應
    var reframedText: String?      // 用戶反轉後的開放性信念
    var createdAt: Date = Date()
}

// MARK: - 年度回顧（「總結過去」步驟）

struct YearlyReview: Codable, Identifiable {
    var id: String = UUID().uuidString
    var year: Int                    // 回顧年份
    var topAchievements: [String]   // 最大的3個成就
    var regrets: [String]           // 3個遺憾或挑戰
    var lessonsLearned: [String]    // 從中學到的3個教訓
    var aiExperienceReport: String? // AI 生成的「經驗萃取報告」
    var createdAt: Date = Date()
}

// MARK: - 季度回顧

struct QuarterlyReview: Codable, Identifiable {
    var id: String = UUID().uuidString
    var year: Int
    var quarter: Int                // 1-4
    var achievements: [String]
    var challenges: [String]
    var lessonsLearned: [String]
    var adjustments: [String]       // 下季度需要調整的
    var aiReport: String?
    var createdAt: Date = Date()
}

// MARK: - 目標動機（「找到為什麼」步驟）

struct GoalMotivation: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var goalId: String
    var whys: [String]              // 3個「為什麼我要完成這個目標」
    var aiMotivationCard: String?   // AI 生成的動機卡片文案
    var createdAt: Date = Date()
}

// MARK: - SMARTER 目標評分

struct SMARTERScore: Codable, Identifiable {
    var id: String = UUID().uuidString
    var goalId: String
    var specific: Int       // 1-10
    var measurable: Int     // 1-10
    var actionable: Int     // 1-10
    var risky: Int          // 1-10 風險度
    var timeKeyed: Int      // 1-10
    var exciting: Int       // 1-10 興奮度
    var relevant: Int       // 1-10
    var overallScore: Double { Double(specific + measurable + actionable + risky + timeKeyed + exciting + relevant) / 7.0 }
    var aiSuggestions: [String]? // AI 生成的改進建議
    var createdAt: Date = Date()
}

// MARK: - 領先/滯後指標

enum GoalIndicatorType: String, Codable, CaseIterable {
    case lead = "lead"       // 領先指標（可控制的行動）
    case lag = "lag"         // 滯後指標（結果）

    var displayName: String {
        switch self {
        case .lead: return "領先指標"
        case .lag: return "滯後指標"
        }
    }

    var icon: String {
        switch self {
        case .lead: return "figure.run"
        case .lag: return "chart.line.uptrend.xyaxis"
        }
    }
}

struct GoalIndicator: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var goalId: String
    var type: GoalIndicatorType
    var title: String
    var description: String
    var targetValue: Double?   // 目標值（如：每週3次）
    var currentValue: Double?  // 當前值
    var unit: String?          // 單位（次、分鐘、公斤等）
    var createdAt: Date = Date()
}

// MARK: - 待棄清單（「更少但更好」）

struct AbandonItem: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var title: String           // 決定不做的事情
    var reason: String?         // 為什麼放棄
    var freedUpTime: String?    // 騰出的時間/精力
    var createdAt: Date = Date()
}

// MARK: - 里程碑

struct Milestone: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var goalId: String?
    var title: String
    var description: String
    var achievedAt: Date
    var category: String?       // 事業/人際/成長
    var createdAt: Date = Date()
}

// MARK: - AI 教練風格

enum CoachStyle: String, Codable, CaseIterable {
    case strict = "strict"             // 嚴格軍官型
    case warm = "warm"                 // 溫暖鼓勵型
    case analytical = "analytical"     // 理性分析型
    case humorous = "humorous"         // 幽默夥伴型

    var displayName: String {
        switch self {
        case .strict: return "嚴格軍官"
        case .warm: return "溫暖鼓勵"
        case .analytical: return "理性分析"
        case .humorous: return "幽默夥伴"
        }
    }

    var icon: String {
        switch self {
        case .strict: return "shield.fill"
        case .warm: return "heart.fill"
        case .analytical: return "brain.head.profile"
        case .humorous: return "face.smiling.inverse"
        }
    }

    var systemPromptSuffix: String {
        switch self {
        case .strict:
            return "你的風格是嚴格但公正的軍官型教練。直接指出問題，不粉飾太平，但始終相信用戶的潛力。用短句、指令式語氣。"
        case .warm:
            return "你的風格是溫暖鼓勵型教練。像一個關心你的好朋友，先肯定再建議。多用「我看到你...」「你已經...」開頭。"
        case .analytical:
            return "你的風格是理性分析型教練。用數據和邏輯說話，幫助用戶看清客觀事實。多用百分比、對比、趨勢分析。"
        case .humorous:
            return "你的風格是幽默夥伴型教練。用輕鬆的語氣化解壓力，偶爾開個小玩笑，但不失深度。像一個有趣又靠譜的朋友。"
        }
    }
}

// MARK: - 補卡記錄

struct MakeUpCheckIn: Codable, Identifiable {
    var id: String = UUID().uuidString
    var originalDate: Date        // 原本應打卡的日期
    var reason: String            // 為什麼錯過
    var reflection: String        // 反思
    var madeUpAt: Date = Date()   // 補卡時間
}
