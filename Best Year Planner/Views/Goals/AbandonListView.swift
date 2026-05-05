import SwiftUI

/// 「更少但更好」待棄清單 — 基於《規劃最好的一年》取捨原則
struct AbandonListView: View {
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("✂️ 我決定不做的事")
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)
                        Text("你不可能擁有最好的一年，除非你敢對不重要的事情說「不」。每放棄一件事，就為重要的事騰出空間。")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding()

                    // Add new item
                    VStack(spacing: 8) {
                        HStack(spacing: 12) {
                            TextField("我決定不做...", text: $viewModel.newAbandonTitle)
                                .padding(10)
                                .background(AppColors.cardBackground)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))

                            Button(action: { viewModel.addAbandonItem() }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(AppColors.primary)
                            }
                            .disabled(viewModel.newAbandonTitle.isEmpty)
                        }

                        if !viewModel.newAbandonTitle.isEmpty {
                            TextField("為什麼放棄？（選填）", text: $viewModel.newAbandonReason)
                                .padding(10)
                                .background(AppColors.cardBackground)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                        }
                    }
                    .padding(.horizontal)

                    // List
                    if viewModel.abandonItems.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "scissors")
                                .font(.system(size: 40))
                                .foregroundColor(AppColors.textSecondary.opacity(0.5))
                            Text("還沒有記錄\n寫下你決定不做的事，為重要的事騰出空間")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    } else {
                        List {
                            ForEach(viewModel.abandonItems) { item in
                                HStack(alignment: .top, spacing: 12) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(AppColors.textPrimary)

                                        if let reason = item.reason {
                                            Text(reason)
                                                .font(.caption)
                                                .foregroundColor(AppColors.textSecondary)
                                        }

                                        if let freed = item.freedUpTime {
                                            HStack(spacing: 4) {
                                                Image(systemName: "clock.arrow.circlepath")
                                                    .font(.caption2)
                                                Text("騰出：\(freed)")
                                                    .font(.caption2)
                                            }
                                            .foregroundColor(AppColors.success)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteAbandonItem(id: item.id)
                                    } label: {
                                        Label("刪除", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
            }
            .navigationTitle("更少但更好")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
        }
        .onAppear { viewModel.loadAbandonItems() }
    }
}

// MARK: - 領先/滯後指標視圖

struct GoalIndicatorsView: View {
    let goalId: String
    let goalTitle: String
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAddSheet = false
    @State private var newType: GoalIndicatorType = .lead
    @State private var newTitle = ""
    @State private var newDesc = ""
    @State private var newTarget = ""
    @State private var newUnit = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Explanation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📊 領先 vs 滯後指標")
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                            Text("領先指標是你能控制的行動（如每週運動3次），滯後指標是結果（如減重5公斤）。專注領先指標，結果自然跟著來。")
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        // Lead indicators
                        let leadIndicators = viewModel.goalIndicators[goalId]?.filter { $0.type == .lead } ?? []
                        let lagIndicators = viewModel.goalIndicators[goalId]?.filter { $0.type == .lag } ?? []

                        indicatorSection(title: "🏃 領先指標（你能控制的）", indicators: leadIndicators, color: AppColors.primary)
                        indicatorSection(title: "📈 滯後指標（結果）", indicators: lagIndicators, color: AppColors.accent)

                        // Add button
                        Button(action: { showAddSheet = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("新增指標")
                            }
                            .font(.subheadline)
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(AppColors.primary.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("領先/滯後指標")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") { dismiss() }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                addIndicatorSheet
            }
        }
        .onAppear { viewModel.loadGoalIndicators(goalId: goalId) }
    }

    private func indicatorSection(title: String, indicators: [GoalIndicator], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)

            if indicators.isEmpty {
                Text("尚未設定")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .padding()
            } else {
                ForEach(indicators) { indicator in
                    HStack(spacing: 12) {
                        Image(systemName: indicator.type.icon)
                            .foregroundColor(color)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(indicator.title)
                                .font(.subheadline)
                                .foregroundColor(AppColors.textPrimary)
                            Text(indicator.description)
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        Spacer()
                        if let target = indicator.targetValue, let unit = indicator.unit {
                            Text("\(Int(target)) \(unit)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(color)
                        }
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(10)
                }
            }
        }
    }

    private var addIndicatorSheet: some View {
        NavigationStack {
            Form {
                Picker("類型", selection: $newType) {
                    ForEach(GoalIndicatorType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                TextField("指標名稱", text: $newTitle)
                TextField("描述", text: $newDesc)
                HStack {
                    TextField("目標值", text: $newTarget)
                        .keyboardType(.decimalPad)
                    TextField("單位", text: $newUnit)
                        .frame(width: 60)
                }
            }
            .navigationTitle("新增指標")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") { showAddSheet = false }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        let indicator = GoalIndicator(
                            goalId: goalId,
                            type: newType,
                            title: newTitle,
                            description: newDesc,
                            targetValue: Double(newTarget),
                            unit: newUnit.isEmpty ? nil : newUnit
                        )
                        viewModel.saveGoalIndicator(indicator)
                        showAddSheet = false
                        newTitle = ""; newDesc = ""; newTarget = ""; newUnit = ""
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
        }
    }
}
