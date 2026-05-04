import Foundation
import WidgetKit

// MARK: - Dimension Enum (Widget Local Copy)
enum WidgetDimension: String, Codable {
    case career
    case relationship
    case growth
    
    var widgetColor: Color {
        switch self {
        case .career:
            return Color(red: 52/255, green: 152/255, blue: 219/255) // #3498DB
        case .relationship:
            return Color(red: 231/255, green: 76/255, blue: 140/255) // #E74C8C
        case .growth:
            return Color(red: 39/255, green: 174/255, blue: 96/255)  // #27AE60
        }
    }
}

// MARK: - Today Task Data (Shared with App)
struct TodayTaskData: Codable {
    let taskTitle: String
    let taskDescription: String
    let dayNumber: Int
    let totalDays: Int
    let dimension: String
    let aiTip: String?
    let updatedAt: String
}

// MARK: - Widget Data Provider
final class WidgetDataProvider {
    static let shared = WidgetDataProvider()
    
    private let appGroupSuiteName = "group.com.bestyearplanner"
    private let todayTaskKey = "todayTask"
    
    private init() {}
    
    // MARK: - Get Current Entry
    func getCurrentEntry() -> TodayTaskEntry {
        guard let data = getTodayTaskData() else {
            return TodayTaskEntry.placeholder
        }
        
        return TodayTaskEntry(
            date: Date(),
            taskTitle: data.taskTitle,
            taskDescription: data.taskDescription,
            dayNumber: data.dayNumber,
            totalDays: data.totalDays,
            dimension: data.dimension,
            aiTip: data.aiTip,
            isPlaceholder: false
        )
    }
    
    // MARK: - Get Today Task Data from App Group
    private func getTodayTaskData() -> TodayTaskData? {
        guard let defaults = UserDefaults(suiteName: appGroupSuiteName),
              let jsonString = defaults.string(forKey: todayTaskKey),
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            let taskData = try JSONDecoder().decode(TodayTaskData.self, from: jsonData)
            
            // Check if data is stale (more than 24 hours old)
            let calendar = Calendar.current
            if let hoursDiff = calendar.dateComponents([.hour], from: taskData.updatedAt, to: Date()).hour,
               hoursDiff > 24 {
                return nil
            }
            
            return taskData
        } catch {
            print("Error decoding today task data: \(error)")
            return nil
        }
    }
    
    // MARK: - Save Today Task Data (Called from App)
    func saveTodayTaskData(_ taskData: TodayTaskData) {
        guard let defaults = UserDefaults(suiteName: appGroupSuiteName) else {
            print("Error: Could not access app group UserDefaults")
            return
        }
        
        do {
            let jsonData = try JSONEncoder().encode(taskData)
            let jsonString = String(data: jsonData, encoding: .utf8)
            defaults.set(jsonString, forKey: todayTaskKey)
            defaults.synchronize()
            
            // Reload widget timelines
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Error encoding today task data: \(error)")
        }
    }
    
    // MARK: - Clear Today Task Data
    func clearTodayTaskData() {
        guard let defaults = UserDefaults(suiteName: appGroupSuiteName) else { return }
        defaults.removeObject(forKey: todayTaskKey)
        defaults.synchronize()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

// MARK: - Helper Extension for Color
extension GoalDimension {
    var widgetColor: Color {
        switch self {
        case .career:
            return Color(red: 52/255, green: 152/255, blue: 219/255) // #3498DB
        case .relationship:
            return Color(red: 231/255, green: 76/255, blue: 140/255) // #E74C8C
        case .growth:
            return Color(red: 39/255, green: 174/255, blue: 96/255)  // #27AE60
        }
    }
}

// MARK: - String Extension for Dimension
extension String {
    var toGoalDimension: GoalDimension {
        switch self.lowercased() {
        case "career": return .career
        case "relationship": return .relationship
        case "growth": return .growth
        default: return .growth
        }
    }
}