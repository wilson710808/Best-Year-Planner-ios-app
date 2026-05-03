import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @StateObject private var localizationManager = LocalizationManager.shared
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section("個人資料") {
                    NavigationLink(destination: ProfileEditView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(AppColors.primary)
                                .font(.title)

                            VStack(alignment: .leading) {
                                Text(viewModel.currentUser?.nickname ?? "用戶")
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text(viewModel.currentUser?.account ?? "")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }

                Section("語言") {
                    Picker("語言", selection: $localizationManager.currentLanguage) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section("通知") {
                    Toggle(isOn: $viewModel.notificationEnabled) {
                        Label("打卡提醒", systemImage: "bell.fill")
                    }
                    .onChange(of: viewModel.notificationEnabled) {
                        viewModel.setNotificationEnabled(viewModel.notificationEnabled)
                    }

                    if viewModel.notificationEnabled {
                        DatePicker(
                            "每日提醒時間",
                            selection: $viewModel.dailyReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: viewModel.dailyReminderTime) {
                            viewModel.setDailyReminderTime(viewModel.dailyReminderTime)
                        }
                    }
                }

                Section("外觀") {
                    Picker("主題模式", selection: $viewModel.themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .onChange(of: viewModel.themeMode) {
                        viewModel.setThemeMode(viewModel.themeMode)
                    }
                }

                Section("數據管理") {
                    Button(action: {
                        viewModel.syncData()
                    }) {
                        Label("同步數據", systemImage: "arrow.triangle.2.circlepath")
                    }

                    Button(action: {
                        if let url = viewModel.exportData() {
                            print("Exported to: \(url)")
                        }
                    }) {
                        Label("導出數據", systemImage: "square.and.arrow.up")
                    }
                }

                Section("關於") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    NavigationLink(destination: AboutView()) {
                        Text("關於App")
                    }

                    NavigationLink(destination: Text("書籍核心觀念")) {
                        Text("《規劃最好的一年》核心原則")
                    }
                }

                Section {
                    Button(action: {
                        viewModel.showLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text(StringConstants.Settings.logout)
                                .foregroundColor(AppColors.error)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(StringConstants.Settings.title)
            .alert("確認登出", isPresented: $viewModel.showLogoutConfirmation) {
                Button("取消", role: .cancel) {}
                Button("登出", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("你確定要登出嗎？")
            }
            .onAppear {
                viewModel.loadSettings()
            }
        }
    }
}

struct ProfileEditView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var nickname: String = ""
    @State private var gender: Gender?
    @State private var birthYear: Int?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("基本資訊") {
                TextField("暱稱", text: $nickname)

                Picker("性別", selection: $gender) {
                    Text("請選擇").tag(Gender?.none)
                    ForEach(Gender.allCases, id: \.self) { g in
                        Text(g.displayName).tag(Gender?.some(g))
                    }
                }

                Picker("出生年份", selection: $birthYear) {
                    Text("請選擇").tag(Int?.none)
                    ForEach((1950...2025).reversed(), id: \.self) { year in
                        Text("\(year)").tag(Int?.some(year))
                    }
                }
            }

            Section("帳戶安全") {
                NavigationLink(destination: ChangePasswordView(viewModel: viewModel)) {
                    Text("修改密碼")
                }
            }
        }
        .navigationTitle(StringConstants.Settings.profile)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("保存") {
                    _ = viewModel.updateProfile(nickname: nickname, gender: gender, birthYear: birthYear)
                    dismiss()
                }
            }
        }
        .onAppear {
            nickname = viewModel.currentUser?.nickname ?? ""
            gender = viewModel.currentUser?.gender
            birthYear = viewModel.currentUser?.birthYear
        }
    }
}

struct ChangePasswordView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section("修改密碼") {
                SecureField("當前密碼", text: $currentPassword)
                SecureField("新密碼", text: $newPassword)
                SecureField("確認新密碼", text: $confirmPassword)
            }

            Section {
                Button("確認修改") {
                    if newPassword == confirmPassword {
                        _ = viewModel.changePassword(oldPassword: currentPassword, newPassword: newPassword)
                        dismiss()
                    }
                }
                .disabled(currentPassword.isEmpty || newPassword.isEmpty || newPassword != confirmPassword)
            }
        }
        .navigationTitle("修改密碼")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "book.pages.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)

                    Text("Best Year Planner")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("基於《規劃最好的一年》")
                        .font(.subheadline)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)

                VStack(alignment: .leading, spacing: 16) {
                    Text("核心理念")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("本書強調「規則化」和「自我反省」的重要性，透過五步驟法則幫助讀者設定並達成人生目標。")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("主要功能")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    FeatureRow(icon: "target", title: "目標設定", description: "SMART原則設定具體目標")
                    FeatureRow(icon: "checkmark.circle", title: "每日打卡", description: "追蹤並記錄你的進度")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "進度回顧", description: "每週、每月、每年複盤")
                    FeatureRow(icon: "person.2", title: "社群互助", description: "與夥伴相互激勵")
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("使用條款")
                        .font(.headline)
                        .foregroundColor(AppColors.textPrimary)

                    Text("本App僅供個人使用目的，不構成任何投資建議。")
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .padding()
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("關於")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(AppColors.primary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(AppColors.textPrimary)

                Text(description)
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
}