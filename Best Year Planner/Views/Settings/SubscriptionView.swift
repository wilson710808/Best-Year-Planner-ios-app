import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKit = StoreKitService.shared
    @State private var selectedProductID: String?

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
                    .background(AppColors.cardBackground)
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
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .padding(.horizontal)

                    // Premium products
                    if !storeKit.products.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(StringConstants.Subscription.features)
                                .font(.headline)
                                .foregroundColor(AppColors.textPrimary)
                                .padding(.horizontal)

                            ForEach(storeKit.products, id: \.id) { product in
                                ProductCard(
                                    product: product,
                                    isSelected: selectedProductID == product.id,
                                    onSelect: { selectedProductID = product.id }
                                )
                                .padding(.horizontal)
                            }
                        }
                    } else {
                        // Premium features list
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
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // Error message
                    if let error = storeKit.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(AppColors.error)
                            .padding(.horizontal)
                    }

                    // Upgrade button
                    if !appState.subscriptionState.isPremium {
                        Button(action: {
                            Task {
                                if let productID = selectedProductID,
                                   let product = storeKit.products.first(where: { $0.id == productID }) {
                                    let success = await storeKit.purchase(product)
                                    if success {
                                        dismiss()
                                    }
                                } else {
                                    // Fallback: direct upgrade (for testing)
                                    appState.upgradeToPremium()
                                    dismiss()
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                if storeKit.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                } else {
                                    Image(systemName: "crown.fill")
                                }
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

                        Button(action: {
                            Task {
                                await storeKit.restorePurchases()
                            }
                        }) {
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
            .task {
                await storeKit.loadProducts()
            }
        }
    }
}

// MARK: - Product Card
struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(isSelected ? AppColors.accent : AppColors.divider, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(AppColors.accent)
                            .frame(width: 16, height: 16)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.textPrimary)

                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Text(product.displayPrice)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.accent)
            }
            .padding()
            .background(isSelected ? AppColors.accent.opacity(0.05) : Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.accent : AppColors.divider, lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
