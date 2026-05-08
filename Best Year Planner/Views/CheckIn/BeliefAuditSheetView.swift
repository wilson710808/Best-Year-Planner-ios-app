import SwiftUI

/// 信念審計 Sheet — 勾選10條常見信念 + AI即時生成轉化視角
struct BeliefAuditSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var limitingBeliefs: [String] = ["", "", ""]
    @State private var reframedBeliefs: [String] = ["", "", ""]
    @State private var currentStep = 0
    @State private var aiGuidance: String = ""
    @State private var isLoading = false
    // 勾選常見信念
    @State private var commonBeliefSelections: [Bool] = Array(repeating: false, count: 10)
    @State private var selectedCommonBeliefs: [String] = []

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if currentStep == 0 {
                            // Step 0: 勾選常見限制性信念
                            commonBeliefChecklistStep
                        } else if currentStep == 1 {
                            // Step 1: 識別限制性信念（自由填寫）
                            beliefIdentificationStep
                        } else if currentStep == 2 {
                            // Step 2: 反轉信念
                            beliefReframeStep
                        } else {
                            // Step 3: 選擇一個信念行動驗證
                            beliefCommitStep
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🧠 信念審計")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(currentStep == 0 ? "稍後" : "上一步") {
                        if currentStep > 0 { currentStep -= 1 } else { dismiss() }
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    if currentStep < 3 {
                        Button("下一步") {
                            if currentStep == 0 {
                                // 將勾選的常見信念帶入
                                selectedCommonBeliefs = commonLimitingBeliefs.enumerated()
                                    .filter { commonBeliefSelections[$0.offset] }
                                    .map { $0.element }
                                for (i, belief) in selectedCommonBeliefs.prefix(3).enumerated() {
                                    limitingBeliefs[i] = belief
                                }
                            }
                            currentStep += 1
                        }
                        .disabled(currentStep == 0 && commonBeliefSelections.allSatisfy { !$0 } && limitingBeliefs.allSatisfy { $0.isEmpty })
                    } else {
                        Button("完成") { dismiss() }
                    }
                }
            }
        }
    }

    // MARK: - Step 0: 勾選常見限制性信念

    private var commonBeliefChecklistStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🧠 勾選你認同的限制性信念")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("以下10條是最常見的限制性信念，勾選那些你也有的想法。我們會幫你逐一轉化！")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            VStack(spacing: 8) {
                ForEach(0..<commonLimitingBeliefs.count, id: \.self) { index in
                    Button(action: {
                        commonBeliefSelections[index].toggle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: commonBeliefSelections[index] ? "checkmark.square.fill" : "square")
                                .font(.title3)
                                .foregroundColor(commonBeliefSelections[index] ? AppColors.primary : AppColors.divider)

                            Text(commonLimitingBeliefs[index])
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                                .multilineTextAlignment(.leading)
                                
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(commonBeliefSelections[index] ? AppColors.primary.opacity(0.05) : Color.clear)
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            HStack {
                Text("已勾選 \(commonBeliefSelections.filter { $0 }.count)/10")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
                Button("全選") {
                    commonBeliefSelections = Array(repeating: true, count: 10)
                }
                .font(.caption)
                .foregroundColor(AppColors.primary)
                Button("全取消") {
                    commonBeliefSelections = Array(repeating: false, count: 10)
                }
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    // MARK: - Step 1: 識別限制性信念

    private var beliefIdentificationStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📝 第一步：識別你的限制性信念")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("寫下最近出現的「我做不到X，因為Y」的想法。這些不是事實，只是舊信念。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<3, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("限制性信念 #\(index + 1)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)

                    TextField("我做不到...因為...", text: $limitingBeliefs[index])
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.divider, lineWidth: 1)
                        )
                }
            }

            // 常見範例提示
            VStack(alignment: .leading, spacing: 8) {
                Text("💡 常見的限制性信念：")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                ForEach(commonLimitingBeliefs, id: \.self) { belief in
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption2)
                            .foregroundColor(AppColors.warning)
                        Text(belief)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .padding()
            .background(AppColors.warning.opacity(0.05))
            .cornerRadius(12)
        }
    }

    // MARK: - Step 2: 反轉信念

    private var beliefReframeStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🔄 第二步：反轉為開放性信念")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("把「做不到」轉為「正在找到方法」。這不是自我欺騙，而是選擇一個讓你能行動的視角。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<3, id: \.self) { index in
                if !limitingBeliefs[index].isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        // 原始限制性信念
                        HStack(spacing: 8) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(AppColors.error)
                            Text(limitingBeliefs[index])
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .strikethrough()
                        }

                        Image(systemName: "arrow.down")
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)

                        // 反轉後的開放性信念
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.success)
                            TextField("我正在找到方法...", text: $reframedBeliefs[index])
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding()
                        .background(AppColors.success.opacity(0.05))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.success.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
                }
            }

            // AI 引導反轉
            Button(action: { generateAIReframe() }) {
                HStack {
                    Image(systemName: "sparkles")
                    Text(isLoading ? "AI 正在分析..." : "讓 AI 幫我反轉")
                }
                .font(.subheadline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(isLoading ? AppColors.disabled : AppColors.primary)
                .cornerRadius(12)
            }
            .disabled(isLoading)

            if !aiGuidance.isEmpty {
                Text(aiGuidance)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .padding()
                    .background(AppColors.primary.opacity(0.05))
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Step 3: 行動承諾

    private var beliefCommitStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🎯 第三步：選擇一個信念，用行動驗證")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("信念轉化最強的證明不是想通，而是做到。選擇一個反轉後的信念，明天用5分鐘行動驗證它。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<3, id: \.self) { index in
                if !reframedBeliefs[index].isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(AppColors.success)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(limitingBeliefs[index])
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                                .strikethrough()
                            Text(reframedBeliefs[index])
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.success)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                }
            }

            // 總結
            VStack(spacing: 12) {
                Image(systemName: "heart.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(AppColors.accent)

                Text("你今天的覺察，已經在改寫舊故事了。")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text("每一次你選擇行動而非逃避，\n你都在證明那個「做不到」的想法不是事實。")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                LinearGradient(
                    colors: [AppColors.accent.opacity(0.05), AppColors.primary.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(16)
        }
    }

    // MARK: - Helper

    private var commonLimitingBeliefs: [String] {
        [
            "我做不到 — 因為我以前試過都失敗",
            "我沒時間 — 因為太忙了",
            "我不夠好 — 因為別人比我強",
            "太難了 — 因為這超出我的能力",
            "這沒用 — 因為試了也不會改變",
            "我總是放棄 — 因為我缺乏毅力"
        ]
    }

    private func generateAIReframe() {
        isLoading = true
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let beliefs = limitingBeliefs.filter { !$0.isEmpty }.map { "「\($0)」" }.joined(separator: "、")

        let prompt = BeliefTransformationPrompts.beliefAuditPrompt + "\n\n用戶的限制性信念：\(beliefs)"

        Task {
            let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
            let response = await aiProvider.query(userId: userId, query: prompt)
            aiGuidance = response
            isLoading = false
        }
    }
}
