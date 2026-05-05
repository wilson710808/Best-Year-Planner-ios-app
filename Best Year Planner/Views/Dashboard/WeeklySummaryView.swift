import SwiftUI

struct WeeklySummaryView: View {
    let completionRate: Double
    let totalCheckIns: Int
    let streakDays: Int

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(AppColors.primary)
                Text("本週摘要")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            HStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text("\(Int(completionRate * 100))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.primary)

                    Text("完成率")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                VStack(spacing: 8) {
                    Text("\(totalCheckIns)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.secondary)

                    Text("打卡次數")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 40)

                VStack(spacing: 8) {
                    Text("\(streakDays)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.accent)

                    Text("連續天數")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }

            // 進度條
            ProgressView(value: completionRate)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primary))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
