import SwiftUI

struct AdvancedAnalyticsView: View {
    @StateObject private var viewModel = AdvancedAnalyticsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // 總覽統計
                        if let stats = viewModel.stats {
                            OverviewStatsSection(stats: stats)
                        }

                        // 維度趨勢
                        if !viewModel.dimensionTrends.isEmpty {
                            DimensionTrendSection(trends: viewModel.dimensionTrends)
                        }

                        // 目標完成時間線
                        if !viewModel.goalTimeline.isEmpty {
                            GoalTimelineSection(timelines: viewModel.goalTimeline)
                        }

                        // 習慣養成曲線
                        if !viewModel.habitCurves.isEmpty {
                            HabitCurveSection(curves: viewModel.habitCurves)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("進階數據分析")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("關閉") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.refresh() }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .onAppear { viewModel.refresh() }
        }
    }
}

// MARK: - Overview Stats

struct OverviewStatsSection: View {
    let stats: AnalyticsService.OverviewStats

    var body: some View {
        VStack(spacing: 12) {
            Text("📊 數據總覽")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(title: "目標", value: "\(stats.completedGoals)/\(stats.totalGoals)", icon: "target", color: AppColors.primary)
                StatCard(title: "任務", value: "\(stats.completedTasks)/\(stats.totalTasks)", icon: "checklist", color: AppColors.success)
                StatCard(title: "打卡", value: "\(stats.totalCheckIns)", icon: "flame.fill", color: AppColors.accent)
                StatCard(title: "均連續", value: String(format: "%.1f天", stats.averageStreak), icon: "bolt.fill", color: AppColors.warning)
            }

            // 最佳維度
            if let bestDim = stats.bestDimension {
                HStack {
                    Text("最佳維度")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text(bestDim.displayName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: bestDim.color))
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Dimension Trend

struct DimensionTrendSection: View {
    let trends: [AnalyticsService.DimensionTrend]

    var body: some View {
        VStack(spacing: 12) {
            Text("📈 維度趨勢")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(GoalDimension.allCases) { dim in
                let dimTrends = trends.filter { $0.dimension == dim }.sorted { $0.weekIndex < $1.weekIndex }
                if !dimTrends.isEmpty {
                    let avgRate = dimTrends.map(\.completionRate).reduce(0, +) / Double(dimTrends.count)
                    let latestRate = dimTrends.last?.completionRate ?? 0

                    HStack {
                        Circle()
                            .fill(Color(hex: dim.color))
                            .frame(width: 12, height: 12)
                        Text(dim.displayName)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                        Spacer()
                        // 週均完成率
                        Text("\(Int(avgRate * 100))%")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color(hex: dim.color))

                        // 趨勢箭頭
                        let trend = latestRate - avgRate
                        Image(systemName: trend >= 0 ? "arrow.up.right" : "arrow.down.right")
                            .font(.caption)
                            .foregroundColor(trend >= 0 ? AppColors.success : AppColors.error)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Goal Timeline

struct GoalTimelineSection: View {
    let timelines: [AnalyticsService.GoalCompletionTimeline]

    var body: some View {
        VStack(spacing: 12) {
            Text("🎯 目標完成時間線")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(timelines.prefix(10)) { item in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(hex: item.dimension.color))
                        .frame(width: 10, height: 10)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.goalTitle)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)

                        if let days = item.completionDays {
                            Text("用時 \(days) 天")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        } else {
                            Text("進行中 — \(Int(item.taskCompletionRate * 100))% 完成")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }

                    Spacer()

                    if item.completedAt != nil {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.success)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(AppColors.disabled)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Habit Curve

struct HabitCurveSection: View {
    let curves: [AnalyticsService.HabitCurve]

    var body: some View {
        VStack(spacing: 12) {
            Text("🔥 習慣養成")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            ForEach(curves.prefix(5)) { curve in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(curve.taskTitle)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(1)
                        Spacer()
                        Text("🔥\(curve.longestStreak)天")
                            .font(.caption)
                            .foregroundColor(AppColors.accent)
                    }

                    // 30天打卡率進度條
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(AppColors.accent)
                                .frame(width: geometry.size.width * min(curve.consistency30Day, 1.0), height: 6)
                        }
                    }
                    .frame(height: 6)

                    HStack {
                        Text("近30天打卡率：\(Int(curve.consistency30Day * 100))%")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                        Spacer()
                        Text("累計\(curve.totalCheckIns)次")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }
        }
    }
}
