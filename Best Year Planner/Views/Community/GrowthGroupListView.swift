import SwiftUI

// MARK: - 揪團成長主頁

struct GrowthGroupListView: View {
    @StateObject private var viewModel = GrowthGroupViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // 概念說明卡片
                        GrowthGroupIntroCard()

                        // 我的揪團列表
                        if viewModel.groups.isEmpty {
                            EmptyStateView(
                                icon: "person.3.fill",
                                title: "還沒有揪團",
                                message: "揪 3-5 位 AI 夥伴一起成長！\n有同行者、過來人、新手陪你走",
                                actionTitle: "創建揪團",
                                action: { viewModel.showCreateGroup = true }
                            )
                            .padding(.horizontal)
                        } else {
                            ForEach(viewModel.groups) { group in
                                NavigationLink(destination: GrowthGroupDetailView(group: group)) {
                                    GrowthGroupCardView(group: group)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("AI夥伴揪團")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showCreateGroup = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $viewModel.showCreateGroup) {
                CreateGrowthGroupView(viewModel: viewModel)
            }
            .onAppear { viewModel.loadGroups() }
        }
    }
}

// MARK: - 概念說明卡片

struct GrowthGroupIntroCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "person.3.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.primary)
                Text("揪團一起成長")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }

            VStack(alignment: .leading, spacing: 10) {
                PartnerRolePreview(role: .fellowStarter, count: "×2")
                PartnerRolePreview(role: .experiencedGuide, count: "×1")
                PartnerRolePreview(role: .inspiredBeginner, count: "×1")
            }

            Text("3-5 位 AI 夥伴各有角色，陪你走完全程")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

struct PartnerRolePreview: View {
    let role: AIPartnerRole
    let count: String

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color(hex: role.color).opacity(0.2))
                .frame(width: 28, height: 28)
                .overlay(
                    Image(systemName: role.icon)
                        .font(.caption)
                        .foregroundColor(Color(hex: role.color))
                )

            Text(role.displayName)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)

            Text(count)
                .font(.caption)
                .foregroundColor(Color(hex: role.color))
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(hex: role.color).opacity(0.1))
                .cornerRadius(4)

            Spacer()

            Text(roleBrief)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
    }

    private var roleBrief: String {
        switch role {
        case .fellowStarter: return "一起摸索"
        case .experiencedGuide: return "分享經驗"
        case .inspiredBeginner: return "被你影響"
        case .coach: return "適時引導"
        }
    }
}

// MARK: - 揪團卡片

struct GrowthGroupCardView: View {
    let group: GrowthGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(Color(hex: group.dimension.color).opacity(0.2))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: group.dimension.icon)
                            .font(.body)
                            .foregroundColor(Color(hex: group.dimension.color))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    Text(group.theme)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                Spacer()

                // 進度環
                ZStack {
                    Circle()
                        .stroke(AppColors.disabled.opacity(0.3), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: CGFloat(group.dayNumber) / CGFloat(group.totalDays))
                        .stroke(Color(hex: group.dimension.color), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    Text("\(group.dayNumber)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(width: 36, height: 36)
            }

            // 夥伴頭像列表
            HStack(spacing: -8) {
                ForEach(group.aiPartners) { partner in
                    Text(partner.avatarEmoji)
                        .font(.title3)
                        .frame(width: 32, height: 32)
                        .background(Color(hex: partner.role.color).opacity(0.15))
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                }

                Text("你")
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(width: 32, height: 32)
                    .background(AppColors.primary.opacity(0.15))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .padding(.leading, 4)

            if !group.groupMilestone.isEmpty {
                Text(group.groupMilestone)
                    .font(.caption)
                    .foregroundColor(Color(hex: group.dimension.color))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: group.dimension.color).opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

// MARK: - 創建揪團

struct CreateGrowthGroupView: View {
    @ObservedObject var viewModel: GrowthGroupViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("揪團資訊") {
                    TextField("揪團名稱", text: $viewModel.createGroupName)
                    TextField("成長主題", text: $viewModel.createGroupTheme)
                }

                Section("成長維度") {
                    Picker("維度", selection: $viewModel.createGroupDimension) {
                        ForEach(GoalDimension.allCases) { dim in
                            Label(dim.displayName, systemImage: dim.icon)
                                .tag(dim)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("挑戰天數") {
                    Picker("天數", selection: $viewModel.createGroupTotalDays) {
                        Text("7 天").tag(7)
                        Text("14 天").tag(14)
                        Text("21 天").tag(21)
                        Text("30 天").tag(30)
                    }
                    .pickerStyle(.segmented)
                }

                Section("AI 夥伴配置") {
                    // 預覽夥伴陣容
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(GrowthGroup.defaultPartners(groupId: "", dimension: viewModel.createGroupDimension)) { partner in
                            HStack(spacing: 10) {
                                Text(partner.avatarEmoji)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("\(partner.name) — \(partner.role.displayName)")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text(partner.backstory)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .lineLimit(1)
                                }
                            }
                        }

                        Toggle("加入教練（5人陣容）", isOn: $viewModel.createGroupIncludeCoach)
                    }
                }
            }
            .navigationTitle("創建揪團")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("創建") {
                        viewModel.createGroup()
                        dismiss()
                    }
                    .disabled(viewModel.createGroupName.isEmpty || viewModel.createGroupTheme.isEmpty)
                }
            }
        }
    }
}
