import Foundation
import StoreKit
import os.log

@MainActor
final class StoreKitService: ObservableObject {
    static let shared = StoreKitService()

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var purchaseError: String?

    private var transactionListener: Task<Void, Never>?
    private let userDefaults = UserDefaultsManager.shared

    // Product identifiers
    enum ProductID {
        static let premiumMonthly = "com.bestyearplanner.premium.monthly"
        static let premiumYearly = "com.bestyearplanner.premium.yearly"
        static let premiumLifetime = "com.bestyearplanner.premium.lifetime"
    }

    private init() {
        transactionListener = listenForTransactions()
        Task { await loadPurchasedProducts() }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Load Products

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let productIDs = [
                ProductID.premiumMonthly,
                ProductID.premiumYearly,
                ProductID.premiumLifetime
            ]
            products = try await Product.products(for: productIDs)
        } catch {
            AppLogger.log("Failed to load products: \(error)", category: AppLogger.subscription, level: .error)
            purchaseError = "無法載入產品資訊"
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                updateSubscriptionStatus(transaction)
                await transaction.finish()
                return true
            case .userCancelled:
                return false
            case .pending:
                purchaseError = "購買待處理中，請稍後確認"
                return false
            @unknown default:
                return false
            }
        } catch {
            AppLogger.log("Purchase failed: \(error)", category: AppLogger.subscription, level: .error)
            purchaseError = "購買失敗：\(error.localizedDescription)"
            return false
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await loadPurchasedProducts()
        } catch {
            AppLogger.log("Restore failed: \(error)", category: AppLogger.subscription, level: .error)
            purchaseError = "恢復購買失敗"
        }
    }

    // MARK: - Transaction Listener

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self = self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus(transaction)
                    await transaction.finish()
                } catch {
                    AppLogger.log("Transaction verification failed: \(error)", category: AppLogger.subscription, level: .error)
                }
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }

    private func loadPurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                updateSubscriptionStatus(transaction)
            } catch {
                AppLogger.log("Failed to verify entitlement: \(error)", category: AppLogger.subscription, level: .error)
            }
        }
    }

    private func updateSubscriptionStatus(_ transaction: Transaction) {
        if transaction.productID == ProductID.premiumMonthly ||
            transaction.productID == ProductID.premiumYearly ||
            transaction.productID == ProductID.premiumLifetime {

            // 檢查訂閱是否過期
            if let expirationDate = transaction.expirationDate {
                if expirationDate < Date() {
                    // 訂閱已過期 — 降級
                    purchasedProductIDs.remove(transaction.productID)
                    AppState.shared.downgradeFromPremium()
                    userDefaults.subscriptionExpirationDate = nil
                    AppLogger.log("訂閱已過期：\(transaction.productID)", category: AppLogger.subscription, level: .warning)
                    return
                }
                userDefaults.subscriptionExpirationDate = expirationDate
            }

            // 檢查是否在免費試用期
            if transaction.offer?.type == .introductory {
                userDefaults.isInFreeTrial = true
                userDefaults.freeTrialEndDate = transaction.expirationDate
                AppLogger.log("免費試用中：\(transaction.productID)", category: AppLogger.subscription)
            } else {
                userDefaults.isInFreeTrial = false
            }

            purchasedProductIDs.insert(transaction.productID)
            AppState.shared.upgradeToPremium()
            AppLogger.log("訂閱生效：\(transaction.productID)", category: AppLogger.subscription)
        }
    }

    // MARK: - Subscription Status

    /// 是否為高級用戶（含有效訂閱或終身購買）
    var isPremiumUser: Bool {
        if purchasedProductIDs.contains(ProductID.premiumLifetime) { return true }
        if let expiration = userDefaults.subscriptionExpirationDate, expiration > Date() { return true }
        return !purchasedProductIDs.isEmpty
    }

    /// 是否在免費試用期
    var isInFreeTrial: Bool {
        guard userDefaults.isInFreeTrial else { return false }
        if let endDate = userDefaults.freeTrialEndDate, endDate > Date() { return true }
        return false
    }

    /// 訂閱剩餘天數
    var remainingDays: Int? {
        guard let expiration = userDefaults.subscriptionExpirationDate else { return nil }
        return max(Calendar.current.dateComponents([.day], from: Date(), to: expiration).day ?? 0, 0)
    }

    // MARK: - Product Info Helpers

    var monthlyProduct: Product? { products.first { $0.id == ProductID.premiumMonthly } }
    var yearlyProduct: Product? { products.first { $0.id == ProductID.premiumYearly } }
    var lifetimeProduct: Product? { products.first { $0.id == ProductID.premiumLifetime } }
    var isPremium: Bool { !purchasedProductIDs.isEmpty }
}
