import SwiftUI
import WidgetKit

// MARK: - Small Widget View
struct SmallWidgetView: View {
    var entry: TodayTaskEntry
    
    private var progress: Double {
        guard entry.totalDays > 0 else { return 0 }
        return Double(entry.dayNumber) / Double(entry.totalDays)
    }
    
    private var dimensionColor: Color {
        entry.dimension.toGoalDimension.widgetColor
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
        VStack(alignment: .leading, spacing: 8) {
            // Header with dimension indicator
            HStack {
                Circle()
                    .fill(dimensionColor)
                    .frame(width: 8, height: 8)
                Spacer()
            }
            
            Spacer()
            
            // Task Title
            Text(entry.taskTitle)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            // Progress Circle + Day Label
            HStack(spacing: 12) {
                // Progress Circle
                ZStack {
                    Circle()
                        .stroke(dimensionColor.opacity(0.2), lineWidth: 3)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(dimensionColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(dimensionColor)
                }
                .frame(width: 36, height: 36)
                
                // Day Label
                VStack(alignment: .leading, spacing: 2) {
                    Text(dayLabel)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(entry.totalDays == 7 ? "7天啟動" : "21天挑戰")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary.opacity(0.7))
                }
                
                Spacer()
            }
        }
        .padding(12)
        .widgetBackground(color: dimensionColor.opacity(0.05))
    }
}

// MARK: - Widget Background
extension View {
    func widgetBackground(color: Color) -> some View {
        self.background(color)
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    TodayTaskWidget()
} timeline: {
    TodayTaskEntry(
        date: Date(),
        taskTitle: "設定年度目標",
        taskDescription: "花5分鐘思考今年想要達成的目標",
        dayNumber: 3,
        totalDays: 7,
        dimension: "career",
        aiTip: "好的開始是成功的一半！",
        isPlaceholder: false
    )
}