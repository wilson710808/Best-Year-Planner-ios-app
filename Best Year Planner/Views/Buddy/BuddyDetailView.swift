import SwiftUI

struct BuddyDetailView: View {
    let buddy: GrowthBuddy
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 頭像區域
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(avatarColor.opacity(0.2))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: buddy.avatar)
                                .font(.system(size: 50))
                                .foregroundColor(avatarColor)
                        }
                        
                        Text(buddy.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        statusBadge
                    }
                    .padding(.top, 20)
                    
                    // 進度卡片
                    if buddy.status != .notStarted {
                        progressSection
                    }
                    
                    // 統計卡片
                    statsSection
                    
                    // 經驗分享（已完成）
                    if let experience = buddy.sharedExperience {
                        experienceSection(experience)
                    }
                    
                    // 激勵訊息（待開始）
                    if let message = buddy.inspirationalMessage, buddy.status == .notStarted {
                        inspirationSection(message)
                    }
                    
                    // 掉鏈子狀態顯示（進行中）
                    if buddy.status == .inProgress || buddy.status == .justStarted {
                        slackingSection
                    }
                    
                    // 互動按鈕
                    actionButtons
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("夥伴詳情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var statusBadge: some View {
        HStack(spacing: 8) {
            statusIcon
            Text(buddy.statusText)
                .font(.subheadline)
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(statusColor.opacity(0.15))
        .cornerRadius(20)
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("挑戰進度")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Day \(buddy.challengeDay)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                        Text("當前天數")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("\(Int(buddy.progressPercentage * 100))%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.primary)
                        Text("完成度")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // 進度條
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(progressGradient)
                            .frame(width: geo.size.width * buddy.progressPercentage)
                    }
                }
                .frame(height: 16)
                
                HStack {
                    Text("Day 1")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                    Spacer()
                    Text("Day \(buddy.totalDays)")
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        }
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("統計數據")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 16) {
                StatCard(
                    icon: "flame.fill",
                    iconColor: .orange,
                    value: "\(buddy.streak)",
                    label: "連續天數"
                )
                
                StatCard(
                    icon: "calendar",
                    iconColor: .blue,
                    value: "\(buddy.challengeDay)",
                    label: "總天數"
                )
                
                StatCard(
                    icon: "clock.fill",
                    iconColor: .purple,
                    value: lastActiveText,
                    label: "最後活躍"
                )
            }
        }
    }
    
    private func experienceSection(_ experience: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("過來人經驗")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text(experience)
                .font(.body)
                .foregroundColor(AppColors.textPrimary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    LinearGradient(
                        colors: [Color.yellow.opacity(0.2), Color.orange.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
        }
    }
    
    private func inspirationSection(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "quote.opening")
                    .foregroundColor(AppColors.accent)
                Text("激勵訊息")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text("「\(message)」")
                .font(.body)
                .italic()
                .foregroundColor(AppColors.textSecondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.accent.opacity(0.1))
                .cornerRadius(16)
        }
    }
    
    // MARK: - 掉鏈子區塊
    
    private var slackingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: buddy.isCurrentlySlacking ? "exclamationmark.triangle.fill" : "figure.walk")
                    .foregroundColor(buddy.isCurrentlySlacking ? .orange : .green)
                Text("打卡紀錄")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            // 漏打卡統計
            HStack(spacing: 16) {
                StatCard(
                    icon: "xmark.circle.fill",
                    iconColor: .red,
                    value: "\(buddy.missedDays)",
                    label: buddy.missedDaysText
                )
                
                StatCard(
                    icon: "percent",
                    iconColor: .blue,
                    value: "\(Int(buddy.missProbability * 100))%",
                    label: "漏卡機率"
                )
            }
            
            // 掉鏈子狀態提示
            if buddy.isCurrentlySlacking {
                HStack(spacing: 12) {
                    Image(systemName: "zzz")
                        .font(.title2)
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(buddy.name) 正在掉鏈子... 😴")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                        
                        if !buddy.slackingDaysText.isEmpty {
                            Text(buddy.slackingDaysText)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        Text(slackingEncouragement)
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.orange.opacity(0.15), Color.yellow.opacity(0.1)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            } else if buddy.missedDays > 0 {
                HStack(spacing: 12) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(buddy.name) 最近有按時打卡 ✅")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("累計漏打卡 \(buddy.missedDays) 天，但正在努力坚持！")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
            } else {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundColor(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(buddy.name) 表現優異！⭐")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("目前零漏打卡，繼續保持！")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .padding()
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(12)
            }
        }
    }
    
    private var slackingEncouragement: String {
        let days = buddy.slackingDaysText
        if days.contains("1天") {
            return "昨天没打卡，今天给 ta 加加油吧！"
        } else if days.contains("2天") {
            return "两天没动了，ta 需要你的鼓励！"
        } else if days.contains("3") || days.contains("4") || days.contains("5") {
            return "快要放弃了，快去帮 ta 打气！"
        } else {
            return "ta 已经很久没打卡了，需要你的支持！"
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if buddy.status == .notStarted {
                Button {
                    // 激勵夥伴開始
                } label: {
                    Label("鼓勵他開始", systemImage: "hand.thumbsup.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(12)
                }
            } else if buddy.status == .completed {
                Button {
                    // 查看更多經驗
                } label: {
                    Label("向他學習更多", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
            } else {
                // 進行中或剛開始
                if buddy.isCurrentlySlacking {
                    Button {
                        // 為掉鏈子的夥伴加油（已在 ViewModel 中處理）
                    } label: {
                        Label("鼓勵 \(buddy.name)", systemImage: "heart.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                } else {
                    Button {
                        // 為夥伴加油
                    } label: {
                        Label("為他加油", systemImage: "heart.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.accent)
                            .cornerRadius(12)
                    }
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private var avatarColor: Color {
        switch buddy.status {
        case .justStarted: return .orange
        case .inProgress: return .red
        case .completed: return .green
        case .notStarted: return .gray
        }
    }
    
    private var statusColor: Color {
        switch buddy.status {
        case .justStarted: return .orange
        case .inProgress: return .red
        case .completed: return .green
        case .notStarted: return .gray
        }
    }
    
    @ViewBuilder
    private var statusIcon: some View {
        switch buddy.status {
        case .justStarted:
            Image(systemName: "sparkles")
        case .inProgress:
            Image(systemName: "flame.fill")
        case .completed:
            Image(systemName: "checkmark.seal.fill")
        case .notStarted:
            Image(systemName: "questionmark.circle")
        }
    }
    
    private var progressGradient: LinearGradient {
        switch buddy.status {
        case .justStarted:
            return LinearGradient(colors: [.orange, .yellow], startPoint: .leading, endPoint: .trailing)
        case .inProgress:
            return LinearGradient(colors: [.red, .orange], startPoint: .leading, endPoint: .trailing)
        case .completed:
            return LinearGradient(colors: [.green, .mint], startPoint: .leading, endPoint: .trailing)
        case .notStarted:
            return LinearGradient(colors: [.gray, .gray.opacity(0.5)], startPoint: .leading, endPoint: .trailing)
        }
    }
    
    private var lastActiveText: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(buddy.lastActiveDate) {
            return "今天"
        } else if calendar.isDateInYesterday(buddy.lastActiveDate) {
            return "昨天"
        } else {
            let days = calendar.dateComponents([.day], from: buddy.lastActiveDate, to: Date()).day ?? 0
            return "\(days)天"
        }
    }
}

// MARK: - Stat Card Component


#Preview {
    BuddyDetailView(
        buddy: GrowthBuddy(
            name: "小明",
            status: .inProgress,
            challengeDay: 12,
            streak: 5
        )
    )
}