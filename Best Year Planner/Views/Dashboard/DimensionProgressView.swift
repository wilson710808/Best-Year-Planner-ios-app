import SwiftUI

struct DimensionProgressView: View {
    let dimension: GoalDimension
    let progress: Double

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: dimension.icon)
                .font(.title2)
                .foregroundColor(Color(hex: dimension.color))

            Text(dimension.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.textPrimary)

            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(AppColors.divider.opacity(0.3))
                    .frame(height: 8)

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: dimension.color))
                    .frame(height: 8)
                    .scaleEffect(x: progress, y: 1, anchor: .leading)
            }

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
