import SwiftUI

struct CheckInView: View {
    @StateObject private var viewModel = CheckInViewModel()
    @State private var showCheckInSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        SummaryCardView(
                            icon: "checkmark.circle.fill",
                            value: "\(viewModel.todayCheckIns.filter { $0.status == .completed }.count)",
                            label: StringConstants.CheckIn.completed
                        )

                        SummaryCardView(
                            icon: "flame.fill",
                            value: "\(viewModel.todayCheckIns.map { $0.taskId }.reduce(0) { _, _ in 1 })",
                            label: StringConstants.CheckIn.streakDays
                        )
                    }
                    .padding(.horizontal)

                    ScrollView {
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
            }
            .navigationTitle(StringConstants.CheckIn.title)
            .sheet(isPresented: $showCheckInSheet) {
                if let task = viewModel.selectedTask {
                    CheckInSheetView(viewModel: viewModel, task: task)
                }
            }
            .onAppear {
                viewModel.loadTodaysData()
            }
            .refreshable {
                viewModel.loadTodaysData()
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

