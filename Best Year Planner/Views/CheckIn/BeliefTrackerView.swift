import SwiftUI

/// 信念轉化追蹤主頁 — 查看所有限制性信念的轉化進度
struct BeliefTrackerView: View {
    @StateObject private var viewModel = BeliefTrackerViewModel()
    @State private var showAddBelief = false
    @State private var selectedFilter: BeliefFilter = .all

    enum BeliefFilter: String, CaseIterable {
        case all = "全部"
        case active = "進行中"
        case actionTaken = "行動中"
        case verified = "已驗證"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Stats overview
                        beliefStatsCard

                        // Filter bar
                        filterBar

                        // Belief cards
                        if filteredRecords.isEmpty {
                            emptyState
                        } else {
                            LazyVStack(spacing: 12) {
                                ForEach(filteredRecords) { record in
                                    NavigationLink(destination: BeliefDetailView(record: record)) {
                                        BeliefCardView(record: record)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🧠 信念追蹤")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddBelief = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAddBelief) {
                AddBeliefRecordView()
            }
        }
        .onAppear {
            viewModel.loadRecords()
        }
    }

    // MARK: - Stats Card

    private var beliefStatsCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("轉化進度")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
            }

            HStack(spacing: 16) {
                StatBadge(value: "\(viewModel.stats.total)", label: "總信念", color: AppColors.primary)
                StatBadge(value: "\(viewModel.stats.verified)", label: "已驗證", color: AppColors.success)
                StatBadge(value: "\(viewModel.stats.active)", label: "進行中", color: AppColors.accent)
            }

            // Top category
            if viewModel.stats.total > 0 {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.stats.topCategory.icon)
                        .foregroundColor(AppColors.primary)
                        .font(.caption)
                    Text("最常出現：\(viewModel.stats.topCategory.displayName)相關信念")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    // MARK: - Filter Bar

    private var filterBar: some View {
        HStack(spacing: 8) {
            ForEach(BeliefFilter.allCases, id: \.self) { filter in
                FilterChip(
                    title: filter.rawValue,
                    isSelected: selectedFilter == filter,
                    action: { selectedFilter = filter }
                )
            }
        }
    }

    // MARK: - Filtered Records

    private var filteredRecords: [BeliefRecord] {
        switch selectedFilter {
        case .all: return viewModel.records
        case .active: return viewModel.records.filter { $0.status == .active }
        case .actionTaken: return viewModel.records.filter { $0.status == .actionTaken }
        case .verified: return viewModel.records.filter { $0.status == .verified }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundColor(AppColors.divider)
            Text("還沒有信念記錄")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            Text("在信念審計中記錄你的限制性信念，\n追蹤它們的轉化進度")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 40)
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
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(color.opacity(0.05))
        .cornerRadius(10)
    }
}

// MARK: - Filter Chip

private struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? AppColors.primary : AppColors.cardBackground)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? AppColors.primary : AppColors.divider, lineWidth: 1)
                )
        }
    }
}

// MARK: - Belief Card View

struct BeliefCardView: View {
    let record: BeliefRecord

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            VStack(spacing: 4) {
                Image(systemName: record.category.icon)
                    .font(.title3)
                    .foregroundColor(Color(hex: record.status.color))
                Text(record.category.displayName)
                    .font(.system(size: 9))
                    .foregroundColor(AppColors.textSecondary)
            }
            .frame(width: 44)

            // Belief content
            VStack(alignment: .leading, spacing: 6) {
                // Limiting belief (struck through)
                HStack(spacing: 4) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(AppColors.error)
                    Text(record.limitingBelief)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .strikethrough()
                        .lineLimit(1)
                }

                // Reframed belief
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption2)
                        .foregroundColor(AppColors.success)
                    Text(record.reframedBelief)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.textPrimary)
                        .lineLimit(2)
                }

                // Status badge
                HStack(spacing: 6) {
                    Text(record.status.displayName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: record.status.color))
                        .cornerRadius(8)

                    if let action = record.actionTaken {
                        Text(action)
                            .font(.caption2)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    Text(record.createdAt.formatted(.dateTime.month().day()))
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}

// MARK: - Belief Detail View

struct BeliefDetailView: View {
    let record: BeliefRecord
    @State private var actionText = ""
    @State private var showAIGuidance = false
    @StateObject private var viewModel = BeliefTrackerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Original vs Reframed
                beliefComparisonCard

                // Status & Timeline
                statusTimelineCard

                // Action Section
                actionSection

                // AI Guidance
                if let guidance = record.aiGuidance {
                    aiGuidanceCard(guidance)
                }
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle("信念詳情")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var beliefComparisonCard: some View {
        VStack(spacing: 16) {
            // Category
            HStack {
                Image(systemName: record.category.icon)
                    .foregroundColor(AppColors.primary)
                Text(record.category.displayName)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
                Spacer()
            }

            // Limiting belief
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(AppColors.error)
                    Text("限制性信念")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.error)
                }
                Text(record.limitingBelief)
                    .font(.body)
                    .foregroundColor(AppColors.textSecondary)
                    .strikethrough()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(AppColors.error.opacity(0.05))
            .cornerRadius(12)

            Image(systemName: "arrow.down")
                .foregroundColor(AppColors.primary)

            // Reframed belief
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.success)
                    Text("開放性信念")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.success)
                }
                Text(record.reframedBelief)
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(AppColors.success.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
    }

    private var statusTimelineCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("轉化進度")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            HStack(spacing: 0) {
                // Step 1: Identified
                statusStep(label: "識別", isComplete: true)
                statusLine(isActive: record.status != .active)

                // Step 2: Action taken
                statusStep(label: "行動", isComplete: record.status == .actionTaken || record.status == .verified)
                statusLine(isActive: record.status == .verified)

                // Step 3: Verified
                statusStep(label: "驗證", isComplete: record.status == .verified)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private func statusStep(label: String, isComplete: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(isComplete ? AppColors.success : AppColors.divider, lineWidth: 2)
                    .frame(width: 28, height: 28)
                if isComplete {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                        .foregroundColor(AppColors.success)
                }
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(isComplete ? AppColors.success : AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func statusLine(isActive: Bool) -> some View {
        Rectangle()
            .fill(isActive ? AppColors.success : AppColors.divider)
            .frame(width: 40, height: 2)
            .offset(y: -8)
    }

    private var actionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("行動記錄")
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            if record.status == .active {
                TextField("用5分鐘行動驗證這個信念...", text: $actionText, axis: .vertical)
                    .lineLimit(2...4)
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.divider, lineWidth: 1))

                Button(action: recordAction) {
                    HStack {
                        Image(systemName: "figure.run")
                        Text("記錄行動")
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(AppColors.primary)
                    .cornerRadius(10)
                }
                .disabled(actionText.isEmpty)
            } else if let action = record.actionTaken {
                HStack(spacing: 8) {
                    Image(systemName: "figure.run")
                        .foregroundColor(AppColors.primary)
                    Text(action)
                        .font(.subheadline)
                        .foregroundColor(AppColors.textPrimary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.primary.opacity(0.05))
                .cornerRadius(12)

                if record.status == .actionTaken && !record.isVerified {
                    Button(action: verifyBelief) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("驗證成功！這個信念已轉化")
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(AppColors.success)
                        .cornerRadius(10)
                    }
                }
            }

            if record.isVerified, let verifiedAt = record.verifiedAt {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(AppColors.success)
                    Text("已於 \(verifiedAt.formatted(.dateTime.month().day())) 驗證成功")
                        .font(.caption)
                        .foregroundColor(AppColors.success)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }

    private func aiGuidanceCard(_ guidance: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundColor(AppColors.accent)
                Text("AI 引導")
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
            }
            Text(guidance)
                .font(.subheadline)
                .foregroundColor(AppColors.textPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppColors.accent.opacity(0.05))
        .cornerRadius(12)
    }

    private func recordAction() {
        viewModel.updateStatus(id: record.id, status: .actionTaken, actionTaken: actionText)
    }

    private func verifyBelief() {
        viewModel.updateStatus(id: record.id, status: .verified)
    }
}

// MARK: - Add Belief Record View

struct AddBeliefRecordView: View {
    @State private var limitingBelief = ""
    @State private var reframedBelief = ""
    @State private var selectedCategory: BeliefCategory = .general
    @State private var isLoading = false
    @StateObject private var viewModel = BeliefTrackerViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Limiting belief
                        VStack(alignment: .leading, spacing: 8) {
                            Label("限制性信念", systemImage: "xmark.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.error)

                            TextField("我做不到...因為...", text: $limitingBelief, axis: .vertical)
                                .lineLimit(2...4)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.error.opacity(0.3), lineWidth: 1))
                        }

                        // Reframed belief
                        VStack(alignment: .leading, spacing: 8) {
                            Label("開放性信念", systemImage: "checkmark.circle.fill")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.success)

                            TextField("我正在找到方法...", text: $reframedBelief, axis: .vertical)
                                .lineLimit(2...4)
                                .padding()
                                .background(AppColors.cardBackground)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.success.opacity(0.3), lineWidth: 1))
                        }

                        // AI help
                        Button(action: generateReframe) {
                            HStack {
                                if isLoading { ProgressView().tint(.white) }
                                Image(systemName: "sparkles")
                                Text(isLoading ? "AI 分析中..." : "讓 AI 幫我反轉")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(isLoading ? AppColors.disabled : AppColors.primary)
                            .cornerRadius(10)
                        }
                        .disabled(limitingBelief.isEmpty || isLoading)

                        // Category
                        VStack(alignment: .leading, spacing: 8) {
                            Text("信念類別")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                                ForEach(BeliefCategory.allCases, id: \.self) { category in
                                    Button(action: { selectedCategory = category }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: category.icon)
                                                .font(.caption2)
                                            Text(category.displayName)
                                                .font(.caption)
                                        }
                                        .foregroundColor(selectedCategory == category ? .white : AppColors.textPrimary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 6)
                                        .background(selectedCategory == category ? AppColors.primary : AppColors.cardBackground)
                                        .cornerRadius(8)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(selectedCategory == category ? AppColors.primary : AppColors.divider, lineWidth: 1)
                                        )
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("新增信念記錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        saveRecord()
                        dismiss()
                    }
                    .disabled(limitingBelief.isEmpty || reframedBelief.isEmpty)
                }
            }
        }
    }

    private func generateReframe() {
        isLoading = true
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        let prompt = "用戶有一個限制性信念：「\(limitingBelief)」。請用一句話幫用戶反轉為開放性信念。要求：1) 不否定原信念，而是提供新視角 2) 用「正在找到方法」取代「做不到」 3) 30字以內"

        Task {
            let aiProvider = ServiceLocator.shared.resolve(AIProvider.self)
            let response = await aiProvider.query(userId: userId, query: prompt)
            reframedBelief = response.trimmingCharacters(in: .whitespacesAndNewlines)
            isLoading = false
        }
    }

    private func saveRecord() {
        let record = BeliefRecord(
            userId: UserDefaultsManager.shared.currentUserId,
            limitingBelief: limitingBelief,
            reframedBelief: reframedBelief,
            category: selectedCategory
        )
        viewModel.saveRecord(record)
    }
}

// MARK: - Belief Tracker ViewModel

class BeliefTrackerViewModel: ObservableObject {
    @Published var records: [BeliefRecord] = []
    @Published var stats: (total: Int, verified: Int, active: Int, topCategory: BeliefCategory) = (0, 0, 0, .general)

    private let service = GoalEnhancementService.shared

    func loadRecords() {
        let userId = UserDefaultsManager.shared.currentUserId ?? ""
        records = service.getBeliefRecords(userId: userId)
        stats = service.getBeliefStats(userId: userId)
    }

    func saveRecord(_ record: BeliefRecord) {
        _ = service.saveBeliefRecord(record)
        loadRecords()
    }

    func updateStatus(id: String, status: BeliefStatus, actionTaken: String? = nil) {
        _ = service.updateBeliefStatus(id: id, status: status, actionTaken: actionTaken)
        loadRecords()
    }
}
