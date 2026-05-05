import SwiftUI

// MARK: - 揪團詳情頁 — 動態消息流 + 夥伴互動

struct GrowthGroupDetailView: View {
    let group: GrowthGroup
    @StateObject private var viewModel = GrowthGroupViewModel()
    @State private var showPartnerChat: AIPartner?
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // 頂部：揪團進度 + 夥伴列表
            GroupHeaderView(group: group)
                .padding(.horizontal)
                .padding(.top)

            // 夥伴列表橫滾
            PartnersHorizontalScrollView(
                group: group,
                onPartnerTap: { partner in showPartnerChat = partner }
            )
            .padding(.horizontal)

            // 分段選擇器
            Picker("", selection: $selectedTab) {
                Text("動態").tag(0)
                Text("夥伴").tag(1)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            if selectedTab == 0 {
                ActivityFeedView(viewModel: viewModel)
            } else {
                PartnersListView(
                    group: group,
                    onPartnerTap: { partner in showPartnerChat = partner }
                )
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $showPartnerChat) { partner in
            PartnerChatSheetView(partner: partner, group: group, viewModel: viewModel)
        }
        .onAppear {
            viewModel.selectGroup(group)
            Task { await viewModel.loadDailyPartnerActivities() }
        }
    }
}

// MARK: - 頂部進度頭

struct GroupHeaderView: View {
    let group: GrowthGroup

    var body: some View {
        VStack(spacing: 8) {
            // 里程碑
            if !group.groupMilestone.isEmpty {
                Text(group.groupMilestone)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        LinearGradient(
                            colors: [Color(hex: group.dimension.color), Color(hex: group.dimension.color).opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(20)
            }

            // 進度條
            HStack(spacing: 8) {
                Text("第 \(group.dayNumber) 天")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                ProgressView(value: Double(group.dayNumber), total: Double(group.totalDays))
                    .tint(Color(hex: group.dimension.color))
                Text("/ \(group.totalDays)")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}

// MARK: - 夥伴橫滾列表

struct PartnersHorizontalScrollView: View {
    let group: GrowthGroup
    let onPartnerTap: (AIPartner) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 用戶自己
                VStack(spacing: 4) {
                    Text("🙋")
                        .font(.title2)
                        .frame(width: 44, height: 44)
                        .background(AppColors.primary.opacity(0.15))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(AppColors.primary, lineWidth: 2))
                    Text("我")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }

                ForEach(group.aiPartners) { partner in
                    Button(action: { onPartnerTap(partner) }) {
                        VStack(spacing: 4) {
                            Text(partner.avatarEmoji)
                                .font(.title2)
                                .frame(width: 44, height: 44)
                                .background(Color(hex: partner.role.color).opacity(0.15))
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color(hex: partner.role.color), lineWidth: 2))
                            Text(partner.name)
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                            Text(partner.role.displayName)
                                .font(.system(size: 9))
                                .foregroundColor(Color(hex: partner.role.color))
                        }
                    }
                }
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - 動態消息流

struct ActivityFeedView: View {
    @ObservedObject var viewModel: GrowthGroupViewModel
    @State private var checkInNote = ""

    var body: some View {
        VStack(spacing: 0) {
            // 消息列表
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.activities) { activity in
                        ActivityCardView(activity: activity)
                    }
                }
                .padding(.horizontal)
            }

            // 底部操作欄
            VStack(spacing: 8) {
                // 快速打卡
                HStack {
                    TextField("打卡心得（選填）", text: $checkInNote)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.cardBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )

                    Button(action: {
                        Task { await viewModel.checkIn(note: checkInNote.isEmpty ? nil : checkInNote) }
                        checkInNote = ""
                    }) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.success)
                    }
                    .disabled(viewModel.isLoading)
                }

                // 分享經驗
                HStack {
                    TextField("分享你的經驗...", text: $viewModel.newSharingContent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.cardBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )

                    Button(action: {
                        Task { await viewModel.shareExperience() }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .font(.body)
                            .foregroundColor(.white)
                            .frame(width: 36, height: 36)
                            .background(viewModel.newSharingContent.isEmpty ? AppColors.disabled : AppColors.primary)
                            .cornerRadius(18)
                    }
                    .disabled(viewModel.newSharingContent.isEmpty || viewModel.isLoading)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(AppColors.cardBackground)
            .shadow(color: .black.opacity(0.05), radius: 4, y: -2)
        }
    }
}

// MARK: - 動態消息卡片

struct ActivityCardView: View {
    let activity: GroupActivity

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // 頭像
            Text(activity.authorEmoji)
                .font(.title2)
                .frame(width: 40, height: 40)
                .background(Color(hex: activity.activityType.color).opacity(0.1))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                // 名字 + 時間
                HStack(spacing: 6) {
                    Text(activity.authorName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)

                    Image(systemName: activity.activityType.icon)
                        .font(.caption2)
                        .foregroundColor(Color(hex: activity.activityType.color))

                    Spacer()

                    Text(activity.createdAt.formatted(.dateTime.hour().minute()))
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }

                // 內容
                Text(activity.content)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - 夥伴列表頁

struct PartnersListView: View {
    let group: GrowthGroup
    let onPartnerTap: (AIPartner) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(group.aiPartners) { partner in
                    Button(action: { onPartnerTap(partner) }) {
                        PartnerDetailCard(partner: partner)
                    }
                }
            }
            .padding()
        }
    }
}

struct PartnerDetailCard: View {
    let partner: AIPartner

    var body: some View {
        HStack(spacing: 12) {
            Text(partner.avatarEmoji)
                .font(.largeTitle)
                .frame(width: 56, height: 56)
                .background(Color(hex: partner.role.color).opacity(0.15))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(partner.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(partner.role.displayName)
                        .font(.caption)
                        .foregroundColor(Color(hex: partner.role.color))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(hex: partner.role.color).opacity(0.1))
                        .cornerRadius(4)
                }

                Text(partner.personality)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                Text(partner.currentStatus)
                    .font(.caption)
                    .foregroundColor(Color(hex: partner.role.color))
            }

            Spacer()

            Image(systemName: "bubble.left.fill")
                .foregroundColor(Color(hex: partner.role.color))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - 夥伴私聊 Sheet

struct PartnerChatSheetView: View {
    let partner: AIPartner
    let group: GrowthGroup
    @ObservedObject var viewModel: GrowthGroupViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 對話列表
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.partnerChatMessages) { message in
                                ChatBubbleView(message: message, isPartner: true)
                                    .id(message.id)
                            }
                        }
                        .padding()
                    }
                    .onChange(of: viewModel.partnerChatMessages.count) {
                        if let last = viewModel.partnerChatMessages.last {
                            withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                        }
                    }
                }

                // 輸入欄
                HStack(spacing: 12) {
                    TextField("和\(partner.name)聊聊...", text: $viewModel.partnerChatInput)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(AppColors.cardBackground)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )

                    Button(action: {
                        Task { await viewModel.sendPartnerChat() }
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(viewModel.partnerChatInput.isEmpty ? AppColors.disabled : Color(hex: partner.role.color))
                            .cornerRadius(22)
                    }
                    .disabled(viewModel.partnerChatInput.isEmpty || viewModel.isPartnerChatLoading)
                }
                .padding()
                .background(AppColors.cardBackground)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("\(partner.avatarEmoji) \(partner.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Text(partner.role.displayName)
                        .font(.caption)
                        .foregroundColor(Color(hex: partner.role.color))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: partner.role.color).opacity(0.1))
                        .cornerRadius(8)
                }
            }
            .onAppear { viewModel.startChatWithPartner(partner) }
            .onDisappear { viewModel.endPartnerChat() }
        }
    }
}
