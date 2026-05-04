import SwiftUI

struct SevenDayLaunchView: View {
    @ObservedObject var viewModel: ChallengeViewModel
    @State private var showTip: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(StringConstants.Challenge.launchTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(StringConstants.Challenge.launchSubtitle)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 16)

                // Progress Ring
                if let challenge = viewModel.currentChallenge {
                    ZStack {
                        ProgressRingView(
                            progress: challenge.progress,
                            size: 160
                        )

                        VStack(spacing: 4) {
                            Text("\(challenge.completedDays)")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundColor(AppColors.primary)
                            Text("/ \(challenge.totalDays) 天")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    // Milestone messages
                    if challenge.completedDays >= 5 {
                        Text(StringConstants.Challenge.almostDone)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.accent)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(AppColors.accent.opacity(0.1))
                            .cornerRadius(20)
                    } else if challenge.completedDays >= 4 {
                        Text(StringConstants.Challenge.halfwayThere)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(AppColors.primary.opacity(0.1))
                            .cornerRadius(20)
                    }

                    // Today's task
                    if let todayTask = viewModel.todayTask, !todayTask.isCompleted {
                        TodayChallengeTaskCard(
                            task: todayTask,
                            isCompleting: viewModel.isCompleting,
                            showTip: $showTip,
                            onComplete: {
                                Task { await viewModel.completeTodayTask() }
                            }
                        )
                    } else if let todayTask = viewModel.todayTask, todayTask.isCompleted {
                        CompletedTaskCard(task: todayTask)
                    }

                    // Day-by-day list
                    VStack(alignment: .leading, spacing: 12) {
                        Text("每日任務")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)

                        ForEach(challenge.dailyTasks) { task in
                            DayRowView(task: task, isCurrentDay: task.dayNumber == challenge.currentDayNumber)
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(AppColors.background)
    }
}

// MARK: - Today's Task Card
struct TodayChallengeTaskCard: View {
    let task: DailyChallengeTask
    let isCompleting: Bool
    @Binding var showTip: Bool
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(AppColors.accent)
                Text(StringConstants.Dashboard.todayMission)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text(String(format: StringConstants.Challenge.dayNumber, "\(task.dayNumber)"))
                    .font(.caption)
                    .foregroundColor(AppColors.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(12)
            }

            Text(task.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text(task.description)
                .font(.body)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            // Time estimate
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                Text(String(format: StringConstants.Challenge.estimatedTime, "\(task.estimatedMinutes)"))
                    .font(.caption)
            }
            .foregroundColor(AppColors.textSecondary)

            // Complete button
            Button(action: onComplete) {
                HStack(spacing: 8) {
                    if isCompleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "checkmark.circle.fill")
                    }
                    Text(StringConstants.Challenge.completeDay)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primary)
                .cornerRadius(12)
            }
            .disabled(isCompleting)

            // AI Tip toggle
            if let tip = task.aiTip {
                Button(action: { showTip.toggle() }) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkle")
                            .font(.caption)
                        Text(StringConstants.Challenge.aiTip)
                            .font(.caption)
                    }
                    .foregroundColor(AppColors.accent)
                }

                if showTip {
                    Text(tip)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(AppColors.accent.opacity(0.08))
                        .cornerRadius(8)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

// MARK: - Completed Task Card
struct CompletedTaskCard: View {
    let task: DailyChallengeTask

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.success)

            Text(StringConstants.Challenge.completedDay)
                .font(.headline)
                .foregroundColor(AppColors.success)

            if let tip = task.aiTip, !tip.isEmpty {
                Text(tip)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.success.opacity(0.08))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Day Row
struct DayRowView: View {
    let task: DailyChallengeTask
    let isCurrentDay: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            ZStack {
                Circle()
                    .fill(task.isCompleted ? AppColors.success : (isCurrentDay ? AppColors.primary : AppColors.disabled.opacity(0.3)))
                    .frame(width: 32, height: 32)

                if task.isCompleted {
                    Image(systemName: "checkmark")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                } else {
                    Text("\(task.dayNumber)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(isCurrentDay ? .white : AppColors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(isCurrentDay ? .semibold : .regular)
                    .foregroundColor(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                    .strikethrough(task.isCompleted)

                Text("\(task.estimatedMinutes)分鐘")
                    .font(.caption2)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            if isCurrentDay && !task.isCompleted {
                Text("今天")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(AppColors.primary)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(isCurrentDay ? AppColors.primary.opacity(0.05) : Color.clear)
        .cornerRadius(10)
    }
}
