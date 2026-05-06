import SwiftUI

/// 回顧詳情頁 — 查看週/月/年度回顧的完整報告
struct ReviewDetailView: View {
    let review: Review
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 回顧類型標題
                        HStack {
                            Image(systemName: reviewIcon)
                                .foregroundColor(AppColors.primary)
                            Text(review.period)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.top, 16)
                        
                        // 日期 + 類型
                        HStack {
                            Text(review.createdAt.formatted(date: .abbreviated, time: .shortened))
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                            Text(review.type.displayName)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.primary)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(AppColors.primary.opacity(0.1))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                        
                        // 摘要
                        if !review.summary.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📝 摘要")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                Text(review.summary)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(nil)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // 成就
                        if !review.achievements.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🏆 成就")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                ForEach(review.achievements, id: \.self) { achievement in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(AppColors.success)
                                            .font(.caption)
                                        Text(achievement)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // 改進空間
                        if !review.improvements.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("📈 改進空間")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                ForEach(review.improvements, id: \.self) { improvement in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "arrow.up.right.circle.fill")
                                            .foregroundColor(AppColors.accent)
                                            .font(.caption)
                                        Text(improvement)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // 下週重點
                        if let nextFocus = review.nextWeekFocus, !nextFocus.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("🎯 下期重點")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                ForEach(nextFocus, id: \.self) { focus in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                            .font(.caption)
                                        Text(focus)
                                            .font(.caption)
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // AI 建議
                        if !review.aiSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 6) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppColors.accent)
                                    Text("AI 建議")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)
                                }
                                Text(review.aiSuggestions)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .lineLimit(nil)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("回顧詳情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var reviewIcon: String {
        switch review.type {
        case .weekly: return "calendar.badge.clock"
        case .monthly: return "calendar"
        case .yearly: return "star.circle.fill"
        }
    }
}
