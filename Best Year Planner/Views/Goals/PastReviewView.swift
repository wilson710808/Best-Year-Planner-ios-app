import SwiftUI

/// 「總結過去」年度回顧 — 基於《規劃最好的一年》第二步
struct PastReviewView: View {
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var currentStep = 0
    @State private var isGeneratingReport = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // 進度指示器
                        StepIndicator(currentStep: currentStep, totalSteps: 4)

                        if currentStep == 0 {
                            achievementsStep
                        } else if currentStep == 1 {
                            regretsStep
                        } else if currentStep == 2 {
                            lessonsStep
                        } else {
                            reportStep
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("📜 總結過去")
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
                            Task { await viewModel.saveYearlyReview() }
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear { viewModel.loadYearlyReview() }
    }

    // MARK: - Step 1: 最大的成就

    private var achievementsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏆 去年最大的3個成就")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("回想過去一年，你完成了什麼讓你自豪的事？不一定要驚天動地，堅持做一件事就是成就。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<3, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("成就 #\(index + 1)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    TextField("描述你的成就...", text: $viewModel.topAchievements[index])
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                }
            }

            insightCard(icon: "lightbulb.fill", color: AppColors.accent,
                        text: "提示：成就不只是結果。開始行動、克服恐懼、學會求助——這些都是成就。")
        }
    }

    // MARK: - Step 2: 遺憾或挑戰

    private var regretsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💭 3個遺憾或挑戰")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("什麼事你本來想做但沒做到？這不是自責，而是誠實面對，才能找到下一步。")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<3, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("遺憾 #\(index + 1)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    TextField("什麼事沒做到？", text: $viewModel.regrets[index])
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                }
            }

            insightCard(icon: "heart.fill", color: AppColors.accent,
                        text: "遺憾是「未完成的事」，不是「失敗」。它們指向你真正在乎的方向。")
        }
    }

    // MARK: - Step 3: 學到的教訓

    private var lessonsStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🧠 從中學到的3個教訓")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text("每個經歷都在教你一些東西。你從成就和遺憾中學到了什麼？")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ForEach(0..<3, id: \.self) { index in
                VStack(alignment: .leading, spacing: 4) {
                    Text("教訓 #\(index + 1)")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    TextField("我學到了...", text: $viewModel.lessonsLearned[index])
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                }
            }

            insightCard(icon: "sparkles", color: AppColors.primary,
                        text: "教訓是你最珍貴的資產。它們會成為下一年的導航系統。")
        }
    }

    // MARK: - Step 4: AI 經驗萃取報告

    private var reportStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📋 經驗萃取報告")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            if isGeneratingReport {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("AI 正在分析你的經歷...")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(32)
                .background(AppColors.cardBackground)
                .cornerRadius(16)
            } else if let report = viewModel.yearlyReview?.aiExperienceReport {
                Text(report)
                    .font(.body)
                    .foregroundColor(AppColors.textPrimary)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(16)
            } else {
                Button(action: {
                    Task {
                        isGeneratingReport = true
                        await viewModel.saveYearlyReview()
                        isGeneratingReport = false
                    }
                }) {
                    HStack {
                        Image(systemName: "sparkles")
                        Text("生成 AI 經驗萃取報告")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AppColors.primary)
                    .cornerRadius(12)
                }
            }

            // 輸入回顧摘要
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    if !viewModel.topAchievements[index].isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "trophy.fill")
                                .foregroundColor(AppColors.accent)
                                .font(.caption)
                            Text(viewModel.topAchievements[index])
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                ForEach(0..<3, id: \.self) { index in
                    if !viewModel.regrets[index].isEmpty {
                        HStack(spacing: 8) {
                            Image(systemName: "cloud.fill")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.caption)
                            Text(viewModel.regrets[index])
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
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
}

// MARK: - Step Indicator

struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int

    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalSteps, id: \.self) { step in
                Circle()
                    .fill(step <= currentStep ? AppColors.primary : AppColors.divider)
                    .frame(width: step == currentStep ? 12 : 8, height: step == currentStep ? 12 : 8)
                    .animation(.easeInOut, value: currentStep)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }
}
