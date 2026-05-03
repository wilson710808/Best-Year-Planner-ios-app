import Foundation

enum AppConstants {
    static let appName = "Best Year Planner"
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
        static let doubaoAPIKey = "YOUR_DOUBAN_API_KEY"
        static let doubaoEndpoint = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
        static let qwenAPIKey = "YOUR_QWEN_API_KEY"
        static let qwenEndpoint = "https://dashscope.aliyuncs.com/api/v1/aigc/text-generation"
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
    }
}
