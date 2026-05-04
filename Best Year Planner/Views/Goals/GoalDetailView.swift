import SwiftUI

struct GoalDetailView: View {
    let goal: Goal
    @ObservedObject var viewModel: GoalViewModel
    @State private var isEditing = false
    @State private var showDeleteConfirmation = false
    @State private var editedTitle: String = ""
    @State private var editedDescription: String = ""
    @State private var editedPriority: Priority = .medium
    @State private var editedDeadline: Date = Date()
    @State private var editedStatus: GoalStatus = .active
    @Environment(\.dismiss) private var dismiss

    private var subGoals: [Goal] {
        viewModel.goals.filter { $0.parentGoalId == goal.id }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 目標頭部
                VStack(spacing: 12) {
                    Image(systemName: goal.dimension.icon)
                        .font(.system(size: 40))
                        .foregroundColor(Color(hex: goal.dimension.color))

                    if isEditing {
                        TextField("目標標題", text: $editedTitle)
                            .font(.title2)
                            .fontWeight(.bold)
                            .textFieldStyle(.roundedBorder)
                            .multilineTextAlignment(.center)
                    } else {
                        Text(goal.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                    }

                    HStack(spacing: 8) {
                        Text(goal.dimension.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(hex: goal.dimension.color).opacity(0.15))
                            .cornerRadius(4)

                        Text(goal.level.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.primary.opacity(0.15))
                            .cornerRadius(4)

                        Text(goal.priority.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(AppColors.accent.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)

                // 進度
                VStack(spacing: 12) {
                    HStack {
                        Text("完成進度")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Text("\(Int(goal.progress * 100))%")
                            .font(.headline)
                            .foregroundColor(AppColors.primary)
                    }

                    ProgressView(value: goal.progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: goal.dimension.color)))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)

                // 描述
                if !goal.description.isEmpty || isEditing {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("描述")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        if isEditing {
                            TextField("目標描述", text: $editedDescription, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            Text(goal.description)
                                .font(.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // 截止日期
                if let deadline = goal.deadline {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(AppColors.primary)
                        Text("截止日期")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        Text(deadline.formatted(AppConstants.DateFormats.displayDate))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // 子目標
                if !subGoals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("子目標")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        ForEach(subGoals) { subGoal in
                            NavigationLink(destination: GoalDetailView(goal: subGoal, viewModel: viewModel)) {
                                SubGoalRowView(goal: subGoal)
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // 操作按鈕
                VStack(spacing: 12) {
                    if isEditing {
                        Button(action: saveChanges) {
                            Text(StringConstants.Common.save)
                                .primaryButtonStyle()
                        }

                        Button(action: { isEditing = false }) {
                            Text(StringConstants.Common.cancel)
                                .secondaryButtonStyle()
                        }
                    } else {
                        HStack(spacing: 12) {
                            Button(action: startEditing) {
                                Label(StringConstants.Common.edit, systemImage: "pencil")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(AppColors.primary.opacity(0.1))
                                    .cornerRadius(12)
                                    .foregroundColor(AppColors.primary)
                            }

                            if goal.status == .active {
                                Button(action: { _ = viewModel.pauseGoal(goal.id) }) {
                                    Label("暫停", systemImage: "pause.circle")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.accent.opacity(0.1))
                                        .cornerRadius(12)
                                        .foregroundColor(AppColors.accent)
                                }
                            } else if goal.status == .paused {
                                Button(action: { _ = viewModel.resumeGoal(goal.id) }) {
                                    Label("繼續", systemImage: "play.circle")
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(AppColors.secondary.opacity(0.1))
                                        .cornerRadius(12)
                                        .foregroundColor(AppColors.secondary)
                                }
                            }
                        }

                        Button(action: { showDeleteConfirmation = true }) {
                            Label(StringConstants.Common.delete, systemImage: "trash")
                                .foregroundColor(AppColors.error)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(AppColors.error.opacity(0.1))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 32)
            }
            .padding(.top)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(goal.title)
        .navigationBarTitleDisplayMode(.inline)
        .alert("確認刪除", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) {}
            Button("刪除", role: .destructive) {
                _ = viewModel.deleteGoal(goal.id)
                dismiss()
            }
        } message: {
            Text("刪除後無法恢復，確定要刪除「\(goal.title)」嗎？")
        }
    }

    private func startEditing() {
        editedTitle = goal.title
        editedDescription = goal.description
        editedPriority = goal.priority
        editedDeadline = goal.deadline ?? Date()
        editedStatus = goal.status
        isEditing = true
    }

    private func saveChanges() {
        var updatedGoal = goal
        updatedGoal.title = editedTitle
        updatedGoal.description = editedDescription
        updatedGoal.priority = editedPriority
        updatedGoal.deadline = editedDeadline
        updatedGoal.status = editedStatus
        updatedGoal.updatedAt = Date()
        _ = viewModel.updateGoal(updatedGoal)
        isEditing = false
    }
}

struct SubGoalRowView: View {
    let goal: Goal

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: goal.status == .completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(goal.status == .completed ? AppColors.secondary : AppColors.disabled)

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .strikethrough(goal.status == .completed)

                Text(goal.level.displayName)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            Spacer()

            Text("\(Int(goal.progress * 100))%")
                .font(.caption)
                .foregroundColor(AppColors.primary)
        }
        .padding(.vertical, 8)
    }
}
