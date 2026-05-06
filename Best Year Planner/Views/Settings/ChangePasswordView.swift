import SwiftUI

/// 修改密碼頁
struct ChangePasswordView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var showSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Form {
                    Section("修改密碼") {
                        SecureField("目前密碼", text: $currentPassword)
                        SecureField("新密碼", text: $newPassword)
                        SecureField("確認新密碼", text: $confirmPassword)
                    }
                    
                    Section {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("密碼要求")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textPrimary)
                            Text("• 至少 6 個字符")
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                            Text("• 建議包含數字和特殊字符")
                                .font(.caption2)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    if let error = errorMessage {
                        Section {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .navigationTitle("修改密碼")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("確認") { changePassword() }
                        .disabled(currentPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty)
                }
            }
            .alert("密碼已更新", isPresented: $showSuccess) {
                Button("好") { dismiss() }
            } message: {
                Text("你的密碼已成功修改")
            }
        }
    }
    
    private func changePassword() {
        guard newPassword == confirmPassword else {
            errorMessage = "兩次輸入的密碼不一致"
            return
        }
        guard newPassword.count >= 6 else {
            errorMessage = "新密碼至少需要 6 個字符"
            return
        }
        
        let result = AuthService.shared.changePassword(
            oldPassword: currentPassword,
            newPassword: newPassword
        )
        switch result {
        case .success:
            showSuccess = true
            currentPassword = ""
            newPassword = ""
            confirmPassword = ""
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
