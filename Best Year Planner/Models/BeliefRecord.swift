import Foundation

// MARK: - 信念轉化記錄

enum BeliefCategory: String, Codable, CaseIterable {
    case ability = "ability"           // 能力相關（我做不到）
    case time = "time"                 // 時間相關（我沒時間）
    case worth = "worth"               // 價值相關（我不夠好）
    case fear = "fear"                 // 恐懼相關（太難了/會失敗）
    case control = "control"           // 控制相關（這沒用/無法改變）
    case general = "general"           // 一般

    var displayName: String {
        switch self {
        case .ability: return "能力"
        case .time: return "時間"
        case .worth: return "價值"
        case .fear: return "恐懼"
        case .control: return "控制"
        case .general: return "一般"
        }
    }

    var icon: String {
        switch self {
        case .ability: return "figure.strengthtraining.traditional"
        case .time: return "clock.fill"
        case .worth: return "heart.fill"
        case .fear: return "shield.fill"
        case .control: return "hand.raised.fill"
        case .general: return "bubble.fill"
        }
    }
}

enum BeliefStatus: String, Codable {
    case active = "active"             // 進行中
    case actionTaken = "action_taken"  // 已採取行動
    case verified = "verified"         // 已驗證（行動證明信念轉化成功）
    case abandoned = "abandoned"       // 已放棄

    var displayName: String {
        switch self {
        case .active: return "進行中"
        case .actionTaken: return "行動中"
        case .verified: return "已驗證"
        case .abandoned: return "已放棄"
        }
    }

    var color: String {
        switch self {
        case .active: return "F5A623"
        case .actionTaken: return "4A90D9"
        case .verified: return "7ED321"
        case .abandoned: return "999999"
        }
    }
}

struct BeliefRecord: Codable, Identifiable {
    var id: String = UUID().uuidString
    var userId: String?
    var limitingBelief: String
    var reframedBelief: String
    var category: BeliefCategory = .general
    var status: BeliefStatus = .active
    var actionTaken: String?
    var actionDate: Date?
    var isVerified: Bool = false
    var verifiedAt: Date?
    var aiGuidance: String?
    var createdAt: Date = Date()
}
