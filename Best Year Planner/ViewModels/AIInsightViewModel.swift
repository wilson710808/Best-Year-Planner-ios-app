import Foundation
import Combine

@MainActor
final class AIInsightViewModel: ObservableObject {
    @Published var insight: AIInsight?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var insightType: AIInsightType = .weekly

    private let insightService = AIInsightService.shared
    var isWeekly: Bool { insightType == .weekly }

    func generateInsight() {
        isLoading = true
        errorMessage = nil
        insight = nil

        let userId = UserDefaultsManager.shared.currentUserId ?? ""

        Task {
            do {
                let result: AIInsight?
                switch insightType {
                case .weekly:
                    result = await insightService.generateWeeklyInsight(userId: userId)
                case .monthly:
                    result = await insightService.generateMonthlyInsight(userId: userId)
                }

                if let result = result {
                    insight = result
                } else {
                    errorMessage = "無法生成洞察報告，請稍後再試。"
                }
                isLoading = false
            }
        }
    }
}
