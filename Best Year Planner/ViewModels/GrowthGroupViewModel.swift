import Foundation
import Combine

@MainActor
final class GrowthGroupViewModel: ObservableObject {
    @Published var groups: [GrowthGroup] = []
    @Published var selectedGroup: GrowthGroup?
    @Published var activities: [GroupActivity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var newSharingContent: String = ""
    @Published var showCreateGroup: Bool = false
    @Published var isChattingWithPartner: AIPartner?
    @Published var partnerChatMessages: [AIMessage] = []
    @Published var partnerChatInput: String = ""
    @Published var isPartnerChatLoading: Bool = false

    // 創建揪團表單
    @Published var createGroupName: String = ""
    @Published var createGroupTheme: String = ""
    @Published var createGroupDimension: GoalDimension = .growth
    @Published var createGroupTotalDays: Int = 21
    @Published var createGroupIncludeCoach: Bool = false

    private let growthService = GrowthGroupService.shared
    private let database = DatabaseManager.shared

    // MARK: - 揪團列表

    func loadGroups() {
        isLoading = true
        groups = growthService.getAllGroups()
        isLoading = false
    }

    func createGroup() {
        guard !createGroupName.isEmpty, !createGroupTheme.isEmpty else { return }
        let group = growthService.createGroup(
            name: createGroupName,
            theme: createGroupTheme,
            dimension: createGroupDimension,
            totalDays: createGroupTotalDays,
            includeCoach: createGroupIncludeCoach
        )
        groups.append(group)
        resetCreateForm()
    }

    private func resetCreateForm() {
        createGroupName = ""
        createGroupTheme = ""
        createGroupDimension = .growth
        createGroupTotalDays = 21
        createGroupIncludeCoach = false
        showCreateGroup = false
    }

    func selectGroup(_ group: GrowthGroup) {
        selectedGroup = group
        loadActivities(forGroupId: group.id)
    }

    func deleteGroup(_ group: GrowthGroup) {
        if growthService.deleteGroup(group.id) {
            groups.removeAll { $0.id == group.id }
            if selectedGroup?.id == group.id {
                selectedGroup = nil
                activities.removeAll()
            }
        }
    }

    // MARK: - 動態消息

    func loadActivities(forGroupId groupId: String) {
        activities = database.getGroupActivities(forGroupId: groupId)
    }

    /// 用戶打卡 — 觸發夥伴互動
    func checkIn(note: String?) async {
        guard let group = selectedGroup else { return }

        // 先添加用戶打卡動態
        let userActivity = GroupActivity(
            groupId: group.id,
            userId: UserDefaultsManager.shared.currentUserId,
            authorName: AuthService.shared.getCurrentUser()?.nickname ?? "我",
            authorEmoji: "🙋",
            activityType: .checkIn,
            content: note ?? "完成今日打卡！💪"
        )
        _ = database.saveGroupActivity(userActivity)
        activities.append(userActivity)

        // 觸發 AI 夥伴回覆
        isLoading = true
        let partnerResponses = await growthService.triggerCheckInInteraction(
            groupId: group.id,
            checkInNote: note
        )
        for response in partnerResponses {
            _ = database.saveGroupActivity(response)
        }
        activities.append(contentsOf: partnerResponses)
        activities.sort { $0.createdAt > $1.createdAt }
        isLoading = false
    }

    /// 用戶分享經驗 — 觸發夥伴互動
    func shareExperience() async {
        guard let group = selectedGroup,
              !newSharingContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userActivity = GroupActivity(
            groupId: group.id,
            userId: UserDefaultsManager.shared.currentUserId,
            authorName: AuthService.shared.getCurrentUser()?.nickname ?? "我",
            authorEmoji: "🙋",
            activityType: .sharing,
            content: newSharingContent
        )
        _ = database.saveGroupActivity(userActivity)
        activities.append(userActivity)

        let content = newSharingContent
        newSharingContent = ""

        isLoading = true
        let partnerResponses = await growthService.triggerSharingInteraction(
            groupId: group.id,
            sharingContent: content
        )
        for response in partnerResponses {
            _ = database.saveGroupActivity(response)
        }
        activities.append(contentsOf: partnerResponses)
        activities.sort { $0.createdAt > $1.createdAt }
        isLoading = false
    }

    /// 載入夥伴每日動態
    func loadDailyPartnerActivities() async {
        guard let group = selectedGroup else { return }
        let dailyActivities = await growthService.generateDailyPartnerActivities(groupId: group.id)
        for activity in dailyActivities {
            _ = database.saveGroupActivity(activity)
        }
        activities.append(contentsOf: dailyActivities)
        activities.sort { $0.createdAt > $1.createdAt }
    }

    // MARK: - 夥伴私聊

    func startChatWithPartner(_ partner: AIPartner) {
        isChattingWithPartner = partner
        partnerChatMessages.removeAll()

        // 添加夥伴的開場白
        let greeting = AIMessage(
            content: "嗨！我是\(partner.name)（\(partner.role.displayName)）\(partner.avatarEmoji) \(partner.currentStatus)，有什麼想聊的嗎？",
            isFromUser: false
        )
        partnerChatMessages.append(greeting)
    }

    func sendPartnerChat() async {
        guard let partner = isChattingWithPartner,
              !partnerChatInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }

        let userMsg = AIMessage(content: partnerChatInput, isFromUser: true)
        partnerChatMessages.append(userMsg)

        let input = partnerChatInput
        partnerChatInput = ""
        isPartnerChatLoading = true

        let response = await growthService.chatWithPartner(
            partnerId: partner.id,
            groupId: selectedGroup?.id ?? "",
            userMessage: input,
            conversationHistory: partnerChatMessages
        )

        let aiMsg = AIMessage(content: response, isFromUser: false)
        partnerChatMessages.append(aiMsg)
        isPartnerChatLoading = false
    }

    func endPartnerChat() {
        isChattingWithPartner = nil
        partnerChatMessages.removeAll()
        partnerChatInput = ""
    }

    // MARK: - 推進天數

    func advanceDay() {
        guard let group = selectedGroup else { return }
        growthService.advancePartnerStatus(groupId: group.id)
        // 重新載入
        if let updated = growthService.getGroup(byId: group.id) {
            selectedGroup = updated
            if let idx = groups.firstIndex(where: { $0.id == group.id }) {
                groups[idx] = updated
            }
        }
    }
}
