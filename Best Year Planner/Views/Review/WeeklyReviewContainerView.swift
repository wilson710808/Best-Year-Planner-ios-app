import SwiftUI

struct WeeklyReviewContainerView: View {
    @StateObject private var viewModel = ReviewViewModel()
    @State private var isGenerating = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 週復盤標題
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.primary)

                    Text("每週復盤")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(currentWeekString)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 24)

                if let review = viewModel.currentWeeklyReview {
                    // 已有復盤結果
                    ReviewContentView(review: review)
                } else if isGenerating {
                    // 正在生成
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("AI 正在分析本週數據...")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(40)
                } else {
                    // 尚未復盤
                    VStack(spacing: 16) {
                        Text("本週尚未進行復盤")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)

                        Text("讓 AI 幫你回顧本週的進展，發現需要改進的地方")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button(action: generateWeeklyReview) {
                            Text("開始週復盤")
                                .primaryButtonStyle()
                        }
                    }
                    .padding(24)
                }

                // 歷史週復盤
                if viewModel.weeklyReviews.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("歷史復盤")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)

                        ForEach(viewModel.weeklyReviews.dropFirst().prefix(5)) { review in
                            NavigationLink(destination: ReviewDetailView(review: review)) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(AppColors.primary)
                                    Text(review.period)
                                        .font(.subheadline)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(AppColors.disabled)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
            .padding(.bottom, 32)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(StringConstants.AICoach.weeklyReviewTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadReviews()
        }
    }

    private var currentWeekString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年 第ww週"
        return formatter.string(from: Date())
    }

    private func generateWeeklyReview() {
        isGenerating = true
        viewModel.createWeeklyReview()
        // 模擬 AI 生成延遲
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isGenerating = false
        }
    }
}

struct ReviewContentView: View {
    let review: Review

    var body: some View {
        VStack(spacing: 16) {
            // 總結
            if !review.summary.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("本週總結", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(review.summary)
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // 成就
            if !review.achievements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("本週成就 🎉", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    ForEach(review.achievements, id: \.self) { achievement in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(AppColors.secondary)
                            Text(achievement)
                                .font(.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.secondary.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // 改進空間
            if !review.improvements.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("需要改進 💪", systemImage: "arrow.up.circle")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    ForEach(review.improvements, id: \.self) { improvement in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(AppColors.accent)
                            Text(improvement)
                                .font(.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.accent.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // 下週重點
            if let nextWeekFocus = review.nextWeekFocus, !nextWeekFocus.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("下週重點 🎯", systemImage: "target")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    ForEach(nextWeekFocus, id: \.self) { focus in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .foregroundColor(AppColors.primary)
                            Text(focus)
                                .font(.body)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            // AI 建議
            if !review.aiSuggestions.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("AI 建議 🤖", systemImage: "brain.head.profile")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text(review.aiSuggestions)
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.05))
                .cornerRadius(12)
                .padding(.horizontal)
            }
        }
    }
}

struct ReviewDetailView: View {
    let review: Review

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(review.period)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.textPrimary)

                Text(review.createdAt.formatted(AppConstants.DateFormats.displayDateTime))
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                ReviewContentView(review: review)
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(review.type.displayName)
        .navigationBarTitleDisplayMode(.inline)
    }
}
