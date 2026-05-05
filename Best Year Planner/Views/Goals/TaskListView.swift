import SwiftUI

struct TaskListView: View {
    let goalId: String
    @StateObject private var viewModel = GoalViewModel()
    @State private var showAddTask = false
    @State private var newTaskTitle = ""
    @State private var newTaskPriority: Priority = .medium
    @State private var showDeleteConfirmation = false
    @State private var taskToDelete: Task?

    private var tasks: [Task] { TaskService.shared.getTasks(byGoalId: goalId) }
    private var goal: Goal? { viewModel.goals.first { $0.id == goalId } }

    var body: some View {
        VStack(spacing: 0) {
            if tasks.isEmpty {
                EmptyStateView(
                    icon: "checklist",
                    title: "尚無任務",
                    message: "為這個目標添加具體的執行任務",
                    actionTitle: "添加任務",
                    action: { showAddTask = true }
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(tasks) { task in
                            TaskRowView(task: task)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        taskToDelete = task
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("刪除", systemImage: "trash.fill")
                                    }

                                    if task.status == .pending || task.status == .inProgress {
                                        Button {
                                            _ = TaskService.shared.completeTask(task.id)
                                            viewModel.loadGoals()
                                        } label: {
                                            Label("完成", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(.green)
                                    }
                                }
                                .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                    if task.status == .active {
                                        Button {
                                            _ = TaskService.shared.updateTaskStreak(task.id, streak: 0)
                                            viewModel.loadGoals()
                                        } label: {
                                            Label("暫停", systemImage: "pause.fill")
                                        }
                                        .tint(.orange)
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("任務列表")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showAddTask = true }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
        }
        .alert("新增任務", isPresented: $showAddTask) {
            TextField("任務名稱", text: $newTaskTitle)
            Button("取消", role: .cancel) { newTaskTitle = "" }
            Button("新增") { addTask() }
                .disabled(newTaskTitle.isEmpty)
        } message: {
            Text("輸入任務名稱以新增任務")
        }
        .alert("確認刪除", isPresented: $showDeleteConfirmation) {
            Button("取消", role: .cancel) { taskToDelete = nil }
            Button("刪除", role: .destructive) {
                if let task = taskToDelete {
                    _ = TaskService.shared.deleteTask(task.id)
                    viewModel.loadGoals()
                }
                taskToDelete = nil
            }
        } message: {
            Text("確定要刪除任務「\(taskToDelete?.title ?? "")」嗎？此操作無法撤銷。")
        }
        .onAppear {
            viewModel.loadGoals()
        }
    }

    private func addTask() {
        guard !newTaskTitle.isEmpty else { return }
        let task = Task(
            goalId: goalId,
            title: newTaskTitle,
            priority: newTaskPriority,
            status: .pending
        )
        _ = TaskService.shared.createTask(task)
        newTaskTitle = ""
        viewModel.loadGoals()
    }
}

struct TaskRowView: View {
    let task: Task

    var body: some View {
        HStack(spacing: 12) {
            // 狀態圖標
            Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
                .foregroundColor(task.status == .completed ? AppColors.success : AppColors.disabled)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .strikethrough(task.status == .completed)

                HStack(spacing: 8) {
                    Text(task.status.displayName)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    if task.currentStreak > 0 {
                        Label("\(task.currentStreak)天", systemImage: "flame.fill")
                            .font(.caption)
                            .foregroundColor(AppColors.accent)
                    }

                    Text(task.priority.displayName)
                        .font(.caption)
                        .foregroundColor(task.priority == .high ? AppColors.error : AppColors.textSecondary)
                }
            }

            Spacer()

            if let deadline = task.deadline {
                Text(deadline.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
