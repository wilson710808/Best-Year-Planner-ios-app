import Foundation
import Combine

@MainActor
final class BuddyViewModel: ObservableObject {
    @Published var group: BuddyGroup?
    @Published var selectedBuddy: GrowthBuddy?
    @Published var isLoading: Bool = false
    
    @Published var showBuddyDetail: Bool = false
    @Published var showExperienceShare: Bool = false
    
    private let buddyService = BuddyService.shared
    private let challengeViewModel: ChallengeViewModel
    
    init(challengeViewModel: ChallengeViewModel = .shared) {
        self.challengeViewModel = challengeViewModel
        loadGroup()
    }
    
    // MARK: - Data Loading
    
    func loadGroup() {
        isLoading = true
        group = buddyService.getOrCreateGroup()
        syncWithUserProgress()
        isLoading = false
    }
    
    func syncWithUserProgress() {
        let currentDay = challengeViewModel.currentDay
        buddyService.syncWithUserProgress(userDay: currentDay)
        loadGroup()
    }
    
    // MARK: - Computed Properties
    
    /// 即將開始的夥伴（需要影響）
    var startingBuddies: [GrowthBuddy] {
        group?.buddies.filter { $0.status == .justStarted } ?? []
    }
    
    /// 進行中的夥伴
    var inProgressBuddies: [GrowthBuddy] {
        group?.buddies.filter { $0.status == .inProgress } ?? []
    }
    
    /// 已完成可以分享經驗的夥伴
    var experiencedBuddy: GrowthBuddy? {
        group?.experiencedBuddy
    }
    
    /// 尚未開始等待被影響的夥伴
    var pendingBuddy: GrowthBuddy? {
        group?.pendingBuddy
    }
    
    /// 總夥伴數
    var totalBuddies: Int {
        group?.buddies.count ?? 0
    }
    
    /// 活躍夥伴數
    var activeBuddies: Int {
        group?.buddies.filter { $0.status != .notStarted }.count ?? 0
    }
    
    // MARK: - Actions
    
    func selectBuddy(_ buddy: GrowthBuddy) {
        selectedBuddy = buddy
        showBuddyDetail = true
    }
    
    func dismissDetail() {
        showBuddyDetail = false
        selectedBuddy = nil
    }
    
    func showExperience() {
        showExperienceShare = true
    }
    
    func refreshBuddies() {
        syncWithUserProgress()
    }
    
    // MARK: - Influence Logic
    
    /// 檢查是否可以影響pending夥伴
    var canInfluencePending: Bool {
        let streak = challengeViewModel.currentStreak
        return streak >= 10  // 連續10天可以影響
    }
    
    /// 獲取影響進度
    var influenceProgress: Double {
        let streak = challengeViewModel.currentStreak
        return min(Double(streak) / 10.0, 1.0)
    }
    
    /// 激勵pending夥伴開始
    func inspirePendingBuddy() {
        guard var group = group,
              let pendingIndex = group.buddies.firstIndex(where: { $0.status == .notStarted }) else {
            return
        }
        
        // 檢查是否達到門檻
        guard canInfluencePending else { return }
        
        group.buddies[pendingIndex].status = .justStarted
        group.buddies[pendingIndex].challengeDay = 1
        group.buddies[pendingIndex].inspirationalMessage = "看到你堅持了\(challengeViewModel.currentStreak)天，我也要開始了！"
        group.buddies[pendingIndex].lastActiveDate = Date()
        
        buddyService.updateGroup(group)
        loadGroup()
    }
    
    // MARK: - Statistics
    
    /// 獲取群組統計
    var stats: (total: Int, active: Int, completed: Int) {
        return buddyService.getGroupStats()
    }
}