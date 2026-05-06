import SwiftUI

/// 里程碑牆 — 記錄每個重要突破，視覺化成長軌跡
struct MilestoneWallView: View {
    @StateObject private var viewModel = GoalEnhancementViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAddMilestone = false
    @State private var newTitle = ""
    @State private var newDescription = ""
    @State private var newCategory: String = "成長"
    
    private let categories = ["事業", "人際", "成長", "健康", "財務", "其他"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 20) {
                        if viewModel.milestones.isEmpty {
                            emptyState
                        } else {
                            // 時間線佈局
                            ForEach(viewModel.milestones) { milestone in
                                milestoneTimelineCard(milestone)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🏆 里程碑牆")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showAddMilestone = true }) {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddMilestone) {
                addMilestoneSheet
            }
        }
        .onAppear {
            viewModel.loadMilestones()
        }
    }
    
    // MARK: - 時間線卡片
    private func milestoneTimelineCard(_ milestone: Milestone) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 4) {
                Circle()
                    .fill(categoryColor(milestone.category ?? "成長"))
                    .frame(width: 16, height: 16)
                    .overlay(
                        Circle().stroke(AppColors.background, lineWidth: 3)
                    )
                Rectangle()
                    .fill(AppColors.divider.opacity(0.5))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(milestone.category ?? "成長")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(categoryColor(milestone.category ?? "成長").opacity(0.15))
                        .cornerRadius(6)
                        .foregroundColor(categoryColor(milestone.category ?? "成長"))
                    
                    Spacer()
                    
                    Text(milestone.achievedAt.formatted(.dateTime.month().day()))
                        .font(.caption2)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)
                
                if !milestone.description.isEmpty {
                    Text(milestone.description)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppColors.cardBackground)
            .cornerRadius(12)
        }
    }
    
    // MARK: - 空狀態
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "flag.fill")
                .font(.system(size: 40))
                .foregroundColor(AppColors.textSecondary.opacity(0.5))
            Text("還沒有里程碑\n每個重要突破都值得記錄")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            Button(action: { showAddMilestone = true }) {
                Text("記錄第一個里程碑")
                    .font(.subheadline)
                    .foregroundColor(AppColors.primary)
            }
        }
        .padding(.vertical, 48)
    }
    
    // MARK: - 新增 Sheet
    private var addMilestoneSheet: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("里程碑名稱")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        TextField("例：第一次跑完10公里", text: $newTitle)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("描述（選填）")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        TextField("記錄這個突破的故事...", text: $newDescription, axis: .vertical)
                            .lineLimit(3...6)
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.divider, lineWidth: 1))
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("類別")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categories, id: \.self) { cat in
                                    Button(action: { newCategory = cat }) {
                                        Text(cat)
                                            .font(.caption)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(newCategory == cat ? categoryColor(cat) : AppColors.cardBackground)
                                            .foregroundColor(newCategory == cat ? .white : AppColors.textSecondary)
                                            .cornerRadius(8)
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AppColors.divider, lineWidth: newCategory == cat ? 0 : 1))
                                    }
                                }
                            }
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("新增里程碑")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { showAddMilestone = false; resetForm() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        viewModel.addMilestone(title: newTitle, description: newDescription, category: newCategory)
                        showAddMilestone = false
                        resetForm()
                    }
                    .disabled(newTitle.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "事業": return AppColors.primary
        case "人際": return AppColors.accent
        case "成長": return AppColors.success
        case "健康": return Color.green
        case "財務": return Color.orange
        default: return AppColors.secondary
        }
    }
    
    private func resetForm() {
        newTitle = ""
        newDescription = ""
        newCategory = "成長"
    }
}
