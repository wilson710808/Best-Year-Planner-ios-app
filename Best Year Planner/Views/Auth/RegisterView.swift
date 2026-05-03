import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        Text(StringConstants.Auth.registerTitle)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Text("創建你的帳戶")
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
                            placeholder: StringConstants.Auth.nicknamePlaceholder,
                            text: $viewModel.nickname,
                            icon: "person.text.rectangle"
                        )

                        CustomTextField(
                            placeholder: StringConstants.Auth.passwordPlaceholder,
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )

                        CustomTextField(
                            placeholder: StringConstants.Auth.confirmPasswordPlaceholder,
                            text: $viewModel.confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("性別（選填）")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Picker("性別", selection: $viewModel.gender) {
                            Text("請選擇").tag(Gender?.none)
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.displayName).tag(Gender?.some(gender))
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("出生年份（選填）")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Picker("出生年份", selection: $viewModel.birthYear) {
                            Text("請選擇").tag(Int?.none)
                            ForEach((1950...2025).reversed(), id: \.self) { year in
                                Text("\(year)").tag(Int?.some(year))
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(height: 100)
                    }
                    .padding(.horizontal, 24)

                    Button {
                        let success = viewModel.register()
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
                            Text(StringConstants.Auth.registerButton)
                                .primaryButtonStyle()
                        }
                    }
                    .disabled(!viewModel.isRegisterValid || viewModel.isLoading)
                    .opacity(viewModel.isRegisterValid ? 1 : 0.6)
                    .padding(.horizontal, 24)

                    Spacer()

                    HStack {
                        Text(StringConstants.Auth.hasAccount)
                            .foregroundColor(AppColors.textSecondary)
                        NavigationLink(destination: LoginView()) {
                            Text(StringConstants.Auth.signIn)
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