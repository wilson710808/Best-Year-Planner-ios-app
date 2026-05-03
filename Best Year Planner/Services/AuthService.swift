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

        if password.count < 4 {
            return .failure(.invalidPassword)
        }

        if nickname.count < 1 {
            return .failure(.invalidNickname)
        }

        if database.getUser(byAccount: account) != nil {
            return .failure(.accountAlreadyExists)
        }

        let passwordHash = hashPassword(password)

        let user = User(
            account: account,
            passwordHash: passwordHash,
            nickname: nickname,
            gender: gender,
            birthYear: birthYear
        )

        if database.saveUser(user) {
            userDefaults.savedAccount = account
            userDefaults.savedPassword = password
            userDefaults.currentUserId = user.id
            return .success(user)
        } else {
            return .failure(.databaseError)
        }
    }

    func login(account: String, password: String) -> Result<User, AuthError> {
        guard let user = database.getUser(byAccount: account) else {
            return .failure(.userNotFound)
        }

        let passwordHash = hashPassword(password)
        if user.passwordHash != passwordHash {
            return .failure(.wrongPassword)
        }

        userDefaults.savedAccount = account
        userDefaults.savedPassword = password
        userDefaults.currentUserId = user.id

        return .success(user)
    }

    func autoLogin() -> Result<User, AuthError> {
        guard let account = userDefaults.savedAccount,
              let password = userDefaults.savedPassword else {
            return .failure(.noSavedCredentials)
        }

        return login(account: account, password: password)
    }

    func logout() {
        userDefaults.savedAccount = nil
        userDefaults.savedPassword = nil
        userDefaults.currentUserId = nil
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
        guard let user = getCurrentUser() else {
            return .failure(.userNotFound)
        }

        let oldPasswordHash = hashPassword(oldPassword)
        if user.passwordHash != oldPasswordHash {
            return .failure(.wrongPassword)
        }

        if newPassword.count < 4 {
            return .failure(.invalidPassword)
        }

        var updatedUser = user
        updatedUser.passwordHash = hashPassword(newPassword)

        if database.saveUser(updatedUser) {
            userDefaults.savedPassword = newPassword
            return .success(())
        } else {
            return .failure(.databaseError)
        }
    }

    private func hashPassword(_ password: String) -> String {
        let data = Data(password.utf8)
        let hash = SHA256.hash(data: data)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }

    func createTestUserIfNeeded() {
        let testAccount = "test"
        if database.getUser(byAccount: testAccount) == nil {
            let passwordHash = hashPassword("test")
            let testUser = User(
                account: testAccount,
                passwordHash: passwordHash,
                nickname: "測試用戶",
                gender: nil,
                birthYear: nil
            )
            _ = database.saveUser(testUser)
        }
    }

    func validateLoginCredentials(account: String, password: String) -> (isValid: Bool, error: AuthError?) {
        if account.count < 4 {
            return (false, .invalidAccount)
        }
        if password.count < 4 {
            return (false, .invalidPassword)
        }
        return (true, nil)
    }

    func validateRegistrationCredentials(account: String, password: String, confirmPassword: String, nickname: String) -> (isValid: Bool, error: AuthError?) {
        if account.count < 4 {
            return (false, .invalidAccount)
        }
        if password.count < 4 {
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
        case .invalidAccount:
            return "帳號格式不正確，請至少輸入4個字符"
        case .invalidPassword:
            return "密碼格式不正確，請至少輸入4個字符"
        case .invalidNickname:
            return "暱稱不能為空"
        case .accountAlreadyExists:
            return "此帳號已經存在"
        case .userNotFound:
            return "找不到此用戶"
        case .wrongPassword:
            return "密碼錯誤"
        case .databaseError:
            return "資料庫錯誤"
        case .noSavedCredentials:
            return "沒有已儲存的登入資訊"
        case .passwordMismatch:
            return "兩次輸入的密碼不一致"
        }
    }
}