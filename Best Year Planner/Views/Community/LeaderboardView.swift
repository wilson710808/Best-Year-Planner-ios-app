import SwiftUI

struct LeaderboardView: View {
    let groupId: String
    @StateObject private var viewModel = CommunityViewModel()
    @State private var selectedPeriod = 0 // 0=本週, 1=本月, 2=全部

    var body: some View {
        VStack(spacing: 0) {
            // 時間篩選
            Picker("時間", selection: $selectedPeriod) {
                Text("本週").tag(0)
                Text("本月").tag(1)
                Text("全部").tag(2)
            }
            .pickerStyle(.segmented)
            .padding()

            if viewModel.leaderboard.isEmpty {
                EmptyStateView(
                    icon: "trophy",
                    title: "暫無排行",
                    message: "完成打卡任務，登上排行榜！"
                )
                .padding(.top, 40)
            } else {
                // 前三名高亮
                let topThree = Array(viewModel.leaderboard.prefix(3))
                if topThree.count >= 3 {
                    HStack(spacing: 12) {
                        // 第二名
                        TopThreeCard(member: topThree[1], rank: 2)
                        // 第一名
                        TopThreeCard(member: topThree[0], rank: 1)
                        // 第三名
                        TopThreeCard(member: topThree[2], rank: 3)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }

                // 其餘排行
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(Array(viewModel.leaderboard.dropFirst(3).enumerated()), id: \.element.id) { index, member in
                            HStack(spacing: 12) {
                                Text("#\(index + 4)")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textSecondary)
                                    .frame(width: 40)

                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(AppColors.primary)
                                    .font(.title2)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.nickname)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.textPrimary)

                                    HStack(spacing: 8) {
                                        Text("\(member.totalCheckIns) 次")
                                            .font(.caption)
                                            .foregroundColor(AppColors.textSecondary)

                                        if member.currentStreak > 0 {
                                            Label("\(member.currentStreak)天", systemImage: "flame.fill")
                                                .font(.caption)
                                                .foregroundColor(AppColors.accent)
                                        }
                                    }
                                }

                                Spacer()

                                Text("\(member.longestStreak)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(AppColors.primary)
                                    + Text(" 最長連續")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(StringConstants.Community.leaderboard)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadLeaderboard(forGroupId: groupId)
        }
    }
}

struct TopThreeCard: View {
    let member: GroupMember
    let rank: Int

    private var rankColor: Color {
        switch rank {
        case 1: return Color(hex: "FFD700") // 金色
        case 2: return Color(hex: "C0C0C0") // 銀色
        case 3: return Color(hex: "CD7F32") // 銅色
        default: return AppColors.primary
        }
    }

    private var crownIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "star.fill"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            // 皇冠/獎牌
            Image(systemName: crownIcon)
                .font(rank == 1 ? .title : .title3)
                .foregroundColor(rankColor)

            // 頭像
            Image(systemName: "person.circle.fill")
                .font(rank == 1 ? .system(size: 50) : .system(size: 40))
                .foregroundColor(AppColors.primary)

            // 名字
            Text(member.nickname)
                .font(rank == 1 ? .subheadline : .caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)

            // 打卡數
            Text("\(member.totalCheckIns)")
                .font(rank == 1 ? .title3 : .body)
                .fontWeight(.bold)
                .foregroundColor(AppColors.primary)
                + Text(" 次")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)

            if member.currentStreak > 0 {
                Label("\(member.currentStreak)天", systemImage: "flame.fill")
                    .font(.caption2)
                    .foregroundColor(AppColors.accent)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, rank == 1 ? 20 : 14)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [rankColor.opacity(0.1), Color.white]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(rankColor.opacity(0.3), lineWidth: rank == 1 ? 2 : 1)
        )
    }
}
