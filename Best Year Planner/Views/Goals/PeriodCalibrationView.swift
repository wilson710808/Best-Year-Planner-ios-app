import SwiftUI

/// 季度/月度校正 — 定期檢視目標，確保方向正確
struct PeriodCalibrationView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var isQuarterly = true
    @State private var completedItems: [String] = ["", "", ""]
    @State private var stuckItems: [String] = ["", "", ""]
    @State private var adjustments: [String] = ["", "", ""]
    @State private var goalAdjustments: [String] = ["", "", ""]
    @State private var isGeneratingReport = false
    @State private var aiReport: String?
    
    private var periodLabel: String {
        isQuarterly ? "季度" : "月度"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        Picker("校正類型", selection: $isQuarterly) {
                            Text("季度校正").tag(true)
                            Text("月度校正").tag(false)
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        StepIndicator(currentStep: currentStep, totalSteps: 4)
                        
                        if currentStep == 0 {
                            completedStep
                        } else if currentStep == 1 {
                            stuckStep
                        } else if currentStep == 2 {
                            adjustmentsStep
                        } else {
                            reportStep
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("📅 \(periodLabel)校正")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(currentStep == 0 ? "稍後" : "上一步") {
                        if currentStep > 0 { currentStep -= 1 } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentStep < 3 {
                        Button("下一步") { withAnimation { currentStep += 1 } }
                    } else {
                        Button("完成") {
                            saveCalibration()
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // Step 1: 完成了什麼
    private var completedStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("✅ 這\(periodLabel)完成了什麼？")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            Text("回顧你的行動，即使小小的進步也算。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            ForEach(0..<3, id: \.self) { i in
                TextField("成就 #\(i+1)...", text: $completedItems[i])
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }
            insightCard(icon: "star.fill", color: AppColors.accent, text: "提示：即使只完成了一部分，也比沒開始好。小進步也是進步。")
        }
    }
    
    // Step 2: 什麼卡住了
    private var stuckStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🧩 什麼卡住了？")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            Text("誠實面對障礙，不是自責，是為了找到出路。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            ForEach(0..<3, id: \.self) { i in
                TextField("障礙 #\(i+1)...", text: $stuckItems[i])
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }
            insightCard(icon: "heart.fill", color: AppColors.accent, text: "提示：障礙通常來自三個地方——能力不足、時間不夠、動機不強。找出是哪一個。")
        }
    }
    
    // Step 3: 調整計劃
    private var adjustmentsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔧 下\(periodLabel)調整什麼？")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            Text("根據回顧，你需要：繼續、修改、暫停、還是刪除？")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            ForEach(0..<3, id: \.self) { i in
                TextField("調整 #\(i+1)...", text: $adjustments[i])
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }
            
            Text("🎯 目標調整")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
                .padding(.top, 8)
            ForEach(0..<3, id: \.self) { i in
                TextField("目標調整（繼續/暫停/修改/刪除）...", text: $goalAdjustments[i])
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
            }
        }
    }
    
    // Step 4: AI 報告
    private var reportStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 校正報告")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            if isGeneratingReport {
                VStack(spacing: 16) {
                    ProgressView().scaleEffect(1.2)
                    Text("AI 正在分析你的\(periodLabel)數據...")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
            } else if let report = aiReport {
                Text(report)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
            } else {
                Button(action: generateReport) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("生成 AI 校正建議")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .cornerRadius(12)
                }
            }
        }
    }
    
    // MARK: - Components
    private func insightCard(icon: String, color: Color, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title3)
            Text(text)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(color.opacity(0.05))
        .cornerRadius(12)
    }
    
    private func generateReport() {
        isGeneratingReport = true
        Task {
            let summary = """
            這\(periodLabel)完成：\(completedItems.filter { !$0.isEmpty }.joined(separator: "、"))
            卡住的：\(stuckItems.filter { !$0.isEmpty }.joined(separator: "、"))
            調整計劃：\(adjustments.filter { !$0.isEmpty }.joined(separator: "、"))
            目標調整：\(goalAdjustments.filter { !$0.isEmpty }.joined(separator: "、"))
            """
            let service = ServiceLocator.shared.aiProvider
            let prompt = "你是《規劃最好的一年》的AI教練。根據用戶的\(periodLabel)校正數據，生成簡潔的校正建議報告（200字以內），包含：1)肯定已完成的事 2)分析卡住的原因 3)具體可行的調整建議：\n\(summary)"
            let result = await service.sendPrompt(prompt)
            aiReport = result
            isGeneratingReport = false
        }
    }
    
    private func saveCalibration() {
        let calibration = PeriodCalibration(
            periodType: isQuarterly ? "quarterly" : "monthly",
            year: Calendar.current.component(.year, from: Date()),
            period: isQuarterly ? currentQuarter : Calendar.current.component(.month, from: Date()),
            completedItems: completedItems.filter { !$0.isEmpty },
            stuckItems: stuckItems.filter { !$0.isEmpty },
            adjustments: adjustments.filter { !$0.isEmpty },
            goalAdjustments: goalAdjustments.filter { !$0.isEmpty },
            newOpportunities: [],
            aiReport: aiReport
        )
        // 保存到 onboarding_data（通用鍵值存儲）
        if let data = try? JSONEncoder().encode(calibration) {
            let userId = UserDefaultsManager.shared.currentUserId ?? ""
            _ = DatabaseManager.shared.saveOnboardingData(userId: userId, key: "period_calibration_\(calibration.periodType)_\(calibration.year)_\(calibration.period)", data: data)
        }
    }
    
    private var currentQuarter: Int {
        let month = Calendar.current.component(.month, from: Date())
        return (month - 1) / 3 + 1
    }
}
