import Foundation

enum AppConstants {
    static let appName = "最好的一年"
    static let bundleId = "com.bestyear.planner"

    enum UserDefaultsKeys {
        static let isFirstLaunch = "isFirstLaunch"
        static let isOnboardingCompleted = "isOnboardingCompleted"
        static let lastSyncDate = "lastSyncDate"
        static let themeMode = "themeMode"
        static let notificationEnabled = "notificationEnabled"
        static let dailyReminderTime = "dailyReminderTime"
        static let weeklyReviewReminderDay = "weeklyReviewReminderDay"
        static let appLanguage = "appLanguage"
        static let subscriptionTier = "subscriptionTier"
        static let activeChallengeCount = "activeChallengeCount"
        static let onboardingAnswers = "onboardingAnswers"
    }

    enum KeychainKeys {
        static let account = "userAccount"
        static let password = "userPassword"
        static let userId = "userId"
    }

    enum APIEndpoints {
        static let baseURL = "https://api.bestyearplanner.com"
        static let auth = "/api/auth"
        static let sync = "/api/sync"
        static let ai = "/api/ai"
    }

    enum AI {
        static let gatewayBaseURL = "https://www.herelai.fun"
        static let gatewayEndpoint = "/ws/05-ai-gateway/api/query"
        static let appId = "bestyearplanner"
    }

    enum Challenge {
        static let launchDays = 7
        static let challengeDays = 21
        static let maxFreeChallenges = 3
        static let defaultTaskMinutes = 5
    }

    enum DateFormats {
        static let fullDate = "yyyy-MM-dd"
        static let monthYear = "yyyy-MM"
        static let weekYear = "yyyy-'W'ww"
        static let displayDate = "yyyy年MM月dd日"
        static let displayTime = "HH:mm"
        static let displayDateTime = "yyyy年MM月dd日 HH:mm"
    }

    enum NotificationIdentifiers {
        static let dailyReminder = "dailyReminder"
        static let weeklyReview = "weeklyReview"
        static let monthlyReview = "monthlyReview"
        static let yearlyReview = "yearlyReview"
        static let streakReminder = "streakReminder"
        static let challengeDayReminder = "challengeDayReminder"
    }
}
