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
    // 「找到為什麼」— 3個動機
    @State private var goalWhys: [String] = ["", "", ""]
    @State private var showWhysWarning = false
    
    // 目標上限提醒
    @State private var showGoalLimitAlert = false
    private let goalLimit = 5
    
    var body: some View {
        NavigationStack {
            Form {
                Section("目標資訊") {
                    TextField("目標標題", text: $title)
                    TextField("目標描述（選填）", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.circle.fill")
                                .foregroundColor(AppColors.accent)
                            Text("為什麼你要完成這個目標？")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        Text("「沒有動機的目標，很難堅持。」寫下3個你一定要完成這個目標的原因。")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        ForEach(0..<3, id: \.self) { index in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(AppColors.accent)
                                    .frame(width: 20, height: 20)
                                    .overlay(Text("\(index + 1)").font(.caption2).foregroundColor(.white))
                                TextField("因為...", text: $goalWhys[index])
                            }
                        }
                    }
                } header: {
                    Text("🎯 找到為什麼")
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
                
                // 父目標選擇
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
                    Button(StringConstants.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(StringConstants.Common.save) { saveGoal() }
                        .disabled(title.isEmpty)
                }
            }
            .alert("💡 建議補充動機", isPresented: $showWhysWarning) {
                Button("繼續保存") { confirmSaveGoal() }
                Button("回去補充", role: .cancel) {}
            } message: {
                Text("沒有寫下「為什麼」，目標很容易放棄。建議至少寫1個動機。")
            }
        }
        
        // 目標上限警告彈窗
        .overlay {
            if showGoalLimitAlert {
                GoalLimitWarningView(
                    currentCount: viewModel.goals.filter { $0.status == .active }.count,
                    maxLimit: goalLimit,
                    isPresented: $showGoalLimitAlert,
                    onContinue: {
                        showGoalLimitAlert = false
                        // 用戶確認，繼續保存流程
                        let hasWhys = goalWhys.contains { !$0.isEmpty }
                        if !hasWhys {
                            showWhysWarning = true
                        } else {
                            confirmSaveGoal()
                        }
                    },
                    onCancel: {
                        showGoalLimitAlert = false
                        // 用戶取消，返回頁面
                    }
                )
            }
        }
    }
    
    private func saveGoal() {
        // 首先檢查目標上限
        let activeCount = viewModel.goals.filter { $0.status == .active }.count
        if activeCount >= goalLimit {
            showGoalLimitAlert = true
            return
        }
        
        // 檢查動機
        let hasWhys = goalWhys.contains { !$0.isEmpty }
        if !hasWhys {
            showWhysWarning = true
        } else {
            confirmSaveGoal()
        }
    }
    
    private func confirmSaveGoal() {
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
        
        // 同時保存目標動機
        let validWhys = goalWhys.filter { !$0.isEmpty }
        if !validWhys.isEmpty, let createdGoal = viewModel.goals.last {
            let motivation = GoalMotivation(goalId: createdGoal.id, whys: validWhys)
            _ = GoalEnhancementService.shared.saveGoalMotivation(motivation)
        }
        
        dismiss()
    }
}
