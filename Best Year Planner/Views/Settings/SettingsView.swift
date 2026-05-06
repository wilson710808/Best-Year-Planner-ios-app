import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showShareSheet = false
    @State private var exportFileURL: URL?
    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            List {
                Section(localizationManager.t("settings.profile")) {
                    NavigationLink(destination: ProfileEditView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(AppColors.primary)
                                .font(.title)

                            VStack(alignment: .leading) {
                                Text(viewModel.currentUser?.nickname ?? localizationManager.t("settings.profile"))
                                    .font(.headline)
                                    .foregroundColor(AppColors.textPrimary)

                                Text(viewModel.currentUser?.account ?? "")
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                }

                Section(localizationManager.t("settings.language")) {
                    Picker(localizationManager.t("settings.language"), selection: $localizationManager.currentLanguage) {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Text(language.displayName).tag(language)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section(localizationManager.t("settings.notification")) {
                    Toggle(isOn: $viewModel.notificationEnabled) {
                        Label(localizationManager.t("settings.checkInReminder"), systemImage: "bell.fill")
                    }
                    .onChange(of: viewModel.notificationEnabled) {
                        viewModel.setNotificationEnabled(viewModel.notificationEnabled)
                    }

                    if viewModel.notificationEnabled {
                        DatePicker(
                            localizationManager.t("settings.dailyReminderTime"),
                            selection: $viewModel.dailyReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                        .onChange(of: viewModel.dailyReminderTime) {
                            viewModel.setDailyReminderTime(viewModel.dailyReminderTime)
                        }
                    }
                }

                Section(localizationManager.t("settings.appearance")) {
                    Picker(localizationManager.t("settings.themeMode"), selection: $viewModel.themeMode) {
                        ForEach(ThemeMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .onChange(of: viewModel.themeMode) {
                        viewModel.setThemeMode(viewModel.themeMode)
                    }
                }

                Section("AI 教練") {
                    NavigationLink(destination: CoachStylePickerView()) {
                        HStack {
                            Text("教練風格")
                            Spacer()
                            Text(CoachStyle(rawValue: UserDefaults.standard.string(forKey: "coachStyle") ?? "warm")?.displayName ?? "溫暖鼓勵")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.subheadline)
                        }
                    }
                }

                Section(localizationManager.t("settings.dataManagement")) {
                    Button(action: {
                        viewModel.syncData()
                    }) {
                        Label(localizationManager.t("settings.syncData"), systemImage: "arrow.triangle.2.circlepath")
                    }

                    Button(action: {
                        if let url = viewModel.exportData() {
                            print("Exported to: \(url)")
                        }
                    }) {
                        Label(localizationManager.t("settings.exportData"), systemImage: "square.and.arrow.up")
                    }
                }

                Section(localizationManager.t("settings.about")) {
                    HStack {
                        Text(localizationManager.t("settings.version"))
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(AppColors.textSecondary)
                    }

                    NavigationLink(destination: AboutView()) {
                        Text(localizationManager.t("settings.aboutApp"))
                    }

                    NavigationLink(destination: Text(localizationManager.t("settings.bookCorePrinciples"))) {
                        Text(localizationManager.t("settings.bookCorePrinciples"))
                    }
                }

                Section {
                    Button(action: {
                        viewModel.showLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Text(localizationManager.t("settings.logout"))
                                .foregroundColor(AppColors.error)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle(localizationManager.t("settings.title"))
            .alert(localizationManager.t("common.confirm"), isPresented: $viewModel.showLogoutConfirmation) {
                Button(localizationManager.t("common.cancel"), role: .cancel) {}
                Button(localizationManager.t("settings.logout"), role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text(localizationManager.t("common.confirm"))
            }
            .onAppear {
                viewModel.loadSettings()
            }
        }
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

// MARK: - Share Sheet Wrapper
struct ShareSheetView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
