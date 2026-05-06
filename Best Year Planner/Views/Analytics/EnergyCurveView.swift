import SwiftUI

/// 能量曲線 — 追蹤用戶的動機水平變化
struct EnergyCurveView: View {
    @State private var energyRecords: [EnergyRecord] = []
    @State private var todayEnergy: Int = 5
    @State private var showInput = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        // 今日能量輸入
                        todayEnergyCard
                        
                        // 能量曲線圖
                        if energyRecords.count >= 2 {
                            energyChart
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "waveform.path.ecg")
                                    .font(.system(size: 40))
                                    .foregroundColor(AppColors.textSecondary.opacity(0.5))
                                Text("記錄至少2天的能量值\n就能看到趨勢曲線")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 32)
                        }
                        
                        // 統計
                        if !energyRecords.isEmpty {
                            statsRow
                        }
                        
                        // 歷史記錄
                        if !energyRecords.isEmpty {
                            historyList
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("⚡ 能量曲線")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            loadEnergyRecords()
        }
    }
    
    // MARK: - 今日能量卡片
    private var todayEnergyCard: some View {
        VStack(spacing: 16) {
            Text("你今天的能量如何？")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { value in
                    Button(action: {
                        todayEnergy = value
                        saveTodayEnergy(value)
                    }) {
                        VStack(spacing: 4) {
                            Circle()
                                .fill(value <= todayEnergy ? energyColor(value) : AppColors.divider.opacity(0.3))
                                .frame(width: 28, height: 28)
                                .overlay(
                                    Text("\(value)")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .foregroundColor(value <= todayEnergy ? .white : AppColors.textSecondary)
                                )
                        }
                    }
                }
            }
            
            Text(energyLabel(todayEnergy))
                .font(.caption)
                .foregroundColor(energyColor(todayEnergy))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - 能量曲線圖
    private var energyChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("能量趨勢")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            ChartView(records: energyRecords.suffix(30))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - 統計行
    private var statsRow: some View {
        HStack(spacing: 12) {
            StatBadge(value: String(format: "%.1f", averageEnergy), label: "平均能量", color: energyColor(Int(averageEnergy)))
            StatBadge(value: "\(energyRecords.count)", label: "記錄天數", color: AppColors.primary)
            if let trend = energyTrend {
                StatBadge(value: trend > 0 ? "↗ 上升" : trend < 0 ? "↘ 下降" : "→ 平穩", label: "趨勢", color: trend > 0 ? AppColors.success : trend < 0 ? AppColors.error : AppColors.textSecondary)
            }
        }
    }
    
    // MARK: - 歷史列表
    private var historyList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("歷史記錄")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(energyRecords.suffix(14).reversed()) { record in
                HStack(spacing: 12) {
                    Text(record.date.formatted(.dateTime.month().day()))
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .frame(width: 50, alignment: .leading)
                    
                    ForEach(1...10, id: \.self) { value in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(value <= record.level ? energyColor(record.level) : AppColors.divider.opacity(0.2))
                            .frame(width: 12, height: 12)
                    }
                    
                    Spacer()
                    
                    Text(energyLabel(record.level))
                        .font(.caption2)
                        .foregroundColor(energyColor(record.level))
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }
    
    // MARK: - Helpers
    private func energyColor(_ level: Int) -> Color {
        if level >= 8 { return AppColors.success }
        if level >= 5 { return AppColors.accent }
        if level >= 3 { return Color.orange }
        return AppColors.error
    }
    
    private func energyLabel(_ level: Int) -> String {
        if level >= 9 { return "🔥 充滿能量" }
        if level >= 7 { return "💪 狀態不錯" }
        if level >= 5 { return "😊 還可以" }
        if level >= 3 { return "😴 有點累" }
        return "😩 低能量"
    }
    
    private var averageEnergy: Double {
        guard !energyRecords.isEmpty else { return 0 }
        return Double(energyRecords.reduce(0) { $0 + $1.level }) / Double(energyRecords.count)
    }
    
    private var energyTrend: Double? {
        guard energyRecords.count >= 5 else { return nil }
        let recent = energyRecords.suffix(3).map { Double($0.level) }.reduce(0, +) / 3.0
        let earlier = energyRecords.dropLast(3).suffix(3).map { Double($0.level) }.reduce(0, +) / 3.0
        return recent - earlier
    }
    
    private func saveTodayEnergy(_ level: Int) {
        let record = EnergyRecord(level: level)
        energyRecords.append(record)
        // 保存到 UserDefaults
        if let data = try? JSONEncoder().encode(energyRecords) {
            UserDefaults.standard.set(data, forKey: "energyRecords_\(UserDefaultsManager.shared.currentUserId ?? "")")
        }
    }
    
    private func loadEnergyRecords() {
        let key = "energyRecords_\(UserDefaultsManager.shared.currentUserId ?? "")"
        if let data = UserDefaults.standard.data(forKey: key),
           let records = try? JSONDecoder().decode([EnergyRecord].self, from: data) {
            energyRecords = records
            // 如果今天已有記錄，顯示今日值
            let today = Date().startOfDay
            if let todayRecord = records.last(where: { $0.date.startOfDay == today }) {
                todayEnergy = todayRecord.level
            }
        }
    }
}

// MARK: - Energy Record Model
struct EnergyRecord: Codable, Identifiable {
    var id: String = UUID().uuidString
    var level: Int // 1-10
    var date: Date = Date()
}

// MARK: - Simple Chart View
private struct ChartView: View {
    let records: ArraySlice<EnergyRecord>
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(Array(records), id: \.id) { record in
                VStack(spacing: 2) {
                    Text("\(record.level)")
                        .font(.system(size: 8))
                        .foregroundColor(energyColor(record.level))
                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            LinearGradient(
                                colors: [energyColor(record.level), energyColor(record.level).opacity(0.5)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: 20, height: max(8, CGFloat(record.level) / 10.0 * 80))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    private func energyColor(_ level: Int) -> Color {
        if level >= 8 { return AppColors.success }
        if level >= 5 { return AppColors.accent }
        if level >= 3 { return Color.orange }
        return AppColors.error
    }
}

// MARK: - Stat Badge
private struct StatBadge: View {
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppColors.cardBackground)
        .cornerRadius(8)
    }
}
