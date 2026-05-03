import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var showLogoutConfirmation: Bool = false
    @Published var showDeleteAccountConfirmation: Bool = false
    @Published var notificationEnabled: Bool = false
    @Published var dailyReminderTime: Date = Date()
    @Published var themeMode: ThemeMode = .system

    private let authService = AuthService.shared
    private let userDefaults = UserDefaultsManager.shared

    func loadSettings() {
        currentUser = authService.getCurrentUser()
        notificationEnabled = userDefaults.notificationEnabled
        dailyReminderTime = userDefaults.dailyReminderTime ?? Date()
        themeMode = userDefaults.themeMode
    }

    func updateProfile(nickname: String, gender: Gender?, birthYear: Int?) -> Bool {
        guard var user = currentUser else { return false }

        user.nickname = nickname
        user.gender = gender
        user.birthYear = birthYear

        let result = authService.updateUser(user)
        switch result {
        case .success(let updatedUser):
            currentUser = updatedUser
            AppState.shared.currentUser = updatedUser
            return true
        case .failure:
            return false
        }
    }

    func changePassword(oldPassword: String, newPassword: String) -> Result<Void, AuthError> {
        let result = authService.changePassword(oldPassword: oldPassword, newPassword: newPassword)
        return result
    }

    func setNotificationEnabled(_ enabled: Bool) {
        notificationEnabled = enabled
        userDefaults.notificationEnabled = enabled

        if enabled {
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    NotificationManager.shared.scheduleDailyReminder(
                        at: self.dailyReminderTime,
                        title: "打卡提醒",
                        body: "今天還有任務等著你完成喔！快去打開App打卡吧！"
                    )
                }
            }
        } else {
            NotificationManager.shared.cancelNotification(identifier: AppConstants.NotificationIdentifiers.dailyReminder)
        }
    }

    func setDailyReminderTime(_ time: Date) {
        dailyReminderTime = time
        userDefaults.dailyReminderTime = time

        if notificationEnabled {
            NotificationManager.shared.scheduleDailyReminder(
                at: time,
                title: "打卡提醒",
                body: "今天還有任務等著你完成喔！快去打開App打卡吧！"
            )
        }
    }

    func setThemeMode(_ mode: ThemeMode) {
        themeMode = mode
        userDefaults.themeMode = mode
        AppState.shared.setThemeMode(mode)
    }

    func syncData() {
        userDefaults.lastSyncDate = Date()
    }

    func exportData() -> URL? {
        let goals = GoalService.shared.getAllGoals()
        let tasks = TaskService.shared.getAllTasks()
        let checkIns = CheckInService.shared.getAllCheckIns()

        let exportData: [String: Any] = [
            "exportDate": Date().ISO8601Format(),
            "goals": goals.map { try? JSONEncoder().encode($0) }.compactMap { $0 },
            "tasks": tasks.map { try? JSONEncoder().encode($0) }.compactMap { $0 },
            "checkIns": checkIns.map { try? JSONEncoder().encode($0) }.compactMap { $0 }
        ]

        guard let data = try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted) else {
            return nil
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("bestyear_backup.json")
        try? data.write(to: tempURL)

        return tempURL
    }

    func logout() {
        AppState.shared.logout()
    }

    func deleteAccount() {
        userDefaults.clearAll()
        AppState.shared.logout()
    }
}
