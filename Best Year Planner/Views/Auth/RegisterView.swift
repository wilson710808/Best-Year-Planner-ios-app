import SwiftUI

struct RegisterView: View {
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
                        Text(localization.t("auth.register.title"))
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)

                        Text(localization.t("auth.createAccount"))
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
                            placeholder: localization.t("auth.nickname.placeholder"),
                            text: $viewModel.nickname,
                            icon: "person.text.rectangle"
                        )

                        CustomTextField(
                            placeholder: localization.t("auth.password.placeholder"),
                            text: $viewModel.password,
                            icon: "lock.fill",
                            isSecure: true
                        )

                        CustomTextField(
                            placeholder: localization.t("auth.confirmPassword.placeholder"),
                            text: $viewModel.confirmPassword,
                            icon: "lock.fill",
                            isSecure: true
                        )
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.t("auth.gender.label"))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Picker("性別", selection: $viewModel.gender) {
                            Text(localization.t("auth.selectGender")).tag(Gender?.none)
                            ForEach(Gender.allCases, id: \.self) { gender in
                                Text(gender.displayName).tag(Gender?.some(gender))
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal, 24)

                    VStack(alignment: .leading, spacing: 8) {
                        Text(localization.t("auth.birthYear.label"))
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Picker("出生年份", selection: $viewModel.birthYear) {
                            Text(localization.t("auth.selectGender")).tag(Int?.none)
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
                            Text(localization.t("auth.register.button"))
                                .primaryButtonStyle()
                        }
                    }
                    .disabled(!viewModel.isRegisterValid || viewModel.isLoading)
                    .opacity(viewModel.isRegisterValid ? 1 : 0.6)
                    .padding(.horizontal, 24)

                    Spacer()

                    HStack {
                        Text(localization.t("auth.hasAccount"))
                            .foregroundColor(AppColors.textSecondary)
                        NavigationLink(destination: LoginView()) {
                            Text(localization.t("auth.signIn"))
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