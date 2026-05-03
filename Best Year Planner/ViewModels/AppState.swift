import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    static let shared = AppState()

    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var isOnboardingCompleted: Bool = false
    @Published var themeMode: ThemeMode = .system
    @Published var isLoading: Bool = false

    private let userDefaults = UserDefaultsManager.shared
    private let authService = AuthService.shared

    private init() {
        authService.createTestUserIfNeeded()
        loadState()
    }

    func loadState() {
        themeMode = userDefaults.themeMode
        isOnboardingCompleted = userDefaults.isOnboardingCompleted

        if let _ = userDefaults.currentUserId {
            let result = authService.autoLogin()
            if case .success(let user) = result {
                isLoggedIn = true
                currentUser = user
                isOnboardingCompleted = user.isOnboardingCompleted
            }
        }
    }

    func login(user: User) {
        currentUser = user
        isLoggedIn = true
        userDefaults.currentUserId = user.id
    }

    func logout() {
        authService.logout()
        currentUser = nil
        isLoggedIn = false
    }

    func completeOnboarding() {
        isOnboardingCompleted = true
        userDefaults.isOnboardingCompleted = true

        if var user = currentUser {
            user.isOnboardingCompleted = true
            currentUser = user
            _ = authService.updateUser(user)
        }
    }

    func setThemeMode(_ mode: ThemeMode) {
        themeMode = mode
        userDefaults.themeMode = mode
    }
}
