import Foundation
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var account: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var nickname: String = ""
    @Published var gender: Gender?
    @Published var birthYear: Int?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isShowingError: Bool = false

    private let authService = AuthService.shared

    var isLoginValid: Bool {
        account.count >= 4 && password.count >= 4
    }

    var isRegisterValid: Bool {
        account.count >= 4 && password.count >= 4 && password == confirmPassword && !nickname.isEmpty
    }

    func login() -> Bool {
        let validation = authService.validateLoginCredentials(account: account, password: password)
        guard validation.isValid else {
            if let error = validation.error {
                displayError(message: error.localizedDescription)
            }
            return false
        }

        isLoading = true
        errorMessage = nil

        let result = authService.login(account: account, password: password)

        isLoading = false

        switch result {
        case .success(let user):
            AppState.shared.login(user: user)
            return true
        case .failure(let error):
            displayError(message: error.localizedDescription)
            return false
        }
    }

    func register() -> Bool {
        let validation = authService.validateRegistrationCredentials(
            account: account,
            password: password,
            confirmPassword: confirmPassword,
            nickname: nickname
        )
        guard validation.isValid else {
            if let error = validation.error {
                displayError(message: error.localizedDescription)
            }
            return false
        }

        isLoading = true
        errorMessage = nil

        let result = authService.register(
            account: account,
            password: password,
            nickname: nickname,
            gender: gender,
            birthYear: birthYear
        )

        isLoading = false

        switch result {
        case .success(let user):
            AppState.shared.login(user: user)
            return true
        case .failure(let error):
            displayError(message: error.localizedDescription)
            return false
        }
    }

    func logout() {
        AppState.shared.logout()
        clearFields()
    }

    func clearFields() {
        account = ""
        password = ""
        confirmPassword = ""
        nickname = ""
        gender = nil
        birthYear = nil
    }

    private func displayError(message: String) {
        errorMessage = message
        isShowingError = true
    }
}