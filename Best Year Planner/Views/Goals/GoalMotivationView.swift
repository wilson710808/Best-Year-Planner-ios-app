import SwiftUI

/// 「找到為什麼」目標動機輸入 — 基於《規劃最好的一年》第三步
struct GoalMotivationView: View {
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
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🎯 為什麼你要完成這個目標？")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)

                            Text("「沒有動機的目標，很難堅持。」寫下3個你一定要完成「\(goalTitle)」的原因。")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        // 3 Whys Input
                        ForEach(0..<3, id: \.self) { index in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(AppColors.primary)
                                        .frame(width: 24, height: 24)
                                        .overlay(Text("\(index + 1)").font(.caption2).foregroundColor(.white))
                                    Text("為什麼 #\(index + 1)")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                                TextField("因為...", text: $viewModel.currentGoalWhys[index])
                                    .padding()
                                    .background(AppColors.cardBackground)
                                    .cornerRadius(12)
                                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))
                            }
                        }

                        // 生成動機卡片
                        Button(action: {
                            Task {
                                isGenerating = true
                                await viewModel.saveGoalMotivation(goalId: goalId, goalTitle: goalTitle)
                                isGenerating = false
                            }
                        }) {
                            HStack {
                                if isGenerating { ProgressView().tint(.white) }
                                Image(systemName: "sparkles")
                                Text(isGenerating ? "生成中..." : "生成動機卡片")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isGenerating ? AppColors.disabled : AppColors.primary)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating || viewModel.currentGoalWhys.allSatisfy { $0.isEmpty })

                        // 動機卡片展示
                        if let card = viewModel.motivationCard {
                            VStack(spacing: 12) {
                                Image(systemName: "heart.circle.fill")
                                    .font(.largeTitle)
                                    .foregroundColor(AppColors.accent)
                                Text(card)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(colors: [AppColors.accent.opacity(0.05), AppColors.primary.opacity(0.05)],
                                               startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(16)
                            .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColors.accent.opacity(0.2), lineWidth: 1))
                        }

                        // 動機耗盡提醒說明
                        HStack(alignment: .top, spacing: 12) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(AppColors.accent)
                            Text("連續3天未打卡時，系統會自動顯示你的動機卡片，提醒你為什麼出發。")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .background(AppColors.accent.opacity(0.05))
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("找到為什麼")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .onAppear { viewModel.loadGoalMotivation(goalId: goalId) }
    }
}

// MARK: - AI 教練風格選擇器

struct CoachStylePickerView: View {
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        Text("選擇你的 AI 教練風格")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        Text("不同風格適合不同性格，你可以隨時更換。")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        ForEach(CoachStyle.allCases, id: \.self) { style in
                            Button(action: { viewModel.saveCoachStyle(style) }) {
                                HStack(spacing: 16) {
                                    Image(systemName: style.icon)
                                        .font(.title2)
                                        .foregroundColor(viewModel.coachStyle == style ? AppColors.primary : AppColors.textSecondary)
                                        .frame(width: 40)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(style.displayName)
                                            .font(.subheadline)
                                            .fontWeight(viewModel.coachStyle == style ? .bold : .regular)
                                            .foregroundColor(AppColors.textPrimary)
                                        Text(style.systemPromptSuffix)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textSecondary)
                                            .lineLimit(2)
                                    }

                                    Spacer()

                                    if viewModel.coachStyle == style {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                            .font(.title3)
                                    }
                                }
                                .padding()
                                .background(viewModel.coachStyle == style ? AppColors.primary.opacity(0.05) : AppColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(viewModel.coachStyle == style ? AppColors.primary : AppColors.divider, lineWidth: viewModel.coachStyle == style ? 2 : 1)
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🧘 教練風格")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .onAppear { viewModel.loadCoachStyle() }
    }
}
