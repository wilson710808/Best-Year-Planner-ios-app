import SwiftUI

/// SMARTER 目標評分器 — 基於《規劃最好的一年》目標7原則
struct SMARTERScorerView: View {
    let goalId: String
    let goalTitle: String
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var isGenerating = false
    @State private var showHistory = false
    @State private var animateScore = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Overall Score with Animation
                        overallScoreCard

                        // Radar Chart
                        if viewModel.currentSMARTER != nil {
                            SMARTERRadarChart(score: viewModel.currentSMARTER!)
                                .padding(.vertical, 8)
                        }

                        // Score History Comparison (if previous scores exist)
                        if viewModel.smarterHistory.count > 1 {
                            scoreHistoryCard
                        }

                        // 7 Dimensions
                        ForEach(smarterDimensions, id: \.0) { key, title, icon, description, binding in
                            dimensionCard(key: key, title: title, icon: icon, description: description, value: binding)
                        }

                        // AI Suggestions
                        if !viewModel.smarterSuggestions.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("💡 AI 改進建議")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                ForEach(viewModel.smarterSuggestions, id: \.self) { suggestion in
                                    HStack(alignment: .top, spacing: 8) {
                                        Image(systemName: "arrow.right.circle.fill")
                                            .foregroundColor(AppColors.primary)
                                            .font(.caption)
                                        Text(suggestion)
                                            .font(.subheadline)
                                            .foregroundColor(AppColors.textPrimary)
                                    }
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(AppColors.primary.opacity(0.05))
                                    .cornerRadius(12)
                                }
                            }
                            .padding(.top)
                        }

                        // Generate Button
                        Button(action: {
                            Task {
                                isGenerating = true
                                await viewModel.saveSMARTERScore(goalId: goalId, goalTitle: goalTitle)
                                isGenerating = false
                                animateScore = true
                            }
                        }) {
                            HStack {
                                if isGenerating { ProgressView().tint(.white) }
                                Image(systemName: "sparkles")
                                Text(isGenerating ? "AI 分析中..." : "獲取 AI 改進建議")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(isGenerating ? AppColors.disabled : AppColors.primary)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating)
                    }
                    .padding()
                }
            }
            .navigationTitle("🎯 SMARTER 評分")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .sheet(isPresented: $showHistory) {
                SMARTERHistoryView(goalId: goalId, goalTitle: goalTitle)
            }
        }
        .onAppear {
            viewModel.loadSMARTERScore(goalId: goalId)
            if viewModel.currentSMARTER == nil {
                viewModel.currentSMARTER = SMARTERScore(goalId: goalId)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                animateScore = true
            }
        }
    }

    private var overallScoreCard: some View {
        VStack(spacing: 12) {
            Text(goalTitle)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .lineLimit(2)

            ZStack {
                Circle()
                    .stroke(AppColors.divider, lineWidth: 8)
                    .frame(width: 100, height: 100)

                Circle()
                    .trim(from: 0, to: animateScore ? min((viewModel.currentSMARTER?.overallScore ?? 0) / 10.0, 1.0) : 0)
                    .stroke(
                        LinearGradient(colors: [scoreColor, scoreColor.opacity(0.7)], startPoint: .top, endPoint: .bottom),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 100, height: 100)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.8), value: animateScore)

                VStack(spacing: 0) {
                    Text(String(format: "%.1f", viewModel.currentSMARTER?.overallScore ?? 0))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("/10")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Text(scoreMessage)
                .font(.caption)
                .foregroundColor(scoreColor)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Score History Card

    private var scoreHistoryCard: some View {
        Button(action: { showHistory = true }) {
            HStack(spacing: 12) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(AppColors.primary)
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    Text("評分歷史")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                    Text("已評分 \(viewModel.smarterHistory.count) 次")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.textSecondary)
                    .font(.caption)
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }

    private var scoreColor: Color {
        let score = viewModel.currentSMARTER?.overallScore ?? 0
        if score >= 8 { return AppColors.success }
        if score >= 6 { return AppColors.accent }
        if score >= 4 { return Color.orange }
        return AppColors.error
    }

    private var scoreMessage: String {
        let score = viewModel.currentSMARTER?.overallScore ?? 0
        if score >= 8 { return "🌟 優秀目標！你已經做好準備了" }
        if score >= 6 { return "💪 不錯！還有一些可以強化的地方" }
        if score >= 4 { return "🔍 目標需要更具體，讓我們來改善" }
        return "🔄 建議重新定義目標，讓它更具行動力"
    }

    private func dimensionCard(key: String, title: String, icon: String, description: String, value: Binding<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(AppColors.primary)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(Int(value.wrappedValue))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(value.wrappedValue < 6 ? AppColors.error : AppColors.success)
            }

            Text(description)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)

            Slider(value: value, in: 1...10, step: 1) {
                Text(title)
            }
            .tint(value.wrappedValue < 6 ? AppColors.error : AppColors.primary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    // 7 dimensions with bindings
    private var smarterDimensions: [(String, String, String, String, Binding<Double>)] {
        guard let score = viewModel.currentSMARTER else { return [] }
        return [
            ("specific", "具體 (Specific)", "target", "目標夠明確嗎？「變瘦」vs「減重5公斤」", Binding(
                get: { Double(score.specific) },
                set: { viewModel.currentSMARTER?.specific = Int($0) }
            )),
            ("measurable", "可衡量 (Measurable)", "chart.bar", "有沒有可以量化的指標？", Binding(
                get: { Double(score.measurable) },
                set: { viewModel.currentSMARTER?.measurable = Int($0) }
            )),
            ("actionable", "可執行 (Actionable)", "figure.run", "目標是行動導向的嗎？「每天跑步」vs「變健康」", Binding(
                get: { Double(score.actionable) },
                set: { viewModel.currentSMARTER?.actionable = Int($0) }
            )),
            ("risky", "風險度 (Risky)", "flame.fill", "目標在舒適區外嗎？太安全的目標不會帶來成長", Binding(
                get: { Double(score.risky) },
                set: { viewModel.currentSMARTER?.risky = Int($0) }
            )),
            ("timeKeyed", "有時限 (Time-keyed)", "clock.fill", "有明確的截止日期嗎？", Binding(
                get: { Double(score.timeKeyed) },
                set: { viewModel.currentSMARTER?.timeKeyed = Int($0) }
            )),
            ("exciting", "令人興奮 (Exciting)", "star.fill", "想到這個目標會心跳加速嗎？低於6分建議重新考慮", Binding(
                get: { Double(score.exciting) },
                set: { viewModel.currentSMARTER?.exciting = Int($0) }
            )),
            ("relevant", "相關 (Relevant)", "arrow.triangle.2.circlepath", "這個目標和你的年度大方向一致嗎？", Binding(
                get: { Double(score.relevant) },
                set: { viewModel.currentSMARTER?.relevant = Int($0) }
            ))
        ]
    }
}

// MARK: - SMARTER Radar Chart

struct SMARTERRadarChart: View {
    let score: SMARTERScore
    @State private var animate = false

    private let dimensions = [
        ("具體", "S"),
        ("可衡量", "M"),
        ("可執行", "A"),
        ("風險度", "R"),
        ("時限", "T"),
        ("興奮", "E"),
        ("相關", "R")
    ]

    private var values: [Double] {
        [Double(score.specific), Double(score.measurable), Double(score.actionable),
         Double(score.risky), Double(score.timeKeyed), Double(score.exciting), Double(score.relevant)]
    }

    var body: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                let radius = min(geo.size.width, geo.size.height) / 2 - 30

                ZStack {
                    // Grid circles (2, 4, 6, 8, 10)
                    ForEach([2.0, 4.0, 6.0, 8.0, 10.0], id: \.self) { level in
                        Circle()
                            .stroke(AppColors.divider.opacity(0.3), lineWidth: 0.5)
                            .frame(width: radius * 2 * level / 10, height: radius * 2 * level / 10)
                    }

                    // Axis lines
                    ForEach(0..<7, id: \.self) { i in
                        Path { path in
                            let angle = Double(i) * 2 * .pi / 7 - .pi / 2
                            path.move(to: center)
                            path.addLine(to: CGPoint(
                                x: center.x + radius * cos(angle),
                                y: center.y + radius * sin(angle)
                            ))
                        }
                        .stroke(AppColors.divider.opacity(0.3), lineWidth: 0.5)
                    }

                    // Score polygon
                    Path { path in
                        for i in 0..<7 {
                            let angle = Double(i) * 2 * .pi / 7 - .pi / 2
                            let r = animate ? radius * values[i] / 10 : 0
                            let point = CGPoint(
                                x: center.x + r * cos(angle),
                                y: center.y + r * sin(angle)
                            )
                            if i == 0 { path.move(to: point) } else { path.addLine(to: point) }
                        }
                        path.closeSubpath()
                    }
                    .fill(AppColors.primary.opacity(0.15))
                    .stroke(AppColors.primary, lineWidth: 2)

                    // Dimension labels
                    ForEach(0..<7, id: \.self) { i in
                        let angle = Double(i) * 2 * .pi / 7 - .pi / 2
                        let labelR = radius + 22
                        let x = center.x + labelR * cos(angle)
                        let y = center.y + labelR * sin(angle)

                        VStack(spacing: 1) {
                            Text(dimensions[i].1)
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundColor(AppColors.primary)
                            Text("\(Int(values[i]))")
                                .font(.system(size: 9))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .position(x: x, y: y)
                    }
                }
            }
            .frame(height: 220)

            Text("7 維度雷達圖")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeInOut(duration: 0.6)) {
                    animate = true
                }
            }
        }
    }
}

// MARK: - SMARTER Score History View

struct SMARTERHistoryView: View {
    let goalId: String
    let goalTitle: String
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                if viewModel.smarterHistory.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.divider)
                        Text("尚無評分歷史")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            // Trend chart
                            scoreTrendChart

                            // History list
                            ForEach(viewModel.smarterHistory.reversed(), id: \.id) { score in
                                historyCard(score)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("📊 評分歷史")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("關閉") { dismiss() }
                }
            }
        }
        .onAppear {
            viewModel.loadSMARTERScore(goalId: goalId)
        }
    }

    private var scoreTrendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("分數趨勢")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(Array(viewModel.smarterHistory.enumerated()), id: \.(offset, element).1.id) { index, score in
                    VStack(spacing: 4) {
                        Text(String(format: "%.1f", score.overallScore))
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(AppColors.primary)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [AppColors.primary, AppColors.primary.opacity(0.6)],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )
                            .frame(width: 32, height: max(20, CGFloat(score.overallScore) / 10 * 100))

                        Text("第\(index + 1)次")
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }

    private func historyCard(_ score: SMARTERScore) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(String(format: "%.1f", score.overallScore))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(score.overallScore >= 7 ? AppColors.success : score.overallScore >= 5 ? AppColors.accent : AppColors.error)

                Text("/10")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)

                Spacer()

                Text(score.createdAt.formatted(.dateTime.month().day().hour().minute()))
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            HStack(spacing: 6) {
                dimensionBadge("S", value: score.specific)
                dimensionBadge("M", value: score.measurable)
                dimensionBadge("A", value: score.actionable)
                dimensionBadge("R", value: score.risky)
                dimensionBadge("T", value: score.timeKeyed)
                dimensionBadge("E", value: score.exciting)
                dimensionBadge("R", value: score.relevant)
            }

            if let suggestions = score.aiSuggestions, !suggestions.isEmpty {
                Text(suggestions.first ?? "")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private func dimensionBadge(_ label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 9))
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text("\(value)")
                .font(.system(size: 10))
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
        .frame(width: 28, height: 32)
        .background(value >= 7 ? AppColors.success : value >= 5 ? AppColors.accent : AppColors.error)
        .cornerRadius(6)
    }
}
