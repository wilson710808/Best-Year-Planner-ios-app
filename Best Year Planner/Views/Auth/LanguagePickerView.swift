import SwiftUI

struct LanguagePickerView: View {
    @Binding var selectedLanguage: AppLanguage
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                List {
                    Section("選擇語言") {
                        ForEach(AppLanguage.allCases, id: \.self) { language in
                            Button(action: {
                                selectedLanguage = language
                                dismiss()
                            }) {
                                HStack {
                                    Text(language.displayName)
                                        .foregroundColor(AppColors.textPrimary)
                                    Spacer()
                                    if selectedLanguage == language {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(AppColors.primary)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .navigationTitle("語言設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}