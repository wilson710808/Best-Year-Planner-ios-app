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

