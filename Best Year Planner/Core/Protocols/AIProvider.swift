import Foundation

// MARK: - AI Provider Protocol

/// AI 服務提供者接口，支持熱插拔不同實現
public protocol AIProvider: Sendable {
    var name: String { get }
    
    // 核心功能
    func query(userId: String, query: String) async -> String
    
    // 挑戰生成
    func generateSevenDayLaunchPlan(answers: [String], userId: String) async -> SevenDayLaunchPlan?
    func generateTwentyOneDayChallenge(goalId: String, completedLaunch: Challenge, userId: String) async -> [DailyChallengeTask]?
    
    // 日常功能
    func generateDailyTip(challengeId: String, dayNumber: Int, previousDays: [DailyChallengeTask], userId: String) async -> String
    
    // 教練功能
    func getCoachResponse(userId: String, query: String, conversationHistory: [AIMessage]) async -> String
    func getPartnerResponse(userId: String, query: String, partnerName: String, conversationHistory: [AIMessage]) async -> String
    
    // 摘要生成
    func generateWeeklyReviewSummary(checkIns: [CheckIn], tasks: [Task]) async -> String
    func generateAISuggestion(forType type: ReviewType, data: [String: Any]) async -> String
}

// MARK: - Storage Provider Protocol

/// 數據存儲提供者接口，支持切換不同存儲實現
public protocol StorageProvider: Sendable {
    func save<T: Codable>(_ item: T, forKey key: String) async throws
    func load<T: Codable>(forKey key: String) async throws -> T?
    func remove(forKey key: String) async throws
}

// MARK: - Auth Provider Protocol

/// 認證服務提供者接口
public protocol AuthProvider: Sendable {
    var isAuthenticated: Bool { get }
    var currentUserId: String? { get }
    
    func login(account: String, password: String) async throws -> User
    func register(account: String, password: String, nickname: String) async throws -> User
    func logout() async
    func getCurrentUser() async -> User?
}

// MARK: - Notification Provider Protocol

/// 通知服務提供者接口
public protocol NotificationProvider: Sendable {
    func requestAuthorization() async -> Bool
    func scheduleLocalNotification(title: String, body: String, date: Date, identifier: String) async throws
    func cancelNotification(identifier: String) async
    func cancelAllNotifications() async
}

// MARK: - Subscription Provider Protocol

/// 訂閱服務提供者接口
public protocol SubscriptionProvider: Sendable {
    var isPremium: Bool { get }
    var maxFreeChallenges: Int { get }
    
    func purchasePremium() async throws
    func restorePurchases() async throws
    func checkSubscriptionStatus() async -> SubscriptionStatus
}

// MARK: - Provider Factory

/// 提供者工廠，根據環境返回不同實現
public enum ProviderFactory {
    
    #if DEBUG
    /// 調試環境使用 Mock 實現
    public static func makeAIProvider() -> any AIProvider {
        return MockAIService()
    }
    
    public static func makeStorageProvider() -> any StorageProvider {
        return MockStorageProvider()
    }
    #else
    /// 生產環境使用真實實現
    public static func makeAIProvider() -> any AIProvider {
        return AIService.shared
    }
    
    public static func makeStorageProvider() -> any StorageProvider {
        return UserDefaultsStorageProvider()
    }
    #endif
    
    // 始终使用真实实现的服务
    public static func makeAuthProvider() -> any AuthProvider {
        return AuthService.shared
    }
    
    public static func makeNotificationProvider() -> any NotificationProvider {
        return NotificationManager.shared
    }
    
    public static func makeSubscriptionProvider() -> any SubscriptionProvider {
        return StoreKitService.shared
    }
}