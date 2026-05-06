import SwiftUI

/// 習慣熱力圖 — 像 GitHub 貢獻圖，顯示每天的打卡完成情況
struct HabitHeatmapView: View {
    @State private var checkInData: [Date: Int] = [:]  // date → count
    @State private var selectedDate: Date?
    @State private var selectedDateInfo: String?
    private let calendar = Calendar.current
    private let totalWeeks = 17  // 顯示最近17週（約4個月）

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 20) {
                    // 圖例
                    HStack(spacing: 16) {
                        Text("少")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                        ForEach(0..<5, id: \.self) { level in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(heatmapColor(level: level))
                                .frame(width: 12, height: 12)
                        }
                        Text("多")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }

                    // 月份標籤
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 4) {
                            // 月份行
                            monthLabels

                            // 熱力圖格子
                            HStack(spacing: 3) {
                                // 週幾標籤
                                VStack(spacing: 3) {
                                    ForEach(["一", "", "三", "", "五", "", "日"], id: \.self) { day in
                                        Text(day)
                                            .font(.system(size: 8))
                                            .foregroundColor(AppColors.textSecondary)
                                            .frame(width: 12, height: 12)
                                    }
                                }

                                // 日期格子
                                ForEach(0..<totalWeeks, id: \.self) { weekIndex in
                                    VStack(spacing: 3) {
                                        ForEach(0..<7, id: \.self) { dayIndex in
                                            if let date = dateFor(week: weekIndex, day: dayIndex) {
                                                let count = checkInData[date.startOfDay] ?? 0
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(heatmapColor(count: count))
                                                    .frame(width: 12, height: 12)
                                                    .overlay(
                                                        RoundedRectangle(cornerRadius: 2)
                                                            .stroke(selectedDate?.startOfDay == date.startOfDay ? AppColors.primary : Color.clear, lineWidth: 1.5)
                                                    )
                                                    .onTapGesture {
                                                        selectedDate = date
                                                        selectedDateInfo = formatDateInfo(date, count: count)
                                                    }
                                            } else {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(Color.clear)
                                                    .frame(width: 12, height: 12)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    // 選中日期詳情
                    if let info = selectedDateInfo {
                        Text(info)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                    }

                    // 統計摘要
                    statsSummary
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.top)
            }
            .navigationTitle("🔥 習慣熱力圖")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear { loadCheckInData() }
    }

    // MARK: - 月份標籤

    private var monthLabels: some View {
        HStack(spacing: 0) {
            Spacer().frame(width: 16) // 對齊週幾標籤
            ForEach(0..<totalWeeks, id: \.self) { weekIndex in
                if let date = dateFor(week: weekIndex, day: 0),
                   calendar.component(.day, from: date) <= 7 {
                    Text(monthName(date))
                        .font(.system(size: 8))
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 15, alignment: .leading)
                } else {
                    Color.clear.frame(width: 15)
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - 統計摘要

    private var statsSummary: some View {
        let totalDays = checkInData.count
        let totalCheckIns = checkInData.values.reduce(0, +)
        let activeDays = checkInData.values.filter { $0 > 0 }.count
        let rate = totalDays > 0 ? Double(activeDays) / Double(totalDays) : 0

        return HStack(spacing: 16) {
            StatBadge(value: "\(activeDays)", label: "活躍天數", color: AppColors.success)
            StatBadge(value: "\(totalCheckIns)", label: "總打卡數", color: AppColors.primary)
            StatBadge(value: String(format: "%.0f%%", rate * 100), label: "完成率", color: AppColors.accent)
        }
    }

    // MARK: - Helpers

    private func dateFor(week: Int, day: Int) -> Date? {
        let today = Date().startOfDay
        let todayWeekday = (calendar.component(.weekday, from: today) + 5) % 7  // 調整為週一=0
        let endOfWeek = calendar.date(byAdding: .day, value: -(todayWeekday), to: today) ?? today
        let targetDate = calendar.date(byAdding: .day, value: -((totalWeeks - 1 - week) * 7 + (todayWeekday - day)), to: today) ?? today

        // 只顯示過去的日期
        return targetDate <= today ? targetDate : nil
    }

    private func heatmapColor(count: Int) -> Color {
        if count == 0 { return AppColors.divider.opacity(0.3) }
        if count == 1 { return AppColors.primary.opacity(0.3) }
        if count == 2 { return AppColors.primary.opacity(0.5) }
        if count == 3 { return AppColors.primary.opacity(0.75) }
        return AppColors.primary
    }

    private func heatmapColor(level: Int) -> Color {
        switch level {
        case 0: return AppColors.divider.opacity(0.3)
        case 1: return AppColors.primary.opacity(0.3)
        case 2: return AppColors.primary.opacity(0.5)
        case 3: return AppColors.primary.opacity(0.75)
        default: return AppColors.primary
        }
    }

    private func monthName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        formatter.locale = Locale(identifier: "zh_TW")
        return formatter.string(from: date)
    }

    private func formatDateInfo(_ date: Date, count: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return "\(formatter.string(from: date))：\(count) 次打卡"
    }

    private func loadCheckInData() {
        let allCheckIns = CheckInService.shared.getAllCheckIns()
        var data: [Date: Int] = [:]
        for checkIn in allCheckIns where checkIn.status == .completed {
            let key = checkIn.date.startOfDay
            data[key, default: 0] += 1
        }
        checkInData = data
    }
}

// MARK: - Stat Badge

private struct StatBadge: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
    }
}
