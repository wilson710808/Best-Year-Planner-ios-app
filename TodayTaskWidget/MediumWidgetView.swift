import SwiftUI
import WidgetKit

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    var entry: TodayTaskEntry
    
    private var progress: Double {
        guard entry.totalDays > 0 else { return 0 }
        return Double(entry.dayNumber) / Double(entry.totalDays)
    }
    
    private var dimensionColor: Color {
        entry.dimension.toGoalDimension.widgetColor
    }
    
    private var dimensionDisplayName: String {
        switch entry.dimension.toGoalDimension {
        case .career: return "事業"
        case .relationship: return "關係"
        case .growth: return "成長"
        }
    }
    
    private var dayLabel: String {
        if entry.totalDays == 7 {
            return "第 \(entry.dayNumber)/7 天"
        } else if entry.totalDays == 21 {
            return "第 \(entry.dayNumber)/21 天"
        } else {
            return "第 \(entry.dayNumber) 天"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left: Content
            VStack(alignment: .leading, spacing: 8) {
                // Header with dimension
                HStack(spacing: 6) {
                    // Dimension color bar
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(dimensionColor)
                        .frame(width: 3, height: 16)
                    
                    Text(dimensionDisplayName)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(dimensionColor)
                }
                
                // Task Title
                Text(entry.taskTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                // Task Description
                Text(entry.taskDescription)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Spacer()
                
                // AI Tip
                if let aiTip = entry.aiTip, !aiTip.isEmpty {
                    HStack(alignment: .top, spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        
                        Text(aiTip)
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    .padding(8)
                    .background(Color.yellow.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Right: Progress
            VStack(spacing: 8) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(dimensionColor.opacity(0.2), lineWidth: 6)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(dimensionColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 2) {
                        Text("\(entry.dayNumber)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(dimensionColor)
                        Text("/ \(entry.totalDays)")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 70, height: 70)
                
                // Day Label
                Text(dayLabel)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                
                // App Name
                Text("最好的一年")
                    .font(.system(size: 10))
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .padding(16)
        .widgetBackground(color: dimensionColor.opacity(0.03))
    }
}

// MARK: - Preview
#Preview(as: .systemMedium) {
    TodayTaskWidget()
} timeline: {
    TodayTaskEntry(
        date: Date(),
        taskTitle: "設定年度目標",
        taskDescription: "花5分鐘思考今年想要達成的目標，並把它們寫下來",
        dayNumber: 3,
        totalDays: 7,
        dimension: "career",
        aiTip: "好的開始是成功的一半！今天邁出了關鍵的一步。",
        isPlaceholder: false
    )
}