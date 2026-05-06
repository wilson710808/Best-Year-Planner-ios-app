import SwiftUI

struct GoalLimitWarningView: View {
    let currentCount: Int
    let maxLimit: Int
    @Binding var isPresented: Bool
    let onContinue: () -> Void
    let onCancel: () -> Void
    
    init(
        currentCount: Int,
        maxLimit: Int = 5,
        isPresented: Binding<Bool>,
        onContinue: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.currentCount = currentCount
        self.maxLimit = maxLimit
        self._isPresented = isPresented
        self.onContinue = onContinue
        self.onCancel = onCancel
    }
    
    private var exceedCount: Int { currentCount - maxLimit }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture { /* 防止點擊背景關閉 */ }
            
            VStack(spacing: 20) {
                // 頂部警告圖標
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.2))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.orange)
                }
                
                // 標題
                Text("⚠️ 目標數量有點多")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // 內容區域
                VStack(spacing: 12) {
                    // 統計卡片
                    HStack(spacing: 16) {
                        StatCard(
                            title: "當前活躍目標",
                            value: "\(currentCount)",
                            color: .orange
                        )
                        StatCard(
                            title: "建議上限",
                            value: "\(maxLimit)",
                            color: .green
                        )
                    }
                    
                    // 說明文字
                    VStack(alignment: .leading, spacing: 8) {
                        Text("根據《規劃最好的一年》研究：")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        BulletPoint(icon: "1.circle.fill", text: "一般人每年能真正完成的目標不超過 5 個", color: .blue)
                        BulletPoint(icon: "2.circle.fill", text: "目標越多，注意力越分散", color: .purple)
                        BulletPoint(icon: "3.circle.fill", text: "專注少數目標反而更容易成功", color: .green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 建議
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("建議：先完成或放棄現有目標，再添加新的")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.horizontal)
                }
                
                // 按鈕區域
                VStack(spacing: 12) {
                    Button {
                        onContinue()
                    } label: {
                        Text("我知道，繼續創建")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    
                    Button {
                        onCancel()
                    } label: {
                        Text("回去整理一下")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 20)
            .padding(.horizontal, 24)
        }
    }
}

// 統計卡片
private struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// 項目符號
private struct BulletPoint: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
                .padding(.top, 2)
            Text(text)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

#Preview {
    GoalLimitWarningView(
        currentCount: 7,
        isPresented: .constant(true),
        onContinue: {},
        onCancel: {}
    )
}
