import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @State private var showBuddyGroup = false
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

                    // Motivation Reminder (if inactive 3+ days)
                    if let motivationCard = getMotivationReminder() {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.circle.fill")
                                    .foregroundColor(AppColors.accent)
                                Text("你的動機提醒")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.accent)
                            }
                            Text(motivationCard)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                                .italic()
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            LinearGradient(colors: [AppColors.accent.opacity(0.05), AppColors.primary.opacity(0.05)],
                                           startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

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

                    // Today's Belief Reminder
                    NavigationLink(destination: PastReviewView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppColors.accent)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("總結過去，規劃未來")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("回顧去年的成就與教訓")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Abandon List Entry
                    NavigationLink(destination: AbandonListView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "scissors")
                                .foregroundColor(AppColors.error)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("更少但更好")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("記錄你決定不做的事")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Belief Tracker Entry
                    NavigationLink(destination: BeliefTrackerView()) {
                        HStack(spacing: 12) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(AppColors.accent)
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("信念追蹤")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                Text("追蹤限制性信念的轉化進度")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.caption)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Dimension Progress
                    HStack(spacing: 12) {
                        MiniDimensionProgress(dimension: .career, progress: viewModel.careerProgress)
                        MiniDimensionProgress(dimension: .relationship, progress: viewModel.relationshipProgress)
                        MiniDimensionProgress(dimension: .growth, progress: viewModel.growthProgress)
                    }
                    .padding(.horizontal)

                    // Quick Check-In Section
                    QuickCheckInSection()
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
                            QuickActionCard(icon: "person.3.fill", title: "揪團成長", color: AppColors.secondary) {
                                showBuddyGroup = true
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

    private func getMotivationReminder() -> String? {
        let tasks = TaskService.shared.getAllTasks().filter { $0.status == .inProgress || $0.status == .pending }
        for task in tasks {
            if let reminder = CheckInService.shared.getMotivationReminder(taskId: task.id) {
                return reminder
            }
        }
        return nil
    }

    private var onAppearBackup: Bool { true }

    private func _onAppear() {
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
            .sheet(isPresented: $showBuddyGroup) {
                BuddyGroupView()
                    .environmentObject(ChallengeViewModel.shared)
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

// MARK: - Quick Check-In Section

struct QuickCheckInSection: View {
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @State private var completedTasks: Set<String> = []
    @State private var showCelebration = false
    @State private var allDone = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundColor(AppColors.success)
                Text("今日快速打卡")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()

                if allDone {
                    Text("🎉 全部完成！")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.success)
                } else {
                    Text("\(completedTasks.count)/\(pendingTasks.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            if pendingTasks.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.title2)
                            .foregroundColor(AppColors.divider)
                        Text("今天沒有待打卡任務")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    Spacer()
                }
                .padding(.vertical, 16)
            } else {
                // Quick one-tap buttons for each task
                VStack(spacing: 8) {
                    ForEach(pendingTasks, id: \.id) { task in
                        quickCheckInRow(task: task)
                    }
                }

                // Batch complete button
                if pendingTasks.filter({ !completedTasks.contains($0.id) }).count > 1 {
                    Button(action: batchCheckIn) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("一鍵全部打卡")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.success)
                        .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .onAppear {
            challengeViewModel.loadChallenges()
        }
        .overlay {
            if showCelebration {
                CheckInCelebrationOverlay()
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { showCelebration = false }
                        }
                    }
            }
        }
    }

    // MARK: - Pending Tasks

    private var pendingTasks: [QuickCheckInTask] {
        var tasks: [QuickCheckInTask] = []

        // Add challenge task if available
        if let challenge = challengeViewModel.currentChallenge,
           let todayTask = challengeViewModel.todayTask,
           !todayTask.isCompleted {
            tasks.append(QuickCheckInTask(
                id: todayTask.id,
                title: todayTask.title,
                subtitle: challenge.phase == .sevenDayLaunch ? "7天啟動" : "21天挑戰",
                icon: challenge.phase == .sevenDayLaunch ? "bolt.fill" : "flame.fill",
                color: challenge.phase == .sevenDayLaunch ? AppColors.accent : AppColors.primary
            ))
        }

        // Add regular tasks
        let regularTasks = TaskService.shared.getTodaysTasks()
        for task in regularTasks {
            let hasCheckedIn = !CheckInService.shared.getCheckIns(forTaskId: task.id).filter {
                Calendar.current.isDate($0.date, inSameDayAs: Date())
            }.isEmpty
            if !hasCheckedIn {
                tasks.append(QuickCheckInTask(
                    id: task.id,
                    title: task.title,
                    subtitle: task.priority.displayName,
                    icon: "checkmark.circle",
                    color: AppColors.primary
                ))
            }
        }

        return tasks
    }

    // MARK: - Quick Check-In Row

    private func quickCheckInRow(task: QuickCheckInTask) -> some View {
        HStack(spacing: 12) {
            Image(systemName: task.icon)
                .foregroundColor(task.color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(completedTasks.contains(task.id) ? AppColors.textSecondary : AppColors.textPrimary)
                    .strikethrough(completedTasks.contains(task.id))

                Text(task.subtitle)
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            if completedTasks.contains(task.id) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(AppColors.success)
            } else {
                Button(action: { completeTask(task) }) {
                    Image(systemName: "circle")
                        .font(.title2)
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Actions

    private func completeTask(_ task: QuickCheckInTask) {
        let result = CheckInService.shared.checkIn(taskId: task.id, status: .completed)
        if case .success = result {
            withAnimation(.spring(response: 0.3)) {
                completedTasks.insert(task.id)
            }
            checkAllDone()
        }
    }

    private func batchCheckIn() {
        let remainingIds = pendingTasks.map { $0.id }.filter { !completedTasks.contains($0) }
        let results = CheckInService.shared.batchCheckIn(taskIds: remainingIds)
        for (taskId, result) in results {
            if case .success = result {
                completedTasks.insert(taskId)
            }
        }
        checkAllDone()
    }

    private func checkAllDone() {
        let allPending = pendingTasks.map { $0.id }
        if Set(allPending).isSubset(of: completedTasks) {
            allDone = true
            showCelebration = true
        }
    }
}

// MARK: - Quick Check-In Task Model

private struct QuickCheckInTask: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

// MARK: - Check-In Celebration Overlay

private struct CheckInCelebrationOverlay: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("🎉")
                .font(.system(size: 48))
            Text("全部完成！")
                .font(.headline)
                .foregroundColor(AppColors.success)
        }
        .padding(24)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 4)
    }
}
