import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @State private var showCheckInSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        // Stats
                        HStack(spacing: 16) {
                            SummaryCardView(
                                icon: "checkmark.circle.fill",
                                value: "\(viewModel.todayCheckIns.filter { $0.status == .completed }.count)",
                                label: StringConstants.CheckIn.completed
                            )

                            SummaryCardView(
                                icon: "flame.fill",
                                value: "\(challengeViewModel.currentChallenge?.completedDays ?? 0)",
                                label: StringConstants.CheckIn.streakDays
                            )
                        }
                        .padding(.horizontal)

                        // Challenge task section (if active)
                        if let challenge = challengeViewModel.currentChallenge,
                           let todayTask = challengeViewModel.todayTask {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: challenge.phase == .sevenDayLaunch ? "bolt.fill" : "flame.fill")
                                        .foregroundColor(challenge.phase == .sevenDayLaunch ? AppColors.accent : AppColors.primary)
                                    Text(challenge.phase == .sevenDayLaunch ? StringConstants.Dashboard.sevenDayLaunch : StringConstants.Dashboard.twentyOneDayChallenge)
                                        .font(.headline)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Text("第\(challenge.currentDayNumber)天")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(AppColors.primary)
                                        .cornerRadius(10)
                                }

                                ChallengeCheckInRow(
                                    task: todayTask,
                                    isCompleting: challengeViewModel.isCompleting,
                                    onComplete: {
                                        Task { await challengeViewModel.completeTodayTask() }
                                    }
                                )
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)
                        }

                        // Regular tasks
                        if !viewModel.todayTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(StringConstants.CheckIn.todayTasks)
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding(.horizontal)

                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.todayTasks) { task in
                                        CheckInTaskRow(
                                            task: task,
                                            checkIn: viewModel.getCheckIn(forTaskId: task.id),
                                            streak: viewModel.getStreak(forTaskId: task.id),
                                            hasCheckedIn: viewModel.hasCheckedIn(task: task),
                                            onCheckIn: {
                                                viewModel.selectTask(task)
                                                showCheckInSheet = true
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }

                        // Empty state
                        if challengeViewModel.currentChallenge == nil && viewModel.todayTasks.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(AppColors.divider)
                                Text("今天沒有待完成的任務")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.top, 60)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle(StringConstants.CheckIn.title)
            .sheet(isPresented: $showCheckInSheet) {
                if let task = viewModel.selectedTask {
                    CheckInSheetView(viewModel: viewModel, task: task)
                }
            }
            .sheet(isPresented: $challengeViewModel.showingUnlock) {
                ChallengeUnlockView(viewModel: challengeViewModel)
            }
            .onAppear {
                viewModel.loadTodaysData()
                challengeViewModel.loadChallenges()
            }
            .refreshable {
                viewModel.loadTodaysData()
                challengeViewModel.loadChallenges()
            }
        }
    }
}

// MARK: - Challenge Check-In Row
struct ChallengeCheckInRow: View {
    let task: DailyChallengeTask
    let isCompleting: Bool
    let onComplete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(task.isCompleted ? AppColors.textSecondary : AppColors.textPrimary)
                    .strikethrough(task.isCompleted)

                HStack(spacing: 8) {
                    Label("\(task.estimatedMinutes)分鐘", systemImage: "clock")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)

                    if task.aiTip != nil {
                        Label("AI建議", systemImage: "sparkle")
                            .font(.caption2)
                            .foregroundColor(AppColors.accent)
                    }
                }
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
}

struct CheckInTaskRow: View {
    let task: Task
    let checkIn: CheckIn?
    let streak: Int
    let hasCheckedIn: Bool
    let onCheckIn: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(task.title)
                        .font(.headline)
                        .foregroundColor(hasCheckedIn ? AppColors.textSecondary : AppColors.textPrimary)
                        .strikethrough(hasCheckedIn)

                    if let checkIn = checkIn {
                        Text(checkIn.date.formatted(AppConstants.DateFormats.displayTime))
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Spacer()

                if hasCheckedIn {
                    Image(systemName: checkIn?.status.icon ?? "checkmark.circle.fill")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                } else {
                    Button(action: onCheckIn) {
                        Text(StringConstants.CheckIn.checkIn)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(AppColors.primary)
                            .cornerRadius(8)
                    }
                }
            }

            HStack {
                if streak > 0 {
                    Label("\(streak)天", systemImage: "flame.fill")
                        .font(.caption)
                        .foregroundColor(AppColors.accent)
                }

                Spacer()

                Text(task.priority.displayName)
                    .font(.caption)
                    .foregroundColor(task.priority == .high ? AppColors.error : AppColors.textSecondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
}

struct CheckInSheetView: View {
    @ObservedObject var viewModel: CheckInViewModel
    let task: Task
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text(task.title)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text("選擇完成狀態")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)

                VStack(spacing: 12) {
                    ForEach(CheckInStatus.allCases, id: \.self) { status in
                        Button(action: {
                            viewModel.selectedCheckInStatus = status
                        }) {
                            HStack {
                                Image(systemName: status.icon)
                                    .foregroundColor(viewModel.selectedCheckInStatus == status ? .white : Color(hex: statusColor(status)))

                                Text(status.displayName)
                                    .foregroundColor(viewModel.selectedCheckInStatus == status ? .white : AppColors.textPrimary)

                                Spacer()

                                if viewModel.selectedCheckInStatus == status {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(viewModel.selectedCheckInStatus == status ? Color(hex: statusColor(status)) : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(hex: statusColor(status)), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("備註（選填）")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)

                    TextField("寫下你的感受...", text: $viewModel.checkInNote, axis: .vertical)
                        .lineLimit(3...5)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                }
                .padding(.horizontal)

                Spacer()

                Button(action: {
                    if viewModel.checkIn(
                        task: task,
                        status: viewModel.selectedCheckInStatus,
                        note: viewModel.checkInNote.isEmpty ? nil : viewModel.checkInNote
                    ) {
                        dismiss()
                    }
                }) {
                    Text(StringConstants.CheckIn.checkIn)
                        .primaryButtonStyle()
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
            }
            .padding(.top, 24)
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(StringConstants.Common.cancel) {
                        viewModel.clearSelection()
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func statusColor(_ status: CheckInStatus) -> String {
        switch status {
        case .completed: return "7ED321"
        case .partial: return "F5A623"
        case .missed: return "E74C3C"
        }
    }
}

