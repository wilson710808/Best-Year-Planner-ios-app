import SwiftUI

struct BuddyCardView: View {
    let buddy: GrowthBuddy
    var showFullDetails: Bool = false
    
    @State private var showDetail: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 頭像和名稱
            HStack(spacing: 12) {
                // 頭像
                ZStack {
                    Circle()
                        .fill(avatarColor.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: buddy.avatar)
                        .font(.title2)
                        .foregroundColor(avatarColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(buddy.name)
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(buddy.statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                
                Spacer()
                
                // 狀態指示
                statusIndicator
            }
            
            // 進度條（如果不是 notStarted）
            if buddy.status != .notStarted {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Day \(buddy.challengeDay)")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(Int(buddy.progressPercentage * 100))%")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary)
                    }
                    
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: 4)
                                .fill(progressColor)
                                .frame(width: geo.size.width * buddy.progressPercentage, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
            }
            
            // 分享經驗（已完成夥伴）
            if let experience = buddy.sharedExperience, showFullDetails {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("經驗分享")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text(experience)
                        .font(.caption)
                        .foregroundColor(AppColors.textPrimary)
                        .padding(10)
                        .background(Color.yellow.opacity(0.1))
                        .cornerRadius(8)
                }
            }
            
            // 激勵訊息（待開始夥伴）
            if let message = buddy.inspirationalMessage, buddy.status == .notStarted {
                HStack(spacing: 8) {
                    Image(systemName: "quote.opening")
                        .foregroundColor(AppColors.accent)
                        .font(.caption)
                    
                    Text(message)
                        .font(.caption)
                        .italic()
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .onTapGesture {
            showDetail = true
        }
        .sheet(isPresented: $showDetail) {
            BuddyDetailView(buddy: buddy)
        }
    }
    
    // MARK: - Helper Views
    
    @ViewBuilder
    private var statusIndicator: some View {
        switch buddy.status {
        case .justStarted:
            Label("新開始", systemImage: "sparkles")
                .font(.caption2)
                .foregroundColor(.orange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.15))
                .cornerRadius(8)
                
        case .inProgress:
            Label("進行中", systemImage: "flame.fill")
                .font(.caption2)
                .foregroundColor(.red)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.red.opacity(0.15))
                .cornerRadius(8)
                
        case .completed:
            Label("已完成", systemImage: "checkmark.seal.fill")
                .font(.caption2)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.15))
                .cornerRadius(8)
                
        case .notStarted:
            Label("待影響", systemImage: "questionmark.circle")
                .font(.caption2)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.gray.opacity(0.15))
                .cornerRadius(8)
        }
    }
    
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
    
    private var progressColor: LinearGradient {
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
}

#Preview {
    VStack(spacing: 16) {
        BuddyCardView(
            buddy: GrowthBuddy(
                name: "小明",
                status: .justStarted,
                challengeDay: 3,
                streak: 3
            )
        )
        
        BuddyCardView(
            buddy: GrowthBuddy(
                name: "小美",
                status: .inProgress,
                challengeDay: 12,
                streak: 5
            )
        )
        
        BuddyCardView(
            buddy: GrowthBuddy(
                name: "阿志",
                status: .completed,
                challengeDay: 21,
                streak: 21,
                sharedExperience: "坚持21天的关键是把大目标拆成小任务，每天完成一点点就够！"
            ),
            showFullDetails: true
        )
        
        BuddyCardView(
            buddy: GrowthBuddy(
                name: "婷妹",
                status: .notStarted,
                inspirationalMessage: "看到你这么努力，我也想试试看！"
            )
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}