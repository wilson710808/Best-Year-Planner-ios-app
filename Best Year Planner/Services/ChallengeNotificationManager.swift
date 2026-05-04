import Foundation
import UserNotifications

final class ChallengeNotificationManager {
    static let shared = ChallengeNotificationManager()

    private let notificationCenter = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Authorization

    func requestAuthorization() async -> Bool {
        do {
            return try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            print("[ChallengeNotification] Authorization failed: \(error)")
            return false
        }
    }

    // MARK: - Schedule Challenge Reminders

    /// Schedule daily reminder for an active challenge
    func scheduleChallengeReminder(
        challengeTitle: String,
        dayNumber: Int,
        taskTitle: String,
        hour: Int = 9,
        minute: Int = 0
    ) {
        let content = UNMutableNotificationContent()
        content.title = "最好的一年 💪"
        content.body = "第\(dayNumber)天任務：\(taskTitle) — 只要5分鐘！"
        content.sound = .default
        content.badge = NSNumber(value: 1)

        var components = DateComponents()
        components.hour = hour
        components.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

        let identifier = "\(AppConstants.NotificationIdentifiers.challengeDayReminder)_\(dayNumber)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("[ChallengeNotification] Failed to schedule reminder: \(error)")
            }
        }
    }

    /// Schedule streak warning reminder if user hasn't checked in by evening
    func scheduleStreakWarningReminder(streakDays: Int) {
        let content = UNMutableNotificationContent()
        content.title = "連續打卡提醒 🔥"
        content.body = "你已連續打卡\(streakDays)天！今天還沒打卡，別讓紀錄中斷！"
        content.sound = .default

        var components = DateComponents()
        components.hour = 20
        components.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(
            identifier: AppConstants.NotificationIdentifiers.streakReminder,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("[ChallengeNotification] Failed to schedule streak warning: \(error)")
            }
        }
    }

    /// Schedule 7-day completion celebration reminder
    func scheduleUnlockReminder() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 7天啟動完成！"
        content.body = "你完成了7天啟動計畫！21天挑戰已解鎖，準備好迎接更大的挑戰了嗎？"
        content.sound = .default

        // Immediate notification
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "unlock_reminder",
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            if let error = error {
                print("[ChallengeNotification] Failed to schedule unlock reminder: \(error)")
            }
        }
    }

    /// Schedule all reminders for a 7-day launch challenge
    func scheduleSevenDayLaunchReminders(challenge: Challenge) {
        // Cancel existing challenge reminders
        cancelChallengeReminders()

        for task in challenge.dailyTasks where !task.isCompleted {
            scheduleChallengeReminder(
                challengeTitle: challenge.phase.displayName,
                dayNumber: task.dayNumber,
                taskTitle: task.title,
                hour: 9,
                minute: 0
            )
        }

        // Schedule evening streak reminder
        let completedDays = challenge.dailyTasks.filter { $0.isCompleted }.count
        if completedDays > 0 {
            scheduleStreakWarningReminder(streakDays: completedDays)
        }
    }

    /// Schedule all reminders for a 21-day challenge
    func scheduleTwentyOneDayReminders(challenge: Challenge) {
        for task in challenge.dailyTasks where !task.isCompleted {
            scheduleChallengeReminder(
                challengeTitle: "21天挑戰",
                dayNumber: task.dayNumber,
                taskTitle: task.title,
                hour: 9,
                minute: 0
            )
        }
    }

    // MARK: - Cancel

    func cancelChallengeReminders() {
        notificationCenter.removeAllPendingNotificationRequests()
    }

    func cancelReminder(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    // MARK: - Badge

    func clearBadge() {
        notificationCenter.setBadgeCount(0)
    }

    func setBadge(count: Int) {
        notificationCenter.setBadgeCount(count)
    }
}
