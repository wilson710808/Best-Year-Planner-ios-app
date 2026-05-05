import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Greeting
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(StringConstants.Dashboard.title)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)

                            if let challenge = challengeViewModel.currentChallenge {
                                Text(StringConstants.Dashboard.currentChallenge)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                Text(StringConstants.Dashboard.noActiveChallenge)
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Active Challenge Card
                    if let challenge = challengeViewModel.currentChallenge {
                        ChallengeCardView(
                            challenge: challenge,
                            todayTask: challengeViewModel.todayTask,
                            isCompleting: challengeViewModel.isCompleting,
                            onComplete: {
                                Task { await challengeViewModel.completeTodayTask() }
                            },
                            onUnlock: {
                                challengeViewModel.showingUnlock = true
                            }
                        )
                        .padding(.horizontal)
                    } else {
                        NoChallengeCardView()
                            .padding(.horizontal)
                    }

                    // Streak & Stats
                    HStack(spacing: 12) {
                        StatCardView(
                            icon: "flame.fill",
                            value: "\(viewModel.weeklyStreakDays)",
                            label: StringConstants.Dashboard.streakDays,
                            color: AppColors.accent
                        )

                        StatCardView(
                            icon: "checkmark.circle.fill",
                            value: "\(viewModel.weeklyTotalCheckIns)",
                            label: StringConstants.Dashboard.totalCheckIns,
                            color: AppColors.success
                        )

                        StatCardView(
                            icon: "chart.line.uptrend.xyaxis",
                            value: String(format: "%.0f%%", viewModel.weeklyCompletionRate * 100),
                            label: StringConstants.Dashboard.thisWeek,
                            color: AppColors.primary
                        )
                    }
                    .padding(.horizontal)

                    // Dimension Progress
                    HStack(spacing: 12) {
                        MiniDimensionProgress(dimension: .career, progress: viewModel.careerProgress)
                        MiniDimensionProgress(dimension: .relationship, progress: viewModel.relationshipProgress)
                        MiniDimensionProgress(dimension: .growth, progress: viewModel.growthProgress)
                    }
                    .padding(.horizontal)

                    // Quick access
                    VStack(alignment: .leading, spacing: 12) {
                        Text("快速操作")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)

                        HStack(spacing: 12) {
                            QuickActionCard(icon: "bubble.left.and.bubble.right.fill", title: "AI教練", color: AppColors.primary) {
                                // Navigate to AI Coach
                            }
                            QuickActionCard(icon: "calendar.badge.clock", title: "每週復盤", color: AppColors.accent) {
                                // Navigate to Review
                            }
                            QuickActionCard(icon: "crown.fill", title: "升級", color: Color(hex: "FFD700")) {
                                challengeViewModel.showingSubscription = true
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 24)
            }
            .background(AppColors.background)
            .onAppear {
                viewModel.loadDashboardData()
                challengeViewModel.loadChallenges()
            }
            .refreshable {
                viewModel.loadDashboardData()
                challengeViewModel.loadChallenges()
            }
            .sheet(isPresented: $challengeViewModel.showingUnlock) {
                ChallengeUnlockView(viewModel: challengeViewModel)
            }
            .sheet(isPresented: $challengeViewModel.showingSubscription) {
                SubscriptionView()
            }
            .sheet(isPresented: $challengeViewModel.showingCompletionCelebration) {
                ChallengeCompletionCelebrationView(challengeViewModel: challengeViewModel)
            }
        }
    }
}

// MARK: - Challenge Card
struct ChallengeCardView: View {
    let challenge: Challenge
    let todayTask: DailyChallengeTask?
    let isCompleting: Bool
    let onComplete: () -> Void
    let onUnlock: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Challenge type header
            HStack {
                Image(systemName: challenge.phase == .sevenDayLaunch ? "bolt.fill" : "flame.fill")
                    .foregroundColor(challenge.phase == .sevenDayLaunch ? AppColors.accent : AppColors.primary)
                Text(challenge.phase == .sevenDayLaunch ? StringConstants.Dashboard.sevenDayLaunch : StringConstants.Dashboard.twentyOneDayChallenge)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(String(format: StringConstants.Dashboard.dayFormat, "\(challenge.currentDayNumber)"))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }

            // Progress bar
            ProgressView(value: challenge.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: challenge.phase == .sevenDayLaunch ? AppColors.accent : AppColors.primary))
                .padding(.vertical, 4)

            HStack {
                Text("\(challenge.completedDays)/\(challenge.totalDays) 天")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                if !challenge.isCompleted {
                    Text(String(format: StringConstants.Dashboard.daysLeft, "\(challenge.totalDays - challenge.completedDays)"))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            // Today's task inline
            if let task = todayTask {
                Divider()

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(StringConstants.Dashboard.todayMission)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)

                        Text(task.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    Spacer()

                    if task.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(AppColors.success)
                    } else {
                        Button(action: onComplete) {
                            if isCompleting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 36, height: 36)
                                    .background(AppColors.primary)
                                    .cornerRadius(18)
                            } else {
                                Image(systemName: "checkmark")
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .frame(width: 36, height: 36)
                                    .background(AppColors.primary)
                                    .cornerRadius(18)
                            }
                        }
                        .disabled(isCompleting)
                    }
                }
            }

            // Unlock button for completed 7-day
            if challenge.isCompleted && challenge.totalDays == AppConstants.Challenge.launchDays {
                Button(action: onUnlock) {
                    HStack {
                        Image(systemName: "lock.open.fill")
                        Text(StringConstants.Onboarding.startChallengeButton)
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.accent)
                    .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
}

// MARK: - No Challenge Card
struct NoChallengeCardView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(AppColors.primary.opacity(0.5))

            Text(StringConstants.Dashboard.noActiveChallenge)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            Button(action: {}) {
                Text(StringConstants.Dashboard.startNewChallenge)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(AppColors.primary)
                    .cornerRadius(20)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Stat Card
struct StatCardView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Mini Dimension Progress
struct MiniDimensionProgress: View {
    let dimension: GoalDimension
    let progress: Double

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: dimension.icon)
                .font(.title3)
                .foregroundColor(Color(hex: dimension.color))

            Text(dimension.displayName)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: dimension.color)))

            Text(String(format: "%.0f%%", progress * 100))
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Quick Action Card
struct QuickActionCard: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(title)
                    .font(.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
}


// MARK: - Challenge Completion Celebration
struct ChallengeCompletionCelebrationView: View {
    @ObservedObject var challengeViewModel: ChallengeViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var goalViewModel = GoalViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "trophy.fill")
                .font(.system(size: 72))
                .foregroundColor(Color(hex: "FFD700"))

            Text("🎉 恭喜完成挑戰！")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text("你已經成功完成21天習慣養成挑戰！
這個習慣已經成為你的一部分。")
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            // 建議下一步
            VStack(alignment: .leading, spacing: 12) {
                Text("接下來你可以...")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                HStack(spacing: 12) {
                    Image(systemName: "target")
                        .foregroundColor(AppColors.primary)
                        .frame(width: 24)
                    Text("設定新的年度目標")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(AppColors.accent)
                        .frame(width: 24)
                    Text("開始新的21天挑戰")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }

                HStack(spacing: 12) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(AppColors.success)
                        .frame(width: 24)
                    Text("查看你的年度進度")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
            .padding(.horizontal)

            Button(action: { dismiss() }) {
                Text("繼續前進")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .background(AppColors.background.ignoresSafeArea())
    }
}
