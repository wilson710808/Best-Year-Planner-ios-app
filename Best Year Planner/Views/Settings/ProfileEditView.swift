import SwiftUI

/// 個人資料編輯頁
struct ProfileEditView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String = ""
    @State private var account: String = ""
    @State private var showSaveSuccess = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                Form {
                    Section("基本資料") {
                        TextField("暱稱", text: $nickname)
                        TextField("帳號", text: $account)
                            .disabled(true)
                    }
                    
                    Section("使用統計") {
                        HStack {
                            Text("使用天數")
                            Spacer()
                            Text("\(FeatureUnlockManager.shared.daysSinceFirstUse) 天")
                                .foregroundColor(AppColors.textSecondary)
                        }
                        HStack {
                            Text("已解鎖功能")
                            Spacer()
                            let unlocked = Feature.allCases.filter { FeatureUnlockManager.shared.isUnlocked($0) }
                            Text("\(unlocked.count)/\(Feature.allCases.count)")
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
            }
            .navigationTitle("編輯個人資料")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") { saveProfile() }
                        .disabled(nickname.isEmpty)
                }
            }
            .alert("保存成功", isPresented: $showSaveSuccess) {
                Button("好") { dismiss() }
            }
            .onAppear {
                if let user = AuthService.shared.getCurrentUser() {
                    nickname = user.nickname
                    account = user.account
                }
            }
        }
    }
    
    private func saveProfile() {
        if let user = AuthService.shared.getCurrentUser() {
            var updated = user
            updated.nickname = nickname
            _ = AuthService.shared.updateUser(updated)
        }
        showSaveSuccess = true
    }
}
