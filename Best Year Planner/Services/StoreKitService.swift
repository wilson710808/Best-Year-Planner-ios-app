import Foundation
import StoreKit

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
        // Start transaction listener
        transactionListener = listenForTransactions()

        // Load previous purchases
        Task {
            await loadPurchasedProducts()
        }
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
            print("[StoreKit] Failed to load products: \(error)")
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
            print("[StoreKit] Purchase failed: \(error)")
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
            print("[StoreKit] Restore failed: \(error)")
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
                    print("[StoreKit] Transaction verification failed: \(error)")
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
                print("[StoreKit] Failed to verify entitlement: \(error)")
            }
        }
    }

    private func updateSubscriptionStatus(_ transaction: Transaction) {
        if transaction.productID == ProductID.premiumMonthly ||
           transaction.productID == ProductID.premiumYearly ||
           transaction.productID == ProductID.premiumLifetime {
            purchasedProductIDs.insert(transaction.productID)
            AppState.shared.upgradeToPremium()
        }
    }

    // MARK: - Product Info Helpers

    var monthlyProduct: Product? {
        products.first { $0.id == ProductID.premiumMonthly }
    }

    var yearlyProduct: Product? {
        products.first { $0.id == ProductID.premiumYearly }
    }

    var lifetimeProduct: Product? {
        products.first { $0.id == ProductID.premiumLifetime }
    }

    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
}
