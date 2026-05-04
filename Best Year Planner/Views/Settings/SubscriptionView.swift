import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: SubscriptionTier = .premium

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [AppColors.accent, Color(hex: "FFD700")],
                                    startPoint: .top, endPoint: .bottom
                                )
                            )

                        Text(StringConstants.Subscription.title)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.top, 24)

                    // Current plan
                    HStack {
                        Text(StringConstants.Subscription.currentPlan)
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)

                        Spacer()

                        Text(appState.subscriptionState.isPremium ?
                             StringConstants.Subscription.premiumActive :
                             StringConstants.Subscription.freeTier)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(appState.subscriptionState.isPremium ? AppColors.accent : AppColors.textPrimary)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Free tier info
                    VStack(alignment: .leading, spacing: 12) {
                        Text(StringConstants.Subscription.freeTier)
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        HStack(spacing: 12) {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(AppColors.success)
                            Text(String(format: StringConstants.Subscription.freeChallenges, AppConstants.Challenge.maxFreeChallenges))
                                .font(.subheadline)
                                .foregroundColor(AppColors.textSecondary)
                        }

                        if !appState.subscriptionState.isPremium {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(AppColors.primary)
                                Text(String(format: StringConstants.Subscription.freeRemaining,
                                           appState.subscriptionState.remainingFreeChallenges))
                                    .font(.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Premium features
                    VStack(alignment: .leading, spacing: 16) {
                        Text(StringConstants.Subscription.features)
                            .font(.headline)
                            .foregroundColor(AppColors.textPrimary)

                        ForEach(SubscriptionFeature.allCases, id: \.rawValue) { feature in
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(AppColors.accent)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(feature.title)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(AppColors.textPrimary)

                                    Text(feature.description)
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Upgrade button
                    if !appState.subscriptionState.isPremium {
                        Button(action: {
                            appState.upgradeToPremium()
                            dismiss()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "crown.fill")
                                Text(StringConstants.Subscription.upgradeButton)
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [AppColors.accent, Color(hex: "FFD700")],
                                    startPoint: .leading, endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .padding(.horizontal)

                        Button(action: {}) {
                            Text(StringConstants.Subscription.restorePurchases)
                                .font(.caption)
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                }
                .padding(.bottom, 32)
            }
            .background(AppColors.background)
            .navigationTitle(StringConstants.Settings.subscription)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
    }
}
