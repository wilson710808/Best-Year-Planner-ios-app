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
    
    // MARK: - 掉鏈子系統
    
    /// 執行夥伴掉鏈子模擬（每天調用一次）
    /// 根據每個夥伴的 missProbability 隨機決定是否漏打卡
    func simulateDailySlacking() {
        guard var group = currentGroup else { return }
        
        for i in 0..<group.buddies.count {
            let buddy = group.buddies[i]
            
            // 僅影響非已完成、非未開始的夥伴
            guard buddy.status == .justStarted || buddy.status == .inProgress else { continue }
            
            // 根據機率決定是否掉鏈子（每天一次機會）
            if Double.random(in: 0...1) < buddy.missProbability {
                // 掉鏈子！
                group.buddies[i].missedDays += 1
                group.buddies[i].lastMissDate = Date()
                
                // 判斷是否進入持續掉鏈子狀態（連續漏卡2天以上）
                let daysSinceLastActive = Calendar.current.dateComponents(
                    [.day], 
                    from: group.buddies[i].lastActiveDate, 
                    to: Date()
                ).day ?? 0
                
                if daysSinceLastActive >= 2 && !group.buddies[i].isCurrentlySlacking {
                    group.buddies[i].isCurrentlySlacking = true
                    group.buddies[i].slackingStartDate = Date()
                }
                
                // 降低連續天數（掉鏈子會中斷streak）
                if group.buddies[i].streak > 0 {
                    group.buddies[i].streak = max(0, group.buddies[i].streak - 1)
                }
            } else {
                // 按時打卡：更新 lastActiveDate，重置掉鏈子狀態
                group.buddies[i].lastActiveDate = Date()
                if group.buddies[i].isCurrentlySlacking {
                    group.buddies[i].isCurrentlySlacking = false
                    group.buddies[i].slackingStartDate = nil
                }
            }
        }
        
        saveGroup(group)
    }
    
    /// 獲取正在掉鏈子的夥伴列表
    func getSlackingBuddies() -> [GrowthBuddy] {
        return currentGroup?.buddies.filter { $0.isCurrentlySlacking } ?? []
    }
    
    /// 獲取漏打卡次數最多的夥伴
    func getMostMissedBuddy() -> GrowthBuddy? {
        return currentGroup?.buddies
            .filter { $0.status != .notStarted && $0.status != .completed }
            .max { $0.missedDays < $1.missedDays }
    }
    
    /// 獲取夥伴掉鏈子統計
    func getSlackingStats() -> (totalMissed: Int, slackingCount: Int, mostMissed: GrowthBuddy?) {
        guard let group = currentGroup else { return (0, 0, nil) }
        let activeBuddies = group.buddies.filter { $0.status != .notStarted && $0.status != .completed }
        let totalMissed = activeBuddies.reduce(0) { $0 + $1.missedDays }
        let slackingCount = activeBuddies.filter { $0.isCurrentlySlacking }.count
        let mostMissed = activeBuddies.max { $0.missedDays < $1.missedDays }
        return (totalMissed, slackingCount, mostMissed)
    }
    
    /// 為夥伴加油（用戶互動，激勵掉鏥子的夥伴）
    func cheerForBuddy(_ buddyId: String) -> String? {
        guard var group = currentGroup,
              let index = group.buddies.firstIndex(where: { $0.id == buddyId }) else {
            return nil
        }
        
        let buddy = group.buddies[index]
        
        // 如果夥伴正在掉鏈子，用戶加油後有 30% 機率讓他振作
        if buddy.isCurrentlySlacking {
            if Double.random(in: 0...1) < 0.3 {
                group.buddies[index].isCurrentlySlacking = false
                group.buddies[index].slackingStartDate = nil
                saveGroup(group)
                return "\(buddy.name) 感受到你的鼓勵，重新振作了！💪"
            } else {
                return "\(buddy.name) 說：'謝謝你，但我今天真的不想動...'"
            }
        }
        
        return "\(buddy.name) 說：'謝謝！有你的支持我更有動力了！'"
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