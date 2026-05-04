import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var localization: LocalizationManager
    @State private var showLanguagePicker = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // 語言選擇器（右上角）
                    HStack {
                        Spacer()
                        Button {
                            showLanguagePicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                Text(localization.currentLanguage.displayName)
                                    .font(.subheadline)
                            }
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.secondary.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text(localization.t("auth.login.title"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Text(localization.t("auth.welcome.back"))
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 16) {
                        CustomTextField(
                            placeholder: localization.t("auth.account.placeholder"),
                            text: $viewModel.account,
                            icon: "person.fill"
                        )

                        CustomTextField(
                            placeholder: localization.t("auth.password.placeholder"),
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
                            Text(localization.t("auth.login.button"))
                                .primaryButtonStyle()
                        }
                    }
                    .disabled(!viewModel.isLoginValid || viewModel.isLoading)
                    .opacity(viewModel.isLoginValid ? 1 : 0.6)
                    .padding(.horizontal, 24)

                    Button {
                    } label: {
                        Text(localization.t("auth.forgotPassword.button"))
                            .font(.subheadline)
                            .foregroundColor(AppColors.primary)
                    }

                    Spacer()

                    HStack {
                        Text(localization.t("auth.noAccount"))
                            .foregroundColor(AppColors.textSecondary)
                        NavigationLink(destination: RegisterView()) {
                            Text(localization.t("auth.signUp"))
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
        .alert(localization.t("common.error"), isPresented: $viewModel.isShowingError) {
            Button(localization.t("common.confirm"), role: .cancel) { }
        } message: {
            Text(viewModel.errorMessage ?? localization.t("error.databaseError"))
        }
        .sheet(isPresented: $showLanguagePicker) {
            LanguageSelectionSheet()
        }
    }
}

// MARK: - 語言選擇 Sheet
struct LanguageSelectionSheet: View {
    @EnvironmentObject private var localization: LocalizationManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            List {
                ForEach(AppLanguage.allCases, id: \.self) { language in
                    Button {
                        localization.setLanguage(language)
                        dismiss()
                    } label: {
                        HStack {
                            Text(language.displayName)
                                .foregroundColor(AppColors.textPrimary)
                            Spacer()
                            if localization.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundColor(AppColors.primary)
                            }
                        }
                    }
                }
            }
            .navigationTitle(localization.t("settings.language"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(localization.t("common.cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.height(CGFloat(AppLanguage.allCases.count * 60 + 100))])
    }
}