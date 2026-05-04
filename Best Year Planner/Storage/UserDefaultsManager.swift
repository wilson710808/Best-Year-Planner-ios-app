import Foundation

final class UserDefaultsManager {
    static let shared = UserDefaultsManager()

    private let defaults = UserDefaults.standard

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
        get {
            let rawValue = defaults.integer(forKey: AppConstants.UserDefaultsKeys.themeMode)
            return ThemeMode(rawValue: rawValue) ?? .system
        }
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
                  let language = AppLanguage(rawValue: rawValue) else {
                return .traditionalChinese
            }
            return language
        }
        set { defaults.set(newValue.rawValue, forKey: AppConstants.UserDefaultsKeys.appLanguage) }
    }

    // MARK: - Subscription State
    var subscriptionState: SubscriptionState {
        get {
            guard let data = defaults.data(forKey: AppConstants.UserDefaultsKeys.subscriptionTier),
                  let state = try? JSONDecoder().decode(SubscriptionState.self, from: data) else {
                return SubscriptionState()
            }
            return state
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: AppConstants.UserDefaultsKeys.subscriptionTier)
            }
        }
    }

    // MARK: - Onboarding Answers
    var onboardingAnswers: OnboardingAnswers? {
        get {
            guard let data = defaults.data(forKey: AppConstants.UserDefaultsKeys.onboardingAnswers),
                  let answers = try? JSONDecoder().decode(OnboardingAnswers.self, from: data) else {
                return nil
            }
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

    func clearAll() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        KeychainManager.shared.clearAll()
    }
}

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
