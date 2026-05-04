import SwiftUI

struct MonthlyReviewView: View {
    @StateObject private var viewModel = ReviewViewModel()
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 月度復盤標題
                VStack(spacing: 12) {
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(AppColors.accent)

                    Text("月度復盤")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(currentMonthString)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 24)

                if let review = viewModel.currentMonthlyReview {
                    ReviewContentView(review: review)
                } else if isGenerating {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("AI 正在分析本月數據...")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(40)
                } else {
                    VStack(spacing: 16) {
                        Text("本月尚未進行復盤")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)

                        Text("讓 AI 幫你回顧本月進展，調整下月計劃")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)

                        Button(action: generateMonthlyReview) {
                            Text("開始月度復盤")
                                .primaryButtonStyle()
                        }
                    }
                    .padding(24)
                }

                // 歷史月度復盤
                if viewModel.monthlyReviews.count > 1 {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("歷史月度復盤")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.horizontal)

                        ForEach(viewModel.monthlyReviews.dropFirst().prefix(5)) { review in
                            NavigationLink(destination: ReviewDetailView(review: review)) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundColor(AppColors.accent)
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

                Spacer(minLength: 32)
            }
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(StringConstants.AICoach.monthlyReviewTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadReviews()
        }
    }

    private var currentMonthString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月"
        return formatter.string(from: Date())
    }

    private func generateMonthlyReview() {
        isGenerating = true
        viewModel.createMonthlyReview()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            isGenerating = false
        }
    }
}
