import SwiftUI

struct AddGoalView: View {
    @ObservedObject var viewModel: GoalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var dimension: GoalDimension = .career
    @State private var level: GoalLevel = .yearly
    @State private var priority: Priority = .medium
    @State private var deadline = Date()
    @State private var hasDeadline = false

    var body: some View {
        NavigationStack {
            Form {
                Section("目標資訊") {
                    TextField("目標標題", text: $title)

                    TextField("目標描述（選填）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("維度") {
                    Picker("維度", selection: $dimension) {
                        ForEach(GoalDimension.allCases, id: \.self) { d in
                            Label(d.displayName, systemImage: d.icon).tag(d)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("層級") {
                    Picker("層級", selection: $level) {
                        ForEach(GoalLevel.allCases, id: \.self) { l in
                            Text(l.displayName).tag(l)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("優先級") {
                    Picker("優先級", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { p in
                            Text(p.displayName).tag(p)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("截止日期") {
                    Toggle("設定截止日期", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker(
                            "截止日期",
                            selection: $deadline,
                            in: Date()...,
                            displayedComponents: .date
                        )
                    }
                }

                // 父目標選擇（如果有同維度的年度目標）
                Section("父目標") {
                    if level != .yearly {
                        let parentGoals = viewModel.goals.filter {
                            $0.dimension == dimension && $0.level == .yearly && $0.status == .active
                        }
                        if parentGoals.isEmpty {
                            Text("此維度尚無年度目標")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            // 顯示可選的父目標
                            Text("將自動關聯同維度年度目標")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    } else {
                        Text("年度目標為頂層目標")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .navigationTitle(StringConstants.Goals.addGoal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(StringConstants.Common.cancel) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(StringConstants.Common.save) {
                        saveGoal()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveGoal() {
        // 查找同維度的年度目標作為父目標
        var parentGoalId: String? = nil
        if level != .yearly {
            let parentGoals = viewModel.goals.filter {
                $0.dimension == dimension && $0.level == .yearly && $0.status == .active
            }
            parentGoalId = parentGoals.first?.id
        }

        let goal = Goal(
            title: title,
            description: description,
            dimension: dimension,
            level: level,
            parentGoalId: parentGoalId,
            priority: priority,
            status: .active,
            deadline: hasDeadline ? deadline : nil,
            progress: 0.0
        )

        _ = viewModel.createGoal(goal)
        dismiss()
    }
}
