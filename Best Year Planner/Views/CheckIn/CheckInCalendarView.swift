import SwiftUI

struct CheckInCalendarView: View {
    @StateObject private var viewModel = CheckInViewModel()
    @State private var selectedMonth = Date()
    @State private var selectedDate: Date?

    private var calendar: Calendar { Calendar.current }

    private var monthString: String {
        selectedMonth.formatted(.dateTime.year().month(.wide))
    }

    private var daysInMonth: [Date] {
        guard let range = calendar.range(of: .day, in: .month, for: selectedMonth) else { return [] }
        let components = calendar.dateComponents([.year, .month], from: selectedMonth)
        return range.compactMap { day -> Date? in
            var comps = components
            comps.day = day
            return calendar.date(from: comps)
        }
    }

    private var firstWeekday: Int {
        guard let firstDay = daysInMonth.first else { return 0 }
        // 轉換為週一=0, 週日=6
        let weekday = calendar.component(.weekday, from: firstDay)
        return (weekday + 5) % 7 // Convert Sun=1..Sat=7 to Mon=0..Sun=6
    }

    var body: some View {
        VStack(spacing: 16) {
            // 月份導航
            HStack {
                Button(action: { changeMonth(-1) }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.primary)
                }

                Spacer()

                Text(monthString)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)

                Spacer()

                Button(action: { changeMonth(1) }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.horizontal)

            // 星期標題
            HStack(spacing: 4) {
                ForEach(["一", "二", "三", "四", "五", "六", "日"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)

            // 日曆格子
            let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)
            LazyVGrid(columns: columns, spacing: 4) {
                // 前面空白
                ForEach(0..<firstWeekday, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.clear)
                        .aspectRatio(1, contentMode: .fit)
                }

                // 日期格子
                ForEach(daysInMonth, id: \.self) { date in
                    let checkIns = checkInsForDate(date)
                    let isSelected = selectedDate != nil && calendar.isDate(date, inSameDayAs: selectedDate!)
                    let isToday = calendar.isDateInToday(date)

                    Button(action: { selectedDate = date }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor(for: date, checkIns: checkIns, isSelected: isSelected))

                            Text("\(calendar.component(.day, from: date))")
                                .font(.caption)
                                .fontWeight(isToday ? .bold : .regular)
                                .foregroundColor(textColor(for: date, checkIns: checkIns, isSelected: isSelected))
                        }
                        .aspectRatio(1, contentMode: .fit)
                    }
                }
            }
            .padding(.horizontal)

            // 選中日期的打卡記錄
            if let date = selectedDate {
                let dateCheckIns = checkInsForDate(date)
                VStack(alignment: .leading, spacing: 12) {
                    Text(date.formatted(AppConstants.DateFormats.displayDate))
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    if dateCheckIns.isEmpty {
                        Text("當天無打卡記錄")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        ForEach(dateCheckIns) { checkIn in
                            HStack(spacing: 8) {
                                Image(systemName: checkIn.status.icon)
                                    .foregroundColor(colorForStatus(checkIn.status))
                                Text(taskName(for: checkIn.taskId))
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textPrimary)
                                Spacer()
                                Text(checkIn.status.displayName)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .padding(.horizontal)
            }

            Spacer()
        }
        .padding(.top)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(StringConstants.CheckIn.calendar)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadTodaysData()
        }
    }

    // MARK: - 輔助方法

    private func checkInsForDate(_ date: Date) -> [CheckIn] {
        CheckInService.shared.getCheckIns(forDate: date)
    }

    private func taskName(for taskId: String) -> String {
        TaskService.shared.getTask(byId: taskId)?.title ?? "未知任務"
    }

    private func colorForStatus(_ status: CheckInStatus) -> Color {
        switch status {
        case .completed: return AppColors.secondary
        case .partial: return AppColors.accent
        case .missed: return AppColors.error
        }
    }

    private func backgroundColor(for date: Date, checkIns: [CheckIn], isSelected: Bool) -> Color {
        if isSelected {
            return AppColors.primary
        }

        let isToday = calendar.isDateInToday(date)
        let isFuture = date > Date()

        if isFuture {
            return AppColors.background
        }

        if checkIns.isEmpty {
            return isToday ? AppColors.primary.opacity(0.1) : Color.white
        }

        let completedCount = checkIns.filter { $0.status == .completed }.count
        let totalCount = checkIns.count
        let ratio = Double(completedCount) / Double(totalCount)

        if ratio >= 1.0 {
            return AppColors.secondary.opacity(0.2)
        } else if ratio >= 0.5 {
            return AppColors.accent.opacity(0.15)
        } else {
            return AppColors.error.opacity(0.1)
        }
    }

    private func textColor(for date: Date, checkIns: [CheckIn], isSelected: Bool) -> Color {
        if isSelected {
            return .white
        }

        let isFuture = date > Date()
        if isFuture {
            return AppColors.disabled
        }

        return AppColors.textPrimary
    }

    private func changeMonth(_ delta: Int) {
        if let newMonth = calendar.date(byAdding: .month, value: delta, to: selectedMonth) {
            withAnimation {
                selectedMonth = newMonth
                selectedDate = nil
            }
        }
    }
}
