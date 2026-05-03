import Foundation

struct DirectionalSuggestion: Identifiable {
    let id = UUID()
    let dimension: GoalDimension
    let title: String
    let description: String
    let actionSteps: [String]
    let inspiringQuote: String
}