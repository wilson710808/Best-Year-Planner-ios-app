import SwiftUI

struct ChallengeUnlockView: View {
    @ObservedObject var viewModel: ChallengeViewModel
    @EnvironmentObject private var appState: AppState
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                // Celebration animation
                ZStack {
                    Circle()
                        .fill(AppColors.accent.opacity(0.15))
                        .frame(width: 180, height: 180)

                    Circle()
                        .fill(AppColors.accent.opacity(0.25))
                        .frame(width: 130, height: 130)

                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.accent)
                }
                .scaleEffect(showConfetti ? 1.0 : 0.5)
                .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)

                // Title
                VStack(spacing: 12) {
                    Text(StringConstants.Onboarding.unlockTitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(StringConstants.Onboarding.unlockSubtitle)
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }

                // Stats
                HStack(spacing: 24) {
                    StatBadge(value: "7", label: "連續天數", icon: "flame.fill", color: AppColors.accent)
                    StatBadge(value: "5", label: "分鐘/天", icon: "clock.fill", color: AppColors.primary)
                    StatBadge(value: "100%", label: "完成率", icon: "checkmark.seal.fill", color: AppColors.success)
                }
                .padding(.horizontal)

                // CTA
                VStack(spacing: 12) {
                    Button(action: {
                        Task { await viewModel.startTwentyOneDayChallenge() }
                    }) {
                        HStack(spacing: 8) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                            Text(StringConstants.Onboarding.startChallengeButton)
                                .font(.headline)
                            Image(systemName: "arrow.right")
                        }
                        .primaryButtonStyle()
                    }
                    .disabled(viewModel.isLoading)

                    if !appState.subscriptionState.isPremium {
                        Button(action: {
                            viewModel.showingSubscription = true
                        }) {
                            Text(StringConstants.Subscription.upgradeButton)
                                .font(.subheadline)
                                .foregroundColor(AppColors.accent)
                        }
                    }
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                showConfetti = true
            }
        }
        .sheet(isPresented: $viewModel.showingSubscription) {
            SubscriptionView()
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text(label)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
