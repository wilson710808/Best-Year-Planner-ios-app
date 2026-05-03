import Foundation
import Combine

@MainActor
final class ReviewViewModel: ObservableObject {
    @Published var weeklyReviews: [Review] = []
    @Published var monthlyReviews: [Review] = []
    @Published var yearlyReviews: [Review] = []
    @Published var currentWeeklyReview: Review?
    @Published var currentMonthlyReview: Review?
    @Published var currentYearlyReview: Review?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let reviewService = ReviewService.shared

    func loadReviews() {
        isLoading = true

        weeklyReviews = reviewService.getWeeklyReviews()
        monthlyReviews = reviewService.getMonthlyReviews()
        yearlyReviews = reviewService.getYearlyReviews()

        currentWeeklyReview = reviewService.getLatestReview(byType: .weekly)
        currentMonthlyReview = reviewService.getLatestReview(byType: .monthly)
        currentYearlyReview = reviewService.getLatestReview(byType: .yearly)

        isLoading = false
    }

    func createWeeklyReview() {
        isLoading = true
        let review = reviewService.createWeeklyReview()
        currentWeeklyReview = review
        weeklyReviews.insert(review, at: 0)
        isLoading = false
    }

    func createMonthlyReview() {
        isLoading = true
        let review = reviewService.createMonthlyReview()
        currentMonthlyReview = review
        monthlyReviews.insert(review, at: 0)
        isLoading = false
    }

    func createYearlyReview() {
        isLoading = true
        let review = reviewService.createYearlyReview()
        currentYearlyReview = review
        yearlyReviews.insert(review, at: 0)
        isLoading = false
    }

    func shouldShowWeeklyReview() -> Bool {
        let lastReview = reviewService.getLatestReview(byType: .weekly)
        guard let lastDate = lastReview?.createdAt else { return true }

        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: Date())
        let lastWeekOfYear = calendar.component(.weekOfYear, from: lastDate)

        return weekOfYear != lastWeekOfYear
    }

    func shouldShowMonthlyReview() -> Bool {
        let lastReview = reviewService.getLatestReview(byType: .monthly)
        guard let lastDate = lastReview?.createdAt else { return true }

        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let lastMonth = calendar.component(.month, from: lastDate)

        return month != lastMonth
    }
}
