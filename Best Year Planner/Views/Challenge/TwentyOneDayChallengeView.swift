import SwiftUI

struct TwentyOneDayChallengeView: View {
    @ObservedObject var viewModel: ChallengeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(StringConstants.Challenge.challengeTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(StringConstants.Challenge.challengeSubtitle)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 16)

                if let challenge = viewModel.currentChallenge {
                    // Progress ring
                    ZStack {
                        ProgressRingView(
                            progress: challenge.progress,
                            size: 140
                        )

                        VStack(spacing: 4) {
                            Text("\(challenge.completedDays)")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primary)
                            Text("/ \(challenge.totalDays) 天")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    // Week progress indicators
                    HStack(spacing: 8) {
                        WeekIndicator(week: 1, title: "建立", completed: min(challenge.completedDays, 7))
                        WeekIndicator(week: 2, title: "深化", completed: max(0, min(challenge.completedDays - 7, 7)))
                        WeekIndicator(week: 3, title: "鞏固", completed: max(0, min(challenge.completedDays - 14, 7)))
                    }
                    .padding(.horizontal)

                    // Milestone
                    if challenge.isCompleted {
                        Text(StringConstants.Challenge.celebration)
                            .font(.headline)
                            .foregroundColor(AppColors.success)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.success.opacity(0.1))
                            .cornerRadius(12)
                            .padding(.horizontal)
                    } else if challenge.completedDays >= 14 {
                        Text(StringConstants.Challenge.almostDone)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(AppColors.accent.opacity(0.1))
                            .cornerRadius(20)
                    }

                    // Today's task
                    if let todayTask = viewModel.todayTask, !todayTask.isCompleted {
                        TodayChallengeTaskCard(
                            task: todayTask,
                            isCompleting: viewModel.isCompleting,
                            showTip: .constant(false),
                            onComplete: {
                                Task { await viewModel.completeTodayTask() }
                            }
                        )
                    } else if let todayTask = viewModel.todayTask, todayTask.isCompleted {
                        CompletedTaskCard(task: todayTask)
                    }

                    // Calendar-style day grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(challenge.dailyTasks) { task in
                            DayGridCell(task: task, isCurrentDay: task.dayNumber == challenge.currentDayNumber)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
    }
}

// MARK: - Week Indicator
struct WeekIndicator: View {
    let week: Int
    let title: String
    let completed: Int

    private var progress: Double {
        guard completed > 0 else { return 0 }
        return Double(min(completed, 7)) / 7.0
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("第\(week)週")
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(progress >= 1.0 ? AppColors.success : AppColors.textPrimary)

            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle(tint: progress >= 1.0 ? AppColors.success : AppColors.primary))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Day Grid Cell
struct DayGridCell: View {
    let task: DailyChallengeTask
    let isCurrentDay: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(task.isCompleted ? AppColors.success.opacity(0.15) :
                        (isCurrentDay ? AppColors.primary.opacity(0.15) : AppColors.disabled.opacity(0.1)))

            if task.isCompleted {
                Image(systemName: "checkmark")
                    .font(.caption2)
                    .foregroundColor(AppColors.success)
            } else {
                Text("\(task.dayNumber)")
                    .font(.caption2)
                    .fontWeight(isCurrentDay ? .bold : .regular)
                    .foregroundColor(isCurrentDay ? AppColors.primary : AppColors.textSecondary)
            }
        }
        .frame(height: 36)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrentDay ? AppColors.primary : Color.clear, lineWidth: 2)
        )
    }
}
