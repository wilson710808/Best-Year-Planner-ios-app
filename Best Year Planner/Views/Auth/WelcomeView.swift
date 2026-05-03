import SwiftUI

struct WelcomeView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    @State private var showLogin = false
    @State private var showRegister = false
    @State private var showLanguagePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [AppColors.primary.opacity(0.1), AppColors.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 40) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            showLanguagePicker = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "globe")
                                    .foregroundColor(AppColors.textSecondary)
                                Text(localizationManager.currentLanguage.displayName)
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .padding(8)
                            .background(Color.white)
                            .cornerRadius(20)
                            .shadow(color: Color.black.opacity(0.05), radius: 2)
                        }
                        .padding(.trailing, 24)
                        .padding(.top, 16)
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.system(size: 80))
                            .foregroundColor(AppColors.primary)

                        Text(StringConstants.Auth.welcomeTitle)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.center)

                        Text(StringConstants.Auth.welcomeSubtitle)
                            .font(.body)
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }

                    Spacer()

                    VStack(spacing: 16) {
                        Button {
                            showLogin = true
                        } label: {
                            Text(StringConstants.Auth.loginButton)
                                .primaryButtonStyle()
                        }

                        Button {
                            showRegister = true
                        } label: {
                            Text(StringConstants.Auth.registerButton)
                                .secondaryButtonStyle()
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 48)
                }
            }
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterView()
            }
            .sheet(isPresented: $showLanguagePicker) {
                LanguagePickerView(selectedLanguage: $localizationManager.currentLanguage)
            }
        }
    }
}