import SwiftUI

struct NotificationSettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var weeklyReviewReminder = true
    @State private var monthlyReviewReminder = true
    @State private var streakReminder = true
    @State private var communityNotification = false

    var body: some View {
        Form {
            Section("每日打卡提醒") {
                Toggle(isOn: $viewModel.notificationEnabled) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("啟用每日提醒")
                            .font(.body)
                            .foregroundColor(AppColors.textPrimary)
                        Text("每天定時提醒你完成打卡任務")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .onChange(of: viewModel.notificationEnabled) {
                    viewModel.setNotificationEnabled(viewModel.notificationEnabled)
                }

                if viewModel.notificationEnabled {
                    DatePicker(
                        "提醒時間",
                        selection: $viewModel.dailyReminderTime,
                        displayedComponents: .hourAndMinute
                    )
                    .onChange(of: viewModel.dailyReminderTime) {
                        viewModel.setDailyReminderTime(viewModel.dailyReminderTime)
                    }
                }
            }

            Section("復盤提醒") {
                Toggle(isOn: $weeklyReviewReminder) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("每週復盤提醒")
                            .font(.body)
                            .foregroundColor(AppColors.textPrimary)
                        Text("每週日提醒你進行週復盤")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }

                Toggle(isOn: $monthlyReviewReminder) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("月度復盤提醒")
                            .font(.body)
                            .foregroundColor(AppColors.textPrimary)
                        Text("每月最後一天提醒你進行月度復盤")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Section("習慣追蹤") {
                Toggle(isOn: $streakReminder) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("連續打卡提醒")
                            .font(.body)
                            .foregroundColor(AppColors.textPrimary)
                        Text("即將斷打卡時提醒你")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Section("社群") {
                Toggle(isOn: $communityNotification) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("社群動態通知")
                            .font(.body)
                            .foregroundColor(AppColors.textPrimary)
                        Text("收到夥伴互動通知")
                            .font(.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Section {
                Button(action: {
                    // 測試通知
                    NotificationManager.shared.scheduleDailyReminder(
                        at: viewModel.dailyReminderTime,
                        title: "測試通知",
                        body: "這是一則測試通知，確認通知功能正常運作！"
                    )
                }) {
                    Label("發送測試通知", systemImage: "bell.badge")
                }
            }
        }
        .navigationTitle(StringConstants.Settings.notifications)
        .navigationBarTitleDisplayMode(.inline)
    }
}
