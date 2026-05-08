import SwiftUI

/// 挑戰進度環形圖 — 7天/21天一目了然
struct ChallengeProgressRingView: View {
    let currentDay: Int
    let totalDays: Int
    let phase: ChallengePhase
    let size: CGFloat
    
    init(currentDay: Int, totalDays: Int, phase: ChallengePhase, size: CGFloat = 160) {
        self.currentDay = currentDay
        self.totalDays = totalDays
        self.phase = phase
        self.size = size
    }
    
    private var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(min(currentDay, totalDays)) / Double(totalDays)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                // 背景環
                Circle()
                    .stroke(ringBackgroundColor, lineWidth: 12)
                    .frame(width: size, height: size)
                
                // 進度環
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: ringGradientColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: size, height: size)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: progress)
                
                // 中心內容
                VStack(spacing: 4) {
                    Text("Day")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(currentDay)")
                        .font(.system(size: size * 0.28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("/ \(totalDays)")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                    
                    // 百分比
                    Text("\(Int(progress * 100))%")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ringMainColor)
                }
            }
            
            // 階段標籤
            HStack(spacing: 8) {
                phaseLabel
                
                if phase == .twentyOneDayChallenge {
                    // 三循環標記
                    HStack(spacing: 4) {
                        CycleDot(isActive: currentDay >= 1, label: "基礎")
                        CycleDot(isActive: currentDay >= 8, label: "深化")
                        CycleDot(isActive: currentDay >= 15, label: "內化")
                    }
                }
            }
        }
    }
    
    // MARK: - Ring Colors
    
    private var ringMainColor: Color {
        switch phase {
        case .sevenDayLaunch: return AppColors.accent
        case .twentyOneDayChallenge: return AppColors.primary
        }
    }
    
    private var ringBackgroundColor: Color {
        switch phase {
        case .sevenDayLaunch: return AppColors.accent.opacity(0.15)
        case .twentyOneDayChallenge: return AppColors.primary.opacity(0.15)
        }
    }
    
    private var ringGradientColors: [Color] {
        switch phase {
        case .sevenDayLaunch: return [.orange, .yellow]
        case .twentyOneDayChallenge: return [AppColors.primary, .cyan]
        }
    }
    
    // MARK: - Phase Label
    
    @ViewBuilder
    private var phaseLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: phase == .sevenDayLaunch ? "bolt.fill" : "flame.fill")
                .font(.caption2)
            Text(phase == .sevenDayLaunch ? "7天啟動" : "21天挑戰")
                .font(.caption)
                .fontWeight(.medium)
        }
        .foregroundColor(ringMainColor)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(ringMainColor.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Cycle Dot (三循環：基礎→深化→內化)

struct CycleDot: View {
    let isActive: Bool
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            Circle()
                .fill(isActive ? AppColors.primary : AppColors.divider)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 8))
                .foregroundColor(isActive ? AppColors.primary : AppColors.textSecondary)
        }
    }
}

// MARK: - 雙環版本（7天+21天同時顯示）

struct DualChallengeRingView: View {
    let sevenDayProgress: Double  // 0.0 - 1.0
    let twentyOneDayProgress: Double  // 0.0 - 1.0
    let sevenDayCurrent: Int
    let twentyOneDayCurrent: Int
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 24) {
            // 7天環
            VStack(spacing: 8) {
                ChallengeProgressRingView(
                    currentDay: sevenDayCurrent,
                    totalDays: 7,
                    phase: .sevenDayLaunch,
                    size: 100
                )
            }
            
            // 分隔線
            Rectangle()
                .fill(AppColors.divider)
                .frame(width: 1, height: 80)
            
            // 21天環
            VStack(spacing: 8) {
                if isUnlocked {
                    ChallengeProgressRingView(
                        currentDay: twentyOneDayCurrent,
                        totalDays: 21,
                        phase: .twentyOneDayChallenge,
                        size: 100
                    )
                } else {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(AppColors.divider, lineWidth: 10)
                                .frame(width: 100, height: 100)
                            
                            VStack(spacing: 4) {
                                Image(systemName: "lock.fill")
                                    .font(.title3)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("完成7天")
                                    .font(.caption2)
                                    .foregroundColor(AppColors.textSecondary)
                                Text("解鎖21天")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    VStack(spacing: 40) {
        ChallengeProgressRingView(currentDay: 5, totalDays: 7, phase: .sevenDayLaunch)
        ChallengeProgressRingView(currentDay: 14, totalDays: 21, phase: .twentyOneDayChallenge)
        DualChallengeRingView(
            sevenDayProgress: 5/7,
            twentyOneDayProgress: 14/21,
            sevenDayCurrent: 5,
            twentyOneDayCurrent: 14,
            isUnlocked: true
        )
    }
}
