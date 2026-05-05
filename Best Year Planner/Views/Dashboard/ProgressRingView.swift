import SwiftUI

struct ProgressRingView: View {
    let progress: Double
    var size: CGFloat = 100
    var lineWidth: CGFloat = 12

    var body: some View {
        ZStack {
            Circle()
                .stroke(AppColors.divider, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AppColors.primary,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            VStack(spacing: 2) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: size * 0.25, weight: .bold))
                    .foregroundColor(AppColors.textPrimary)

                Text("完成")
                    .font(.system(size: size * 0.1))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
        .frame(width: size, height: size)
    }
}

struct DimensionProgressView: View {
    let dimension: GoalDimension
    let progress: Double

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(Color(hex: dimension.color).opacity(0.2), lineWidth: 6)

                Circle()
                    .trim(from: 0, to: CGFloat(min(progress, 1.0)))
                    .stroke(
                        Color(hex: dimension.color),
                        style: StrokeStyle(lineWidth: 6, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))

                Image(systemName: dimension.icon)
                    .foregroundColor(Color(hex: dimension.color))
                    .font(.system(size: 14))
            }
            .frame(width: 50, height: 50)

            Text("\(Int(progress * 100))%")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(AppColors.textPrimary)

            Text(dimension.displayName)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
}

struct WeeklySummaryView: View {
    let completionRate: Double
    let totalCheckIns: Int
    let streakDays: Int

    var body: some View {
        HStack(spacing: 16) {
            SummaryCardView(
                icon: "chart.bar.fill",
                value: "\(Int(completionRate * 100))%",
                label: StringConstants.Dashboard.thisWeek
            )

            SummaryCardView(
                icon: "checkmark.circle.fill",
                value: "\(totalCheckIns)",
                label: "打卡次數"
            )

            SummaryCardView(
                icon: "flame.fill",
                value: "\(streakDays)",
                label: StringConstants.Dashboard.streakDays
            )
        }
    }
}

struct SummaryCardView: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .font(.system(size: 20))

            Text(value)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

