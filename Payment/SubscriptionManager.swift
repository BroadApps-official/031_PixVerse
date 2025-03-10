import ApphudSDK
import Combine
import Foundation
import StoreKit

class SubscriptionManager: NSObject {
    let paywallID = "main"
    var productsApphud: [ApphudProduct] = []

    override init() {
        super.init()
    }

    // MARK: - Subscription Check
    var hasUnlockedPro: Bool {
        return Apphud.hasPremiumAccess()
    }

    // MARK: - Subscription Purchase
    @MainActor func startPurchase(produst: ApphudProduct, escaping: @escaping (Bool) -> Void) {
        let selectedProduct = produst
        Apphud.purchase(selectedProduct) { result in
            if let error = result.error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            debugPrint(result)
            if let subscription = result.subscription, subscription.isActive() {
                escaping(true)
            } else if let purchase = result.nonRenewingPurchase, purchase.isActive() {
                escaping(true)
            } else {
                if Apphud.hasActiveSubscription() {
                    escaping(true)
                }
            }
        }
    }

    // MARK: - Restore Purchase
    @MainActor func restorePurchase(escaping: @escaping (Bool) -> Void) {
        Apphud.restorePurchases { subscriptions, _, error in
            if let error = error {
                debugPrint(error.localizedDescription)
                escaping(false)
            }
            if subscriptions?.first?.isActive() ?? false {
                escaping(true)
                return
            }

            if Apphud.hasActiveSubscription() {
                escaping(true)
            }
        }
    }

    // MARK: - Load Subscription
    @MainActor
    func loadPaywalls(completion: @escaping () -> Void) {
        Apphud.paywallsDidLoadCallback { paywalls, _ in
            if let paywall = paywalls.first(where: { $0.identifier == self.paywallID }) {
                self.productsApphud = paywall.products
                for product in self.productsApphud {
                    let id = product.productId
                    let name = product.skProduct?.localizedTitle ?? "No title"
                    let price = product.skProduct?.price.stringValue ?? "No price"
                    let period = product.skProduct?.subscriptionPeriod?.unit.rawValue == 0 ? "Неделя"
                        : product.skProduct?.subscriptionPeriod?.unit.rawValue == 1 ? "Месяц"
                        : "Год"
                }
            } else {
                print("Paywall \(self.paywallID) not found.")
            }
            completion()
        }
    }
}
