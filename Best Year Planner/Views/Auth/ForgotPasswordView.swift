import SwiftUI

struct ForgotPasswordView: View {
    @State private var email: String = ""
    @State private var showSuccessAlert: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Image(systemName: "key.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)

                    Text(StringConstants.Auth.forgotPasswordTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)

                    Text("輸入你的電子郵箱，我們會寄送密碼重置連結")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 40)

                VStack(spacing: 16) {
                    CustomTextField(
                        placeholder: StringConstants.Auth.emailPlaceholder,
                        text: $email,
                        icon: "envelope.fill"
                    )
                }
                .padding(.horizontal, 24)

                Button(action: {
                    showSuccessAlert = true
                }) {
                    Text("發送重置連結")
                        .primaryButtonStyle()
                }
                .disabled(email.isEmpty)
                .opacity(email.isEmpty ? 0.6 : 1)
                .padding(.horizontal, 24)

                Spacer()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("郵件已發送", isPresented: $showSuccessAlert) {
            Button("確定") {
                dismiss()
            }
        } message: {
            Text("請檢查你的電子郵箱並點擊連結重置密碼")
        }
    }
}

