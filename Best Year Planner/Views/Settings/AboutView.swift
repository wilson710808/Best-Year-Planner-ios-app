import SwiftUI

/// 關於頁面 — App 資訊 + 核心理念
struct AboutView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 24) {
                        // App 圖標與版本
                        VStack(spacing: 12) {
                            Image(systemName: "sun.max.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(AppColors.primary)
                            Text("Best Year Planner")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.textPrimary)
                            Text("版本 1.0.0")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.top, 24)
                        
                        // 核心理念
                        VStack(alignment: .leading, spacing: 16) {
                            Text("📖 核心理念")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            
                            PrincipleRow(number: 1, title: "相信可能", desc: "打破限制性信念，你比想像的更有能力")
                            PrincipleRow(number: 2, title: "總結過去", desc: "回顧經驗，從成功和失敗中汲取智慧")
                            PrincipleRow(number: 3, title: "找到為什麼", desc: "清晰的動機是堅持的燃料")
                            PrincipleRow(number: 4, title: "付諸行動", desc: "SMARTER目標 + 每日行動 = 真實改變")
                            PrincipleRow(number: 5, title: "持續改進", desc: "定期校正，讓計劃隨你成長")
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        
                        // 致謝
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🙏 致謝")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Text("本應用基於 Michael Hyatt 著作《規劃最好的一年》(Your Best Year Ever) 的五大步驟法則設計開發。")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        
                        // 技術資訊
                        VStack(alignment: .leading, spacing: 8) {
                            Text("⚙️ 技術資訊")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            HStack {
                                Text("架構")
                                Spacer()
                                Text("MVVM + SwiftUI")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .font(.caption)
                            HStack {
                                Text("本地存儲")
                                Spacer()
                                Text("SQLite")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .font(.caption)
                            HStack {
                                Text("AI 服務")
                                Spacer()
                                Text("AI Gateway")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .font(.caption)
                            HStack {
                                Text("最低版本")
                                Spacer()
                                Text("iOS 16.0+")
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .font(.caption)
                        }
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                    }
                    .padding()
                }
            }
            .navigationTitle("關於")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct PrincipleRow: View {
    let number: Int
    let title: String
    let desc: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(AppColors.primary)
                .frame(width: 28, height: 28)
                .overlay(Text("\(number)").font(.caption).foregroundColor(.white).fontWeight(.bold))
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                Text(desc)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}
