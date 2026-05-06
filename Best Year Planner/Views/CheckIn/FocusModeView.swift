import SwiftUI

/// 無干擾模式 — 專注打卡，隱藏統計和社交元素
struct FocusModeView: View {
    @StateObject private var checkInViewModel = CheckInViewModel()
    @StateObject private var challengeViewModel = ChallengeViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 16) {
                        // 模式說明
                        HStack(spacing: 8) {
                            Image(systemName: "eye.slash.fill")
                                .foregroundColor(AppColors.primary)
                            Text("無干擾模式 — 只顯示待打卡任務")
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                        .padding(.horizontal)
                        
                        // 挑戰任務
                        if let challenge = challengeViewModel.currentChallenge,
                           let todayTask = challengeViewModel.todayTask,
                           !todayTask.isCompleted {
                            focusCheckInRow(title: todayTask.title, isCompleted: false) {
                                Task { await challengeViewModel.completeTodayTask() }
                            }
                        }
                        
                        // 常規任務
                        ForEach(checkInViewModel.todayTasks.filter { task in
                            !checkInViewModel.hasCheckedIn(task: task)
                        }) { task in
                            focusCheckInRow(title: task.title, isCompleted: false) {
                                checkInViewModel.selectTask(task)
                            }
                        }
                        
                        // 已完成統計
                        let completedCount = checkInViewModel.todayTasks.filter { task in
                            checkInViewModel.hasCheckedIn(task: task)
                        }.count
                        let totalCount = checkInViewModel.todayTasks.count
                        
                        if completedCount > 0 {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(AppColors.success)
                                Text("已完成 \(completedCount)/\(totalCount) 個任務")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.success)
                                    .fontWeight(.medium)
                            }
                            .padding()
                        }
                        
                        // 全部完成慶祝
                        if completedCount == totalCount && totalCount > 0 {
                            VStack(spacing: 12) {
                                Text("🎉")
                                    .font(.system(size: 48))
                                Text("今天全部完成！")
                                    .font(.headline)
                                    .foregroundColor(AppColors.success)
                                Text("好好休息，明天繼續")
                                    .font(.subheadline)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(24)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("🧘 專注打卡")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("退出") { dismiss() }
                }
            }
        }
        .onAppear {
            checkInViewModel.loadTodaysData()
            challengeViewModel.loadChallenges()
        }
    }
    
    private func focusCheckInRow(title: String, isCompleted: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Circle()
                    .stroke(AppColors.primary, lineWidth: 2)
                    .frame(width: 32, height: 32)
                    .background(isCompleted ? AppColors.primary : Color.clear)
                    .cornerRadius(16)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(.white)
                    )
                
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                    .strikethrough(isCompleted)
                
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
}
