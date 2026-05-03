import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(StringConstants.Auth.loginTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Text("歡迎回來！")
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: StringConstants.Auth.accountPlaceholder,
                            text: $viewModel.account,
                            icon: "person.fill"
                        )

                        CustomTextField(
                            placeholder: StringConstants.Auth.passwordPlaceholder,
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 24)

                    Button {
                        let success = viewModel.login()
                        if success {
                            dismiss()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(AppColors.primary)
                                .cornerRadius(12)
                        } else {
                            Text(StringConstants.Auth.loginButton)
                                .primaryButtonStyle()
                        }
                    }
                    .disabled(!viewModel.isLoginValid || viewModel.isLoading)
                    .opacity(viewModel.isLoginValid ? 1 : 0.6)
                    .padding(.horizontal, 24)

                    Button {
                    } label: {
                        Text(StringConstants.Auth.forgotPasswordButton)
                            .font(.subheadline)
                            .foregroundColor(AppColors.primary)
                    }

                    Spacer()

                    HStack {
                        Text(StringConstants.Auth.noAccount)
                            .foregroundColor(AppColors.textSecondary)
                        NavigationLink(destination: RegisterView()) {
                            Text(StringConstants.Auth.signUp)
                                .foregroundColor(AppColors.primary)
                                .fontWeight(.semibold)
                        }
                    }
                    .font(.subheadline)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("錯誤", isPresented: $viewModel.isShowingError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? "發生未知錯誤")
        }
    }
}