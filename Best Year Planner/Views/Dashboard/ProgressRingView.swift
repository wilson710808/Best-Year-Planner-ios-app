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

