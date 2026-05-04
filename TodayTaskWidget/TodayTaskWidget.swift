import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct TodayTaskEntry: TimelineEntry {
    let date: Date
    let taskTitle: String
    let taskDescription: String
    let dayNumber: Int
    let totalDays: Int
    let dimension: String
    let aiTip: String?
    let isPlaceholder: Bool

    static var placeholder: TodayTaskEntry {
        TodayTaskEntry(
            date: Date(),
            taskTitle: "設定年度目標",
            taskDescription: "花5分鐘思考今年想要達成的目標",
            dayNumber: 1,
            totalDays: 7,
            dimension: "career",
            aiTip: "好的開始是成功的一半！",
            isPlaceholder: true
        )
    }
}

// MARK: - Timeline Provider
struct TodayTaskTimelineProvider: TimelineProvider {
    typealias Entry = TodayTaskEntry

    func placeholder(in context: Context) -> TodayTaskEntry {
        TodayTaskEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayTaskEntry) -> Void) {
        let entry = context.isPreview ? TodayTaskEntry.placeholder : WidgetDataProvider.shared.getCurrentEntry()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayTaskEntry>) -> Void) {
        let currentEntry = WidgetDataProvider.shared.getCurrentEntry()
        
        // Refresh every 2 hours
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
        
        let timeline = Timeline(entries: [currentEntry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Configuration
struct TodayTaskWidget: Widget {
    let kind: String = "TodayTaskWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodayTaskTimelineProvider()) { entry in
            TodayTaskWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("今日任務")
        .description("顯示今日的挑戰任務進度")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Widget Entry View
struct TodayTaskWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: TodayTaskEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    TodayTaskWidget()
} timeline: {
    TodayTaskEntry.placeholder
}

#Preview(as: .systemMedium) {
    TodayTaskWidget()
} timeline: {
    TodayTaskEntry.placeholder
}