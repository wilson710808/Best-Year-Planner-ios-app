import SwiftUI

struct GoalsListView: View {
    @StateObject private var viewModel = GoalViewModel()
    @State private var showAddGoal = false
    @State private var selectedDimension: GoalDimension?

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    Picker("維度", selection: $selectedDimension) {
                        Text("全部").tag(GoalDimension?.none)
                        ForEach(GoalDimension.allCases, id: \.self) { dimension in
                            Text(dimension.displayName).tag(GoalDimension?.some(dimension))
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()

                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(filteredGoals) { goal in
                                NavigationLink(destination: GoalDetailView(goal: goal, viewModel: viewModel)) {
                                    GoalRowView(goal: goal)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle(StringConstants.Goals.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(AppColors.primary)
                    }
                }
            }
            .sheet(isPresented: $showAddGoal) {
                AddGoalView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.loadGoals()
            }
            .onChange(of: selectedDimension) {
                if let dimension = selectedDimension {
                    viewModel.loadGoals(forDimension: dimension)
                } else {
                    viewModel.loadGoals()
                }
            }
        }
    }

    var filteredGoals: [Goal] {
        if let dimension = selectedDimension {
            return viewModel.goals.filter { $0.dimension == dimension }
        }
        return viewModel.goals
    }
}

struct GoalRowView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goal.dimension.icon)
                    .foregroundColor(Color(hex: goal.dimension.color))

                Text(goal.dimension.displayName)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(goal.level.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.primary.opacity(0.8))
                    .cornerRadius(4)
            }

            Text(goal.title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            if !goal.description.isEmpty {
                Text(goal.description)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }

            HStack {
                ProgressView(value: goal.progress)
                    .progressViewStyle(LinearProgressViewStyle(tint: Color(hex: goal.dimension.color)))

                Text("\(Int(goal.progress * 100))%")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            HStack {
                Label("\(goal.priority.displayName)", systemImage: "flag.fill")
                    .font(.caption)
                    .foregroundColor(goal.priority == .high ? AppColors.accent : AppColors.textSecondary)

                Spacer()

                Text(goal.status.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor(for: goal.status))
                    .cornerRadius(4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private func statusColor(for status: GoalStatus) -> Color {
        switch status {
        case .active: return AppColors.primary
        case .paused: return AppColors.warning
        case .completed: return AppColors.success
        case .cancelled: return AppColors.disabled
        }
    }
}



struct EditGoalView: View {
    let goal: Goal
    @ObservedObject var viewModel: GoalViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var description: String
    @State private var dimension: GoalDimension
    @State private var level: GoalLevel
    @State private var priority: Priority
    @State private var hasDeadline: Bool
    @State private var deadline: Date

    init(goal: Goal, viewModel: GoalViewModel) {
        self.goal = goal
        self.viewModel = viewModel
        _title = State(initialValue: goal.title)
        _description = State(initialValue: goal.description)
        _dimension = State(initialValue: goal.dimension)
        _level = State(initialValue: goal.level)
        _priority = State(initialValue: goal.priority)
        _hasDeadline = State(initialValue: goal.deadline != nil)
        _deadline = State(initialValue: goal.deadline ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("目標資訊") {
                    TextField("目標標題", text: $title)
                    TextField("描述（選填）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("分類") {
                    Picker("維度", selection: $dimension) {
                        ForEach(GoalDimension.allCases, id: \.self) { dim in
                            Text(dim.displayName).tag(dim)
                        }
                    }

                    Picker("層級", selection: $level) {
                        ForEach(GoalLevel.allCases, id: \.self) { lvl in
                            Text(lvl.displayName).tag(lvl)
                        }
                    }

                    Picker("優先順序", selection: $priority) {
                        ForEach(Priority.allCases, id: \.self) { pri in
                            Text(pri.displayName).tag(pri)
                        }
                    }
                }

                Section {
                    Toggle("設定截止日期", isOn: $hasDeadline)

                    if hasDeadline {
                        DatePicker("截止日期", selection: $deadline, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("編輯目標")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        updateGoal()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func updateGoal() {
        var updatedGoal = goal
        updatedGoal.title = title.trimmingCharacters(in: .whitespaces)
        updatedGoal.description = description
        updatedGoal.dimension = dimension
        updatedGoal.level = level
        updatedGoal.priority = priority
        updatedGoal.deadline = hasDeadline ? deadline : nil
        updatedGoal.updatedAt = Date()

        _ = viewModel.updateGoal(updatedGoal)
        dismiss()
    }
}