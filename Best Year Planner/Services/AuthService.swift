import Foundation
import CryptoKit

final class AuthService {
    static let shared = AuthService()
    private let database = DatabaseManager.shared
    private let userDefaults = UserDefaultsManager.shared
    private init() {}

    func register(account: String, password: String, nickname: String, gender: Gender?, birthYear: Int?) -> Result<User, AuthError> {
        if account.count < 4 {
            return .failure(.invalidAccount)
        }
        if !isPasswordStrong(password) {
            return .failure(.invalidPassword)
        }
        if nickname.count < 1 {
            return .failure(.invalidNickname)
        }
        if database.getUser(byAccount: account) != nil {
            return .failure(.accountAlreadyExists)
        }
        // 先設 savedAccount 以便 hashPassword 使用帳號作為 salt
        userDefaults.savedAccount = account
        let passwordHash = hashPassword(password)
        let user = User(
            account: account,
            passwordHash: passwordHash,
            nickname: nickname,
            gender: gender,
            birthYear: birthYear
        )
        if database.saveUser(user) {
            userDefaults.currentUserId = user.id
            let sessionToken = generateSessionToken()
            userDefaults.savedSessionToken = sessionToken
            return .success(user)
        } else {
            userDefaults.savedAccount = nil
            return .failure(.databaseError)
        }
    }

    func login(account: String, password: String) -> Result<User, AuthError> {
        guard let user = database.getUser(byAccount: account) else {
            return .failure(.userNotFound)
        }
        // 先設 savedAccount 以便 hashPassword 使用帳號作為 salt
        userDefaults.savedAccount = account
        let passwordHash = hashPassword(password)
        if user.passwordHash != passwordHash {
            userDefaults.savedAccount = nil
            return .failure(.wrongPassword)
        }
        // 僅存 account + userId + session token，不存明文密碼
        userDefaults.currentUserId = user.id
        let sessionToken = generateSessionToken()
        userDefaults.savedSessionToken = sessionToken
        return .success(user)
    }

    func autoLogin() -> Result<User, AuthError> {
        guard let userId = userDefaults.currentUserId,
              let _ = userDefaults.savedAccount,
              userDefaults.savedSessionToken != nil else {
            return .failure(.noSavedCredentials)
        }
        // 直接從 DB 取用戶，不重新比對密碼
        guard let user = database.getUser(byId: userId) else {
            // session 無效，清除
            clearSession()
            return .failure(.noSavedCredentials)
        }
        return .success(user)
    }

    func logout() {
        clearSession()
    }

    private func clearSession() {
        userDefaults.savedAccount = nil
        userDefaults.savedPassword = nil
        userDefaults.currentUserId = nil
        userDefaults.savedSessionToken = nil
    }

    func updateUser(_ user: User) -> Result<User, AuthError> {
        if database.saveUser(user) {
            return .success(user)
        } else {
            return .failure(.databaseError)
        }
    }

    func getCurrentUser() -> User? {
        guard let userId = userDefaults.currentUserId else { return nil }
        return database.getUser(byId: userId)
    }

    func changePassword(oldPassword: String, newPassword: String) -> Result<Void, AuthError> {
        guard let user = getCurrentUser() else { return .failure(.userNotFound) }
        let oldPasswordHash = hashPassword(oldPassword)
        if user.passwordHash != oldPasswordHash { return .failure(.wrongPassword) }
        if !isPasswordStrong(newPassword) { return .failure(.invalidPassword) }
        var updatedUser = user
        updatedUser.passwordHash = hashPassword(newPassword)
        if database.saveUser(updatedUser) {
            // 密碼已改，刷新 session
            let sessionToken = generateSessionToken()
            userDefaults.savedSessionToken = sessionToken
            return .success(())
        } else {
            return .failure(.databaseError)
        }
    }

    // MARK: - Security Helpers

    /// 密碼強度驗證：至少8字符，含字母+數字
    private func isPasswordStrong(_ password: String) -> Bool {
        guard password.count >= 8 else { return false }
        let hasLetter = password.unicodeScalars.contains { CharacterSet.letters.contains($0) }
        let hasDigit = password.unicodeScalars.contains { CharacterSet.decimalDigits.contains($0) }
        return hasLetter && hasDigit
    }

    /// 生成隨機 session token（32字符）
    private func generateSessionToken() -> String {
        let length = 32
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var token = ""
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<letters.count)
            token.append(letters[letters.index(letters.startIndex, offsetBy: randomIndex)])
        }
        return token
    }

    /// 密碼 Hash：SHA256 + 每用戶唯一 salt（基於帳號）
    private func hashPassword(_ password: String) -> String {
        let salt = userDefaults.savedAccount ?? "default_salt"
        let salted = password + ":" + salt
        let data = Data(salted.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    #if DEBUG
    func createTestUserIfNeeded() {
        let testAccount = "testuser"
        if database.getUser(byAccount: testAccount) == nil {
            userDefaults.savedAccount = testAccount
            let passwordHash = hashPassword("Test1234")
            let testUser = User(
                account: testAccount,
                passwordHash: passwordHash,
                nickname: "測試用戶",
                gender: nil,
                birthYear: nil
            )
            _ = database.saveUser(testUser)
            userDefaults.savedAccount = nil
        }
    }
    #else
    func createTestUserIfNeeded() {
        // 生產環境不創建測試帳號
    }
    #endif

    func validateLoginCredentials(account: String, password: String) -> (isValid: Bool, error: AuthError?) {
        if account.count < 4 {
            return (false, .invalidAccount)
        }
        if password.count < 8 {
            return (false, .invalidPassword)
        }
        return (true, nil)
    }

    func validateRegistrationCredentials(account: String, password: String, confirmPassword: String, nickname: String) -> (isValid: Bool, error: AuthError?) {
        if account.count < 4 {
            return (false, .invalidAccount)
        }
        if !isPasswordStrong(password) {
            return (false, .invalidPassword)
        }
        if password != confirmPassword {
            return (false, .passwordMismatch)
        }
        if nickname.count < 1 {
            return (false, .invalidNickname)
        }
        if database.getUser(byAccount: account) != nil {
            return (false, .accountAlreadyExists)
        }
        return (true, nil)
    }
}

enum AuthError: Error, LocalizedError {
    case invalidAccount
    case invalidPassword
    case invalidNickname
    case accountAlreadyExists
    case userNotFound
    case wrongPassword
    case databaseError
    case noSavedCredentials
    case passwordMismatch

    var errorDescription: String? {
        switch self {
        case .invalidAccount: return "帳號格式不正確，請至少輸入4個字符"
        case .invalidPassword: return "密碼格式不正確，請至少輸入8個字符且包含字母和數字"
        case .invalidNickname: return "暱稱不能為空"
        case .accountAlreadyExists: return "此帳號已經存在"
        case .userNotFound: return "找不到此用戶"
        case .wrongPassword: return "密碼錯誤"
        case .databaseError: return "資料庫錯誤"
        case .noSavedCredentials: return "沒有已儲存的登入資訊"
        case .passwordMismatch: return "兩次輸入的密碼不一致"
        }
    }
}
