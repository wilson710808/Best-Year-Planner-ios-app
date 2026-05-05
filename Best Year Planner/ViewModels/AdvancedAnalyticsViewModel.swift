import Foundation
import Combine

@MainActor
final class AdvancedAnalyticsViewModel: ObservableObject {
    @Published var stats: AnalyticsService.OverviewStats?
    @Published var dimensionTrends: [AnalyticsService.DimensionTrend] = []
    @Published var goalTimeline: [AnalyticsService.GoalCompletionTimeline] = []
    @Published var habitCurves: [AnalyticsService.HabitCurve] = []
    @Published var isLoading: Bool = false

    private let analyticsService = AnalyticsService.shared

    func refresh() {
        isLoading = true
        stats = analyticsService.getOverviewStats()
        dimensionTrends = analyticsService.getDimensionTrends()
        goalTimeline = analyticsService.getGoalCompletionTimeline()
        habitCurves = analyticsService.getHabitCurves()
        isLoading = false
    }
}
