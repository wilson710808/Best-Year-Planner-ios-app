import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var goalViewModel = GoalViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    ProgressRingView(progress: viewModel.overallProgress, size: 120)
                        .padding(.top, 16)

                    Text(StringConstants.Dashboard.yearProgress)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    HStack(spacing: 16) {
                        DimensionProgressView(
                            dimension: .career,
                            progress: viewModel.careerProgress
                        )

                        DimensionProgressView(
                            dimension: .relationship,
                            progress: viewModel.relationshipProgress
                        )

                        DimensionProgressView(
                            dimension: .growth,
                            progress: viewModel.growthProgress
                        )
                    }
                    .padding(.horizontal)

                    WeeklySummaryView(
                        completionRate: viewModel.weeklyCompletionRate,
                        totalCheckIns: viewModel.weeklyTotalCheckIns,
                        streakDays: viewModel.weeklyStreakDays
                    )
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 12) {
                        Text(StringConstants.Dashboard.todayTasks)
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)

                        if viewModel.todayTasks.isEmpty {
                            EmptyStateView(
                                icon: "checkmark.circle",
                                title: "今日無任務",
                                message: "太棒了！今天沒有待完成的任務"
                            )
                            .frame(height: 150)
                        } else {
                            ForEach(viewModel.todayTasks.prefix(3)) { task in
                                TodayTaskRow(task: task)
                            }
                        }
                    }

                    if !viewModel.pendingTasks.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(StringConstants.Dashboard.unfinishedTasks)
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)

                            ForEach(viewModel.pendingTasks.prefix(3)) { task in
                                PendingTaskRow(task: task)
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .background(AppColors.background)
            .navigationTitle(StringConstants.Dashboard.title)
            .onAppear {
                viewModel.loadDashboardData()
                goalViewModel.loadGoals()
            }
            .refreshable {
                viewModel.loadDashboardData()
            }
        }
    }
}

struct TodayTaskRow: View {
    let task: Task

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: task.priority == .high ? "exclamationmark.circle.fill" : "circle")
                .foregroundColor(task.priority == .high ? AppColors.accent : AppColors.disabled)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)

                if let deadline = task.deadline {
                    Text(deadline.formatted(AppConstants.DateFormats.displayTime))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer()

            Text("\(task.currentStreak)天")
                .font(.caption)
                .foregroundColor(task.currentStreak > 0 ? AppColors.secondary : AppColors.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(task.currentStreak > 0 ? AppColors.secondary.opacity(0.1) : AppColors.disabled.opacity(0.1))
                .cornerRadius(4)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct PendingTaskRow: View {
    let task: Task

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)

                Text(task.status.displayName)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.disabled)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

