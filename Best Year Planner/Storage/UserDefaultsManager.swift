import Foundation
import WidgetKit

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let defaults = UserDefaults.standard
    private let appGroupSuiteName = "group.com.bestyearplanner"
    private init() {}

    var isFirstLaunch: Bool {
        get { !defaults.bool(forKey: AppConstants.UserDefaultsKeys.isFirstLaunch) }
        set { defaults.set(!newValue, forKey: AppConstants.UserDefaultsKeys.isFirstLaunch) }
    }

    var isOnboardingCompleted: Bool {
        get { defaults.bool(forKey: AppConstants.UserDefaultsKeys.isOnboardingCompleted) }
        set { defaults.set(newValue, forKey: AppConstants.UserDefaultsKeys.isOnboardingCompleted) }
    }

    var lastSyncDate: Date? {
        get { defaults.object(forKey: AppConstants.UserDefaultsKeys.lastSyncDate) as? Date }
        set { defaults.set(newValue, forKey: AppConstants.UserDefaultsKeys.lastSyncDate) }
    }

    var themeMode: ThemeMode {
        get { ThemeMode(rawValue: defaults.integer(forKey: AppConstants.UserDefaultsKeys.themeMode)) ?? .system }
        set { defaults.set(newValue.rawValue, forKey: AppConstants.UserDefaultsKeys.themeMode) }
    }

    var notificationEnabled: Bool {
        get { defaults.bool(forKey: AppConstants.UserDefaultsKeys.notificationEnabled) }
        set { defaults.set(newValue, forKey: AppConstants.UserDefaultsKeys.notificationEnabled) }
    }

    var dailyReminderTime: Date? {
        get { defaults.object(forKey: AppConstants.UserDefaultsKeys.dailyReminderTime) as? Date }
        set { defaults.set(newValue, forKey: AppConstants.UserDefaultsKeys.dailyReminderTime) }
    }

    var weeklyReviewReminderDay: Int {
        get { defaults.integer(forKey: AppConstants.UserDefaultsKeys.weeklyReviewReminderDay) }
        set { defaults.set(newValue, forKey: AppConstants.UserDefaultsKeys.weeklyReviewReminderDay) }
    }

    var appLanguage: AppLanguage {
        get {
            guard let rawValue = defaults.string(forKey: AppConstants.UserDefaultsKeys.appLanguage),
                  let language = AppLanguage(rawValue: rawValue) else { return .simplifiedChinese }
            return language
        }
        set { defaults.set(newValue.rawValue, forKey: AppConstants.UserDefaultsKeys.appLanguage) }
    }

    // MARK: - Subscription State

    var subscriptionState: SubscriptionState {
        get {
            guard let data = defaults.data(forKey: AppConstants.UserDefaultsKeys.subscriptionTier),
                  let state = try? JSONDecoder().decode(SubscriptionState.self, from: data) else { return SubscriptionState() }
            return state
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: AppConstants.UserDefaultsKeys.subscriptionTier)
            }
        }
    }

    // MARK: - Subscription Details（訂閱過期降級 + 試用期）

    var subscriptionExpirationDate: Date? {
        get { (defaults.object(forKey: "subscriptionExpirationDate") as? Double).map { Date(timeIntervalSince1970: $0) } }
        set {
            if let value = newValue {
                defaults.set(value.timeIntervalSince1970, forKey: "subscriptionExpirationDate")
            } else {
                defaults.removeObject(forKey: "subscriptionExpirationDate")
            }
        }
    }

    var isInFreeTrial: Bool {
        get { defaults.bool(forKey: "isInFreeTrial") }
        set { defaults.set(newValue, forKey: "isInFreeTrial") }
    }

    var freeTrialEndDate: Date? {
        get { (defaults.object(forKey: "freeTrialEndDate") as? Double).map { Date(timeIntervalSince1970: $0) } }
        set {
            if let value = newValue {
                defaults.set(value.timeIntervalSince1970, forKey: "freeTrialEndDate")
            } else {
                defaults.removeObject(forKey: "freeTrialEndDate")
            }
        }
    }

    // MARK: - Onboarding Answers

    var onboardingAnswers: OnboardingAnswers? {
        get {
            guard let data = defaults.data(forKey: AppConstants.UserDefaultsKeys.onboardingAnswers),
                  let answers = try? JSONDecoder().decode(OnboardingAnswers.self, from: data) else { return nil }
            return answers
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: AppConstants.UserDefaultsKeys.onboardingAnswers)
            } else {
                defaults.removeObject(forKey: AppConstants.UserDefaultsKeys.onboardingAnswers)
            }
        }
    }

    // MARK: - Auth (Keychain)

    var currentUserId: String? {
        get { KeychainManager.shared.readString(forKey: AppConstants.KeychainKeys.userId) }
        set {
            if let value = newValue {
                _ = KeychainManager.shared.save(value, forKey: AppConstants.KeychainKeys.userId)
            } else {
                _ = KeychainManager.shared.delete(forKey: AppConstants.KeychainKeys.userId)
            }
        }
    }

    var savedAccount: String? {
        get { KeychainManager.shared.readString(forKey: AppConstants.KeychainKeys.account) }
        set {
            if let value = newValue {
                _ = KeychainManager.shared.save(value, forKey: AppConstants.KeychainKeys.account)
            } else {
                _ = KeychainManager.shared.delete(forKey: AppConstants.KeychainKeys.account)
            }
        }
    }

    /// 僅用於安全清理，不用於登入驗證
    var savedPassword: String? {
        get { KeychainManager.shared.readString(forKey: AppConstants.KeychainKeys.password) }
        set {
            if let value = newValue {
                _ = KeychainManager.shared.save(value, forKey: AppConstants.KeychainKeys.password)
            } else {
                _ = KeychainManager.shared.delete(forKey: AppConstants.KeychainKeys.password)
            }
        }
    }

    /// Session token for auto-login（替代明文密碼）
    var savedSessionToken: String? {
        get { KeychainManager.shared.readString(forKey: AppConstants.KeychainKeys.userId + "_session") }
        set {
            if let value = newValue {
                _ = KeychainManager.shared.save(value, forKey: AppConstants.KeychainKeys.userId + "_session")
            } else {
                _ = KeychainManager.shared.delete(forKey: AppConstants.KeychainKeys.userId + "_session")
            }
        }
    }

    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        KeychainManager.shared.clearAll()
    }
    
    // MARK: - Generic Data Methods
    
    func data(forKey key: String) -> Data? {
        return defaults.data(forKey: key)
    }
    
    func setData(_ data: Data, forKey key: String) {
        defaults.set(data, forKey: key)
    }
    
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    // MARK: - Widget Sync

    /// Sync today's task to widget via App Group UserDefaults
    func syncTodayTaskToWidget(task: DailyChallengeTask, dayNumber: Int, totalDays: Int, dimension: GoalDimension) {
        guard let appGroupDefaults = UserDefaults(suiteName: appGroupSuiteName) else {
            AppLogger.log("Could not access app group UserDefaults", category: AppLogger.general, level: .error)
            return
        }

        let taskDict: [String: Any] = [
            "taskTitle": task.title,
            "taskDescription": task.description,
            "dayNumber": dayNumber,
            "totalDays": totalDays,
            "dimension": dimension.rawValue,
            "aiTip": task.aiTip ?? "",
            "isCompleted": task.isCompleted,
            "updatedAt": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: taskDict, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            appGroupDefaults.set(jsonString, forKey: "todayTask")
            appGroupDefaults.synchronize()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            AppLogger.log("Error encoding today task data for widget: \(error)", category: AppLogger.general, level: .error)
        }
    }
}

// MARK: - Theme Mode

enum ThemeMode: Int, CaseIterable {
    case light = 0
    case dark = 1
    case system = 2

    var displayName: String {
        switch self {
        case .light: return "淺色"
        case .dark: return "深色"
        case .system: return "系統"
        }
    }
}
