import SwiftUI

/// 補打卡視圖 — 錯過的打卡可以補，但需要寫「為什麼錯過」的反思
struct MakeUpCheckInView: View {
    @State private var selectedDate = Date().adding(days: -1)
    @State private var selectedTaskId: String?
    @State private var reason = ""
    @State private var reflection = ""
    @State private var showSuccess = false
    @State private var availableTasks: [Task] = []

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Date picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📅 選擇補卡日期")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            DatePicker("補卡日期", selection: $selectedDate, in: ...Date().adding(days: -1), displayedComponents: .date)
                                .datePickerStyle(.graphical)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                        }

                        // Task picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("✅ 選擇任務")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            if availableTasks.isEmpty {
                                Text("該日期無可用任務")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .padding()
                            } else {
                                ForEach(availableTasks) { task in
                                    Button(action: { selectedTaskId = task.id }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: selectedTaskId == task.id ? "checkmark.circle.fill" : "circle")
                                                .foregroundColor(selectedTaskId == task.id ? AppColors.primary : AppColors.divider)
                                            Text(task.title)
                                                .font(.subheadline)
                                                .foregroundColor(AppColors.textPrimary)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(selectedTaskId == task.id ? AppColors.primary.opacity(0.05) : AppColors.cardBackground)
                                        .cornerRadius(10)
                                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(selectedTaskId == task.id ? AppColors.primary : AppColors.divider, lineWidth: 1))
                                    }
                                }
                            }
                        }

                        // Reason
                        VStack(alignment: .leading, spacing: 8) {
                            Text("💭 為什麼錯過？")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                            TextField("寫下你錯過的原因...", text: $reason)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                        }

                        // Reflection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🔄 反思：下次如何避免？")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                            TextField("下次我可以...", text: $reflection)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                        }

                        // Insight card
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(AppColors.accent)
                            Text("補卡不是為了「完美記錄」，而是為了誠實面對自己。每一次反思，都在累積對自己的了解。")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .background(AppColors.accent.opacity(0.05))
                        .cornerRadius(12)

                        // Submit
                        Button(action: submitMakeUp) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("確認補卡")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(canSubmit ? AppColors.primary : AppColors.disabled)
                            .cornerRadius(12)
                        }
                        .disabled(!canSubmit)
                    }
                    .padding()
                }
            }
            .navigationTitle("補打卡")
            .navigationBarTitleDisplayMode(.inline)
            .alert("補卡成功！", isPresented: $showSuccess) {
                Button("好的") {}
            } message: {
                Text("你已誠實面對自己，這比完美記錄更有價值。")
            }
            .onAppear { loadTasks() }
            .onChange(of: selectedDate) { _ in loadTasks() }
        }
    }

    private var canSubmit: Bool {
        selectedTaskId != nil && !reason.isEmpty && !reflection.isEmpty
    }

    private func loadTasks() {
        availableTasks = TaskService.shared.getAllTasks().filter { $0.status == .inProgress || $0.status == .pending }
    }

    private func submitMakeUp() {
        guard let taskId = selectedTaskId else { return }
        let result = CheckInService.shared.makeUpCheckIn(
            taskId: taskId,
            originalDate: selectedDate,
            reason: reason,
            reflection: reflection
        )
        if case .success = result {
            showSuccess = true
            reason = ""
            reflection = ""
        }
    }
}
