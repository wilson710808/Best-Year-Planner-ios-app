import Foundation
import Combine

@MainActor
final class GoalViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var selectedDimension: GoalDimension?
    @Published var selectedGoal: Goal?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let goalService = GoalService.shared

    var careerGoals: [Goal] {
        goals.filter { $0.dimension == .career && $0.level == .yearly }
    }

    var relationshipGoals: [Goal] {
        goals.filter { $0.dimension == .relationship && $0.level == .yearly }
    }

    var growthGoals: [Goal] {
        goals.filter { $0.dimension == .growth && $0.level == .yearly }
    }

    var activeGoals: [Goal] {
        goals.filter { $0.status == .active }
    }

    func loadGoals() {
        isLoading = true
        goals = goalService.getAllGoals()
        isLoading = false
    }

    func loadGoals(forDimension dimension: GoalDimension) {
        isLoading = true
        selectedDimension = dimension
        goals = goalService.getGoals(byDimension: dimension)
        isLoading = false
    }

    func createGoal(_ goal: Goal) -> Bool {
        let result = goalService.createGoal(goal)
        switch result {
        case .success:
            loadGoals()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateGoal(_ goal: Goal) -> Bool {
        let result = goalService.updateGoal(goal)
        switch result {
        case .success:
            loadGoals()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func deleteGoal(_ goalId: String) -> Bool {
        let result = goalService.deleteGoal(goalId)
        switch result {
        case .success:
            loadGoals()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func pauseGoal(_ goalId: String) -> Bool {
        let result = goalService.pauseGoal(goalId)
        switch result {
        case .success:
            loadGoals()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func resumeGoal(_ goalId: String) -> Bool {
        let result = goalService.resumeGoal(goalId)
        switch result {
        case .success:
            loadGoals()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func updateGoalProgress(_ goalId: String, progress: Double) -> Bool {
        let result = goalService.updateGoalProgress(goalId, progress: progress)
        switch result {
        case .success:
            loadGoals()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func selectGoal(_ goal: Goal) {
        selectedGoal = goal
    }

    func clearSelection() {
        selectedGoal = nil
    }

    func getOverallProgress() -> Double {
        goalService.getOverallProgress()
    }

    func getDimensionProgress(_ dimension: GoalDimension) -> Double {
        goalService.getDimensionProgress(dimension)
    }
}
