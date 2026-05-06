import SwiftUI

/// 領先/滯後指標管理 — 基於《規劃最好的一年》核心概念
/// 領先指標 = 你可以控制的行動，滯後指標 = 你無法直接控制的結果
struct GoalIndicatorsView: View {
    let goalId: String
    let goalTitle: String
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAddIndicator = false
    @State private var newType: GoalIndicatorType = .lead
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newTargetValue = ""
    @State private var newCurrentValue = ""
    @State private var newUnit = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 概念說明
                        conceptCard
                        
                        // 領先指標
                        if !leadIndicators.isEmpty {
                            indicatorSection(title: "🏃 領先指標（你可以控制的行動）", indicators: leadIndicators, color: AppColors.success)
                        }
                        
                        // 滯後指標
                        if !lagIndicators.isEmpty {
                            indicatorSection(title: "📊 滯後指標（你追求的結果）", indicators: lagIndicators, color: AppColors.accent)
                        }
                        
                        // 空狀態
                        if viewModel.goalIndicators[goalId]?.isEmpty ?? true {
                            emptyState
                        }
                        
                        // 新增按鈕
                        Button(action: { showAddIndicator = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("新增指標")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(AppColors.primary)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("領先/滯後指標")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddIndicator) {
                addIndicatorSheet
            }
        }
        .onAppear {
            viewModel.loadGoalIndicators(goalId: goalId)
        }
    }
    
    // MARK: - 概念卡片
    private var conceptCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(AppColors.accent)
                Text("關鍵概念")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            Text("你無法直接控制結果（滯後指標），但你可以控制行動（領先指標）。把注意力放在領先指標上，結果自然會跟著來。")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            HStack(spacing: 16) {
                exampleChip(icon: "🏃", text: "每週運動3次", type: "領先")
                exampleChip(icon: "📊", text: "3個月減重5公斤", type: "滯後")
            }
        }
        .padding()
        .background(AppColors.accent.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - 指標分區
    private func indicatorSection(title: String, indicators: [GoalIndicator], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(indicators) { indicator in
                indicatorRow(indicator: indicator, color: color)
            }
        }
    }
    
    private func indicatorRow(indicator: GoalIndicator, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: indicator.type.icon)
                    .foregroundColor(color)
                Text(indicator.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }
            if !indicator.description.isEmpty {
                Text(indicator.description)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            if let target = indicator.targetValue, let current = indicator.currentValue, target > 0 {
                HStack(spacing: 8) {
                    Text("進度")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    ProgressView(value: current / target)
                        .progressViewStyle(LinearProgressViewStyle(tint: color))
                    Text("\(Int(current))/\(Int(target))\(indicator.unit ?? "")")
                        .font(.caption2)
                        .foregroundColor(color)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(color.opacity(0.2), lineWidth: 1))
    }
    
    // MARK: - 空狀態
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            Text("還沒有指標\n把目標拆解成你可以控制的行動和追求的結果")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 32)
    }
    
    // MARK: - 新增指標 Sheet
    private var addIndicatorSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("指標類型")
                                .font(.subheadline)
                                .fontWeight(.medium)
                            Picker("類型", selection: $newType) {
                                ForEach(GoalIndicatorType.allCases, id: \.self) { type in
                                    Label(type.displayName, systemImage: type.icon).tag(type)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("指標名稱")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            TextField(newType == .lead ? "例：每週運動3次" : "例：3個月減重5公斤", text: $newTitle)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("描述（選填）")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            TextField("更具體地描述這個指標...", text: $newDescription, axis: .vertical)
                                .lineLimit(2...4)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                        }
                        
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("目標值")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                TextField("3", text: $newTargetValue)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("當前值")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                TextField("0", text: $newCurrentValue)
                                    .keyboardType(.decimalPad)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("單位")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                TextField("次/分鐘/公斤", text: $newUnit)
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(10)
                                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("新增指標")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showAddIndicator = false; resetForm() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveIndicator()
                        showAddIndicator = false
                        resetForm()
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func exampleChip(icon: String, text: String, type: String) -> some View {
        HStack(spacing: 4) {
            Text(icon)
            Text(text)
                .font(.caption2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(type == "領先" ? AppColors.success.opacity(0.1) : AppColors.accent.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var leadIndicators: [GoalIndicator] {
        (viewModel.goalIndicators[goalId] ?? []).filter { $0.type == .lead }
    }
    
    private var lagIndicators: [GoalIndicator] {
        (viewModel.goalIndicators[goalId] ?? []).filter { $0.type == .lag }
    }
    
    private func saveIndicator() {
        let indicator = GoalIndicator(
            goalId: goalId,
            type: newType,
            title: newTitle,
            description: newDescription,
            targetValue: Double(newTargetValue),
            currentValue: Double(newCurrentValue),
            unit: newUnit.isEmpty ? nil : newUnit
        )
        viewModel.saveGoalIndicator(indicator)
    }
    
    private func resetForm() {
        newType = .lead
        newTitle = ""
        newDescription = ""
        newTargetValue = ""
        newCurrentValue = ""
        newUnit = ""
    }
}
