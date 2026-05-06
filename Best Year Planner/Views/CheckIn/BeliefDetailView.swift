import SwiftUI

/// 信念詳情頁 — 查看單條限制性信念的完整轉化過程
struct BeliefDetailView: View {
    let record: BeliefRecord
    @Environment(\.dismiss) private var dismiss
    @State private var isExpanding = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // 限制性信念（紅色警告）
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                Text("限制性信念")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                            }
                            Text(record.limitingBelief)
                                .font(.body)
                                .foregroundColor(AppColors.textPrimary)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.08))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        // 轉化箭頭
                        VStack {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title)
                                .foregroundColor(AppColors.accent)
                            Text("信念轉化")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
                        // AI 引導
                        if let guidance = record.aiGuidance {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(AppColors.primary)
                                    Text("AI 引導")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.primary)
                                }
                                Text(guidance)
                                    .font(.body)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.primary.opacity(0.08))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        // 用戶反轉的開放性信念
                        if !record.reframedBelief.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 8) {
                                    Image(systemName: "heart.circle.fill")
                                        .foregroundColor(AppColors.success)
                                    Text("我的新信念")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.success)
                                }
                                Text(record.reframedBelief)
                                    .font(.body)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.textPrimary)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.success.opacity(0.08))
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        
                        // 轉化日期
                        HStack {
                            Text("記錄於 \(record.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 16)
                }
            }
            .navigationTitle("信念詳情")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
