import Foundation
import Combine

@MainActor
final class CheckInViewModel: ObservableObject {
    @Published var todayTasks: [Task] = []
    @Published var todayCheckIns: [CheckIn] = []
    @Published var selectedTask: Task?
    @Published var selectedCheckInStatus: CheckInStatus = .completed
    @Published var checkInNote: String = ""

    @Published var isLoading: Bool = false
    @Published var showCheckInSuccess: Bool = false
    @Published var errorMessage: String?

    private let taskService = TaskService.shared
    private let checkInService = CheckInService.shared

    var checkedInTaskIds: Set<String> {
        Set(todayCheckIns.map { $0.taskId })
    }

    func loadTodaysData() {
        isLoading = true
        todayTasks = taskService.getTodaysTasks()
        todayCheckIns = checkInService.getTodayCheckIns()
        isLoading = false
    }

    func checkIn(task: Task, status: CheckInStatus, note: String? = nil) -> Bool {
        let result = checkInService.checkIn(taskId: task.id, status: status, note: note)

        switch result {
        case .success:
            showCheckInSuccess = true
            loadTodaysData()
            return true
        case .failure(let error):
            errorMessage = error.localizedDescription
            return false
        }
    }

    func getCheckIn(forTaskId taskId: String) -> CheckIn? {
        todayCheckIns.first { $0.taskId == taskId }
    }

    func getStreak(forTaskId taskId: String) -> Int {
        checkInService.getCurrentStreak(forTaskId: taskId)
    }

    func getCompletionRate(forTaskId taskId: String) -> Double {
        checkInService.getCompletionRate(forTaskId: taskId)
    }

    func selectTask(_ task: Task) {
        selectedTask = task
        checkInNote = ""
        selectedCheckInStatus = .completed
    }

    func clearSelection() {
        selectedTask = nil
        checkInNote = ""
        selectedCheckInStatus = .completed
    }

    func hasCheckedIn(task: Task) -> Bool {
        checkedInTaskIds.contains(task.id)
    }
}
