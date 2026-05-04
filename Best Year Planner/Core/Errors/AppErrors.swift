import Foundation

// MARK: - AI Service Errors

enum AIServiceError: Error, LocalizedError {
    case invalidURL
    case networkError(URLError)
    case invalidResponse
    case serverError(Int)
    case parsingError
    case emptyResponse
    case timeout
    case noInternet
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "抱歉，服務位址配置錯誤。"
        case .networkError(let error):
            return "抱歉，網路連線失敗：\(error.localizedDescription)"
        case .invalidResponse:
            return "抱歉，服務響應異常。"
        case .serverError(let code):
            return "抱歉，服務暫時不可用（錯誤碼: \(code)）。"
        case .parsingError:
            return "抱歉，無法解析服務響應。"
        case .emptyResponse:
            return "抱歉，服務未返回有效內容。"
        case .timeout:
            return "抱歉，連線超時。請稍後再試。"
        case .noInternet:
            return "抱歉，網路連線失敗。請檢查您的網路連線。"
        }
    }
}

// MARK: - Database Errors

enum DatabaseError: Error, LocalizedError {
    case openFailed
    case prepareFailed
    case executeFailed
    case queryFailed
    case notFound
    case duplicateEntry
    
    var errorDescription: String? {
        switch self {
        case .openFailed:
            return "無法打開數據庫"
        case .prepareFailed:
            return "SQL 準備失敗"
        case .executeFailed:
            return "SQL 執行失敗"
        case .queryFailed:
            return "查詢失敗"
        case .notFound:
            return "記錄不存在"
        case .duplicateEntry:
            return "記錄已存在"
        }
    }
}

// MARK: - Validation Errors

enum ValidationError: Error, LocalizedError {
    case emptyField(String)
    case invalidFormat(String)
    case tooShort(String, Int)
    case tooLong(String, Int)
    
    var errorDescription: String? {
        switch self {
        case .emptyField(let name):
            return "\(name)不能為空"
        case .invalidFormat(let name):
            return "\(name)格式不正確"
        case .tooShort(let name, let min):
            return "\(name)不能少於\(min)個字符"
        case .tooLong(let name, let max):
            return "\(name)不能超過\(max)個字符"
        }
    }
}

// MARK: - Auth Errors

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case userNotFound
    case accountAlreadyExists
    case passwordTooWeak
    case sessionExpired
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "帳號或密碼錯誤"
        case .userNotFound:
            return "用戶不存在"
        case .accountAlreadyExists:
            return "該帳號已被註冊"
        case .passwordTooWeak:
            return "密碼強度不足，請使用更強的密碼"
        case .sessionExpired:
            return "登錄會話已過期，請重新登錄"
        }
    }
}

// MARK: - Subscription Errors

enum SubscriptionError: Error, LocalizedError {
    case purchaseFailed
    case restoreFailed
    case notEligible
    case alreadySubscribed
    case limitReached
    
    var errorDescription: String? {
        switch self {
        case .purchaseFailed:
            return "購買失敗，請稍後再試"
        case .restoreFailed:
            return "恢復購買失敗"
        case .notEligible:
            return "您不符合此訂閱資格"
        case .alreadySubscribed:
            return "您已經訂閱了此服務"
        case .limitReached:
            return "已達到同時進行挑戰的上限"
        }
    }
}