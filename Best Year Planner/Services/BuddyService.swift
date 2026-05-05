import Foundation

/// 生長夥伴服務
final class BuddyService: ObservableObject {
    static let shared = BuddyService()
    
    private let userDefaults = UserDefaultsManager.shared
    private let buddyGroupKey = "buddy_group"
    
    @Published private(set) var currentGroup: BuddyGroup?
    
    private init() {
        loadGroup()
    }
    
    // MARK: - CRUD Operations
    
    func loadGroup() {
        if let data = userDefaults.data(forKey: buddyGroupKey),
           let group = try? JSONDecoder().decode(BuddyGroup.self, from: data) {
            currentGroup = group
        }
    }
    
    func createDefaultGroup() -> BuddyGroup {
        let userId = UserDefaultsManager.shared.currentUserId ?? UUID().uuidString
        let group = BuddyConfiguration.createDefaultGroup(userId: userId, challengeDay: 1)
        saveGroup(group)
        return group
    }
    
    func saveGroup(_ group: BuddyGroup) {
        if let data = try? JSONEncoder().encode(group) {
            userDefaults.setData(data, forKey: buddyGroupKey)
            currentGroup = group
        }
    }
    
    func updateGroup(_ group: BuddyGroup) {
        saveGroup(group)
    }
    
    func resetGroup() {
        userDefaults.remove(forKey: buddyGroupKey)
        currentGroup = nil
    }
    
    // MARK: - Group Management
    
    /// 初始化或獲取夥伴群組
    func getOrCreateGroup() -> BuddyGroup {
        if let group = currentGroup {
            return group
        }
        return createDefaultGroup()
    }
    
    /// 根據用戶挑戰進度更新所有夥伴
    func syncWithUserProgress(userDay: Int) {
        guard var group = currentGroup else {
            let newGroup = BuddyConfiguration.createDefaultGroup(
                userId: UserDefaultsManager.shared.currentUserId ?? UUID().uuidString,
                challengeDay: userDay
            )
            saveGroup(newGroup)
            return
        }
        
        BuddyConfiguration.updateGroupWithProgress(&group, userDay: userDay)
        saveGroup(group)
    }
    
    /// 獲取特定狀態的夥伴列表
    func getBuddies(withStatus status: BuddyStatus) -> [GrowthBuddy] {
        return currentGroup?.buddies(withStatus: status) ?? []
    }
    
    /// 獲取已完成並可分享經驗的夥伴
    func getExperiencedBuddy() -> GrowthBuddy? {
        return currentGroup?.experiencedBuddy
    }
    
    /// 獲取待影響的夥伴
    func getPendingBuddy() -> GrowthBuddy? {
        return currentGroup?.pendingBuddy
    }
    
    /// 根據 ID 獲取夥伴
    func getBuddy(byId id: String) -> GrowthBuddy? {
        return currentGroup?.buddies.first { $0.id == id }
    }
    
    /// 更新單個夥伴
    func updateBuddy(_ buddy: GrowthBuddy) {
        guard var group = currentGroup else { return }
        group.updateBuddy(buddy)
        saveGroup(group)
    }
    
    /// 添加新夥伴
    func addBuddy(_ buddy: GrowthBuddy) {
        guard var group = currentGroup else { return }
        group.buddies.append(buddy)
        group.updatedAt = Date()
        saveGroup(group)
    }
    
    /// 移除夥伴
    func removeBuddy(buddyId: String) {
        guard var group = currentGroup else { return }
        group.buddies.removeAll { $0.id == buddyId }
        group.updatedAt = Date()
        saveGroup(group)
    }
    
    // MARK: - Stats
    
    /// 獲取夥伴群組統計
    func getGroupStats() -> (total: Int, active: Int, completed: Int) {
        guard let group = currentGroup else {
            return (0, 0, 0)
        }
        let active = group.buddies.filter { $0.status == .justStarted || $0.status == .inProgress }.count
        let completed = group.buddies.filter { $0.status == .completed }.count
        return (group.buddies.count, active, completed)
    }
}