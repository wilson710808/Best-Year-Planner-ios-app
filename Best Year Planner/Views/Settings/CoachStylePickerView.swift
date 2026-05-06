import SwiftUI

/// 教練風格選擇器 — 讓用戶選擇 AI 教練的互動風格
struct CoachStylePickerView: View {
    @State private var selectedStyle: CoachStyle = CoachStyle(rawValue: UserDefaults.standard.string(forKey: "coachStyle") ?? "warm") ?? .warm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 標題說明
                        VStack(spacing: 8) {
                            Text("選擇你的 AI 教練風格")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            Text("不同風格的教練會用不同的方式引導你")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 16)
                        
                        // 風格卡片
                        ForEach(CoachStyle.allCases, id: \.self) { style in
                            CoachStyleCard(
                                style: style,
                                isSelected: selectedStyle == style
                            ) {
                                selectedStyle = style
                                UserDefaults.standard.set(style.rawValue, forKey: "coachStyle")
                            }
                        }
                        
                        // 預覽對話
                        VStack(alignment: .leading, spacing: 12) {
                            Text("💬 風格預覽")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            HStack(spacing: 12) {
                                Image(systemName: "bubble.left.fill")
                                    .foregroundColor(AppColors.primary)
                                    .font(.title2)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(selectedStyle.displayName)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)
                                    Text(selectedStyle.previewMessage)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .italic()
                                }
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("教練風格")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct CoachStyleCard: View {
    let style: CoachStyle
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // 圖標
                ZStack {
                    Circle()
                        .fill(isSelected ? AppColors.primary.opacity(0.2) : AppColors.divider.opacity(0.3))
                        .frame(width: 52, height: 52)
                    Image(systemName: style.icon)
                        .font(.title2)
                        .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                }
                
                // 描述
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(style.displayName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(AppColors.primary)
                                .font(.caption)
                        }
                    }
                    Text(style.description)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .background(isSelected ? AppColors.primary.opacity(0.05) : AppColors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: isSelected ? 2 : 1)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}
