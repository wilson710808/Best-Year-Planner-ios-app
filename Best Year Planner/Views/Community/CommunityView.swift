import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var showCreateGroup = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 16) {
                        // AI 伙伴聊天室入口
                        AIPartnerCardView()
                            .padding(.horizontal)
                            .padding(.top)

                        // 分隔标题
                        HStack {
                            Text("我的揪團")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)

                        if viewModel.groups.isEmpty {
                            EmptyStateView(
                                icon: "person.3.fill",
                                title: "還沒有揪團",
                                message: "創建或加入一個揪團，與小夥伴一起成長！",
                                actionTitle: "創建揪團",
                                action: { showCreateGroup = true }
                            )
                            .padding(.horizontal)
                        } else {
                            ForEach(viewModel.groups) { group in
                                NavigationLink(destination: GroupDetailView(group: group, viewModel: viewModel)) {
                                    GroupCardView(group: group)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle(StringConstants.Community.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateGroup = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showCreateGroup) {
                CreateGroupView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadGroups()
            }
        }
    }
}

struct GroupCardView: View {
    let group: CommunityGroup

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.3.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 4) {
                    Text(group.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(group.theme)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Text("\(group.memberIds.count)人")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary)
                    .cornerRadius(4)
            }

            if !group.groupDescription.isEmpty {
                Text(group.groupDescription)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }

            HStack {
                Label("每日打卡 \(group.dailyCheckInGoal) 次", systemImage: "checkmark.circle")
                    .font(.caption)
                    .foregroundColor(AppColors.secondary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.disabled)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct GroupDetailView: View {
    let group: CommunityGroup
    @ObservedObject var viewModel: CommunityViewModel
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            Picker("", selection: $selectedTab) {
                Text(StringConstants.Community.posts).tag(0)
                Text(StringConstants.Community.leaderboard).tag(1)
            }
            .pickerStyle(.segmented)
            .padding()

            if selectedTab == 0 {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.posts) { post in
                            PostCardView(post: post)
                        }
                    }
                    .padding(.horizontal)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, member in
                            LeaderboardRowView(rank: index + 1, member: member)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .background(AppColors.background)
        .navigationTitle(group.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct PostCardView: View {
    let post: CommunityPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.title2)

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.authorNickname)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(post.createdAt.formatted(AppConstants.DateFormats.displayTime))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()
            }

            Text(post.content)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)

            HStack {
                Button(action: {}) {
                    Label("\(post.likes.count)", systemImage: "heart")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Button(action: {}) {
                    Label("\(post.comments.count)", systemImage: "bubble.left")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct LeaderboardRowView: View {
    let rank: Int
    let member: GroupMember

    var body: some View {
        HStack(spacing: 12) {
            Text("#\(rank)")
                .font(.headline)
                .foregroundColor(rank <= 3 ? AppColors.accent : AppColors.textSecondary)
                .frame(width: 40)

            Image(systemName: "person.circle.fill")
                .foregroundColor(AppColors.primary)
                .font(.title2)

            VStack(alignment: .leading, spacing: 4) {
                Text(member.nickname)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                Text("\(member.totalCheckIns) 次打卡 | \(member.currentStreak) 天連續")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            if member.currentStreak > 0 {
                Image(systemName: "flame.fill")
                    .foregroundColor(AppColors.accent)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct CreateGroupView: View {
    @ObservedObject var viewModel: CommunityViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var theme = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("揪團資訊") {
                    TextField("揪團名稱", text: $name)
                    TextField("主題", text: $theme)
                    TextField("描述", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle(StringConstants.Community.createGroup)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(StringConstants.Common.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(StringConstants.Common.confirm) {
                        viewModel.createGroup(name: name, theme: theme, description: description)
                        dismiss()
                    }
                    .disabled(name.isEmpty || theme.isEmpty)
                }
            }
        }
    }
}
