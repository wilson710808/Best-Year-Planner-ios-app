import SwiftUI

/// SMARTER 目標評分器 — 基於《規劃最好的一年》目標7原則
struct SMARTERScorerView: View {
    let goalId: String
    let goalTitle: String
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Overall Score
                        overallScoreCard

                        // 7 Dimensions
                        ForEach(smarterDimensions, id: \.0) { key, title, icon, description, binding in
                            dimensionCard(key: key, title: title, icon: icon, description: description, value: binding)
                        }

                        // AI Suggestions
                        if !viewModel.smarterSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("💡 AI 改進建議")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                ForEach(viewModel.smarterSuggestions, id: \.self) { suggestion in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                            .font(.caption)
                                        Text(suggestion)
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.primary.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.top)
                        }

                        // Generate Button
                        Button(action: {
                            Task {
                                isGenerating = true
                                await viewModel.saveSMARTERScore(goalId: goalId, goalTitle: goalTitle)
                                isGenerating = false
                            }
                        }) {
                            HStack {
                                if isGenerating { ProgressView().tint(.white) }
                                Image(systemName: "sparkles")
                                Text(isGenerating ? "AI 分析中..." : "獲取 AI 改進建議")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isGenerating ? AppColors.disabled : AppColors.primary)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating)
                    }
                    .padding()
                }
            }
            .navigationTitle("🎯 SMARTER 評分")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.loadSMARTERScore(goalId: goalId)
            if viewModel.currentSMARTER == nil {
                viewModel.currentSMARTER = SMARTERScore(goalId: goalId)
            }
        }
    }

    private var overallScoreCard: some View {
        VStack(spacing: 12) {
            Text(goalTitle)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)

            ZStack {
                Circle()
                    .stroke(AppColors.divider, lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: min(viewModel.currentSMARTER?.overallScore ?? 0 / 10.0, 1.0))
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))

                Text(String(format: "%.1f", viewModel.currentSMARTER?.overallScore ?? 0))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textPrimary)

                Text("/10")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .offset(y: 12)
            }

            Text(scoreMessage)
                .font(.caption)
                .foregroundColor(scoreColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private var scoreColor: Color {
        let score = viewModel.currentSMARTER?.overallScore ?? 0
        if score >= 8 { return AppColors.success }
        if score >= 6 { return AppColors.accent }
        return AppColors.error
    }

    private var scoreMessage: String {
        let score = viewModel.currentSMARTER?.overallScore ?? 0
        if score >= 8 { return "🌟 優秀目標！你已經做好準備了" }
        if score >= 6 { return "💪 不錯！還有一些可以強化的地方" }
        return "🔄 建議調整目標，讓它更具行動力" }
    }

    private func dimensionCard(key: String, title: String, icon: String, description: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(value.wrappedValue < 6 ? AppColors.error : AppColors.success)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)

            Slider(value: value, in: 1...10, step: 1) {
                Text(title)
            }
            .tint(value.wrappedValue < 6 ? AppColors.error : AppColors.primary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // 7 dimensions with bindings
    private var smarterDimensions: [(String, String, String, String, Binding<Double>)] {
        guard let score = viewModel.currentSMARTER else { return [] }
        return [
            ("specific", "具體 (Specific)", "target", "目標夠明確嗎？「變瘦」vs「減重5公斤」", Binding(
                get: { Double(score.specific) },
                set: { viewModel.currentSMARTER?.specific = Int($0) }
            )),
            ("measurable", "可衡量 (Measurable)", "chart.bar", "有沒有可以量化的指標？", Binding(
                get: { Double(score.measurable) },
                set: { viewModel.currentSMARTER?.measurable = Int($0) }
            )),
            ("actionable", "可執行 (Actionable)", "figure.run", "目標是行動導向的嗎？「每天跑步」vs「變健康」", Binding(
                get: { Double(score.actionable) },
                set: { viewModel.currentSMARTER?.actionable = Int($0) }
            )),
            ("risky", "風險度 (Risky)", "flame.fill", "目標在舒適區外嗎？太安全的目標不會帶來成長", Binding(
                get: { Double(score.risky) },
                set: { viewModel.currentSMARTER?.risky = Int($0) }
            )),
            ("timeKeyed", "有時限 (Time-keyed)", "clock.fill", "有明確的截止日期嗎？", Binding(
                get: { Double(score.timeKeyed) },
                set: { viewModel.currentSMARTER?.timeKeyed = Int($0) }
            )),
            ("exciting", "令人興奮 (Exciting)", "star.fill", "想到這個目標會心跳加速嗎？低於6分建議重新考慮", Binding(
                get: { Double(score.exciting) },
                set: { viewModel.currentSMARTER?.exciting = Int($0) }
            )),
            ("relevant", "相關 (Relevant)", "arrow.triangle.2.circlepath", "這個目標和你的年度大方向一致嗎？", Binding(
                get: { Double(score.relevant) },
                set: { viewModel.currentSMARTER?.relevant = Int($0) }
            ))
        ]
    }
}
