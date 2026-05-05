import SwiftUI

struct AIInsightView: View {
    @StateObject private var viewModel = AIInsightViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if viewModel.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("AI 正在分析你的數據...")
                            .foregroundColor(AppColors.textSecondary)
                    }
                } else if let insight = viewModel.insight {
                    ScrollView {
                        VStack(spacing: 20) {
                            // 總結卡片
                            InsightSummaryCard(summary: insight.summary, type: insight.type)

                            // 優勢/成就
                            if !insight.strengths.isEmpty {
                                InsightListCard(
                                    title: insight.type == .weekly ? "本週優勢" : "本月成就",
                                    icon: "star.fill",
                                    color: AppColors.success,
                                    items: insight.strengths
                                )
                            }

                            // 改進/挑戰
                            if !insight.improvements.isEmpty {
                                InsightListCard(
                                    title: insight.type == .weekly ? "改進空間" : "面臨挑戰",
                                    icon: "exclamationmark.triangle.fill",
                                    color: AppColors.warning,
                                    items: insight.improvements
                                )
                            }

                            // 聚焦建議
                            if !insight.focus.isEmpty {
                                InsightFocusCard(focus: insight.focus, type: insight.type)
                            }

                            // 激勵語句
                            if !insight.motivationQuote.isEmpty {
                                MotivationCard(quote: insight.motivationQuote)
                            }
                        }
                        .padding()
                    }
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.largeTitle)
                            .foregroundColor(AppColors.warning)
                        Text(error)
                            .foregroundColor(AppColors.textSecondary)
                        Button("重試") { viewModel.generateInsight() }
                            .buttonStyle(.borderedProminent)
                    }
                }
            }
            .navigationTitle(viewModel.isWeekly ? "週洞察報告" : "月洞察報告")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Picker("類型", selection: $viewModel.insightType) {
                        Text("週報").tag(AIInsightType.weekly)
                        Text("月報").tag(AIInsightType.monthly)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                    .onChange(of: viewModel.insightType) { _ in viewModel.generateInsight() }
                }
            }
            .onAppear { viewModel.generateInsight() }
        }
    }
}

// MARK: - Sub Views

struct InsightSummaryCard: View {
    let summary: String
    let type: AIInsightType

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: type == .weekly ? "calendar.badge.clock" : "calendar")
                .font(.title)
                .foregroundColor(AppColors.primary)

            Text(summary)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct InsightListCard: View {
    let title: String
    let icon: String
    let color: Color
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon)
                .font(.headline)
                .foregroundColor(color)

            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1).")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 20)
                    Text(item)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct InsightFocusCard: View {
    let focus: String
    let type: AIInsightType

    var body: some View {
        VStack(spacing: 12) {
            Label(
                type == .weekly ? "下週聚焦" : "下月聚焦",
                systemImage: "target"
            )
            .font(.headline)
            .foregroundColor(AppColors.accent)

            Text(focus)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}

struct MotivationCard: View {
    let quote: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "quote.opening")
                .font(.title3)
                .foregroundColor(AppColors.primary.opacity(0.6))

            Text("「\(quote)」")
                .font(.body)
                .italic()
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Image(systemName: "quote.closing")
                .font(.title3)
                .foregroundColor(AppColors.primary.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
}
