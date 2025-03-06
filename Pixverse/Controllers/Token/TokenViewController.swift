import AVFoundation
import ApphudSDK
import SafariServices
import StoreKit
import UIKit
import WebKit

struct TokenSubscription {
    let tokens: String
    let price: String
    let discount: String?
    let isFirst: Bool
}

final class TokenViewController: UIViewController {
    // MARK: - Properties

    private let privacyLabel = SFPrivacyLabel()
    private let termsOfUseLabel = SFTermsOfUse()
    private let restorePurchaseLabel = SFRestrorePurchaseLabel(isToken: true)
    private let moreGenerationsView = MoreGenerationsView()

    private let exitButton = UIButton(type: .system)
    private var subscriptions: [TokenSubscription] = []
    private var tokenManager: TokenManager
    
    private let upperImageView = UIImageView()
    private let lowerImageView = UIImageView()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.itemSize = CGSize(width: view.frame.width - 32, height: 54)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(TokenCell.self, forCellWithReuseIdentifier: TokenCell.identifier)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()

    // MARK: - Initializer

    init() {
        tokenManager = TokenManager()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#111111")
        drawSelf()
        restorePurchaseLabel.delegate = self

        Task {
            await loadPaywallDetails()
            await tokenCount()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            UIView.animate(withDuration: 1.0) {
                self?.exitButton.alpha = 1
            }
        }

        termsOfUseLabel.delegate = self
        privacyLabel.delegate = self
    }

    // MARK: - Private methods

    private func drawSelf() {
        upperImageView.image = UIImage(named: "token_upper_image")
        lowerImageView.image = UIImage(named: "token_lower_image")

        exitButton.do { make in
            make.setImage(UIImage(named: "sub_exit_icon"), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            make.alpha = 0
        }

        view.addSubviews(
            upperImageView,
            lowerImageView,
            moreGenerationsView,
            privacyLabel,
            restorePurchaseLabel,
            termsOfUseLabel,
            exitButton,
            collectionView
        )
        
        upperImageView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (414.0 / 844.0))
        }
        
        lowerImageView.snp.makeConstraints { make in
            make.bottom.trailing.leading.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (708.0 / 844.0))
        }
        
        moreGenerationsView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(16)
            make.top.equalTo(lowerImageView.snp.top).offset(85)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(moreGenerationsView.snp.bottom).offset(32)
            make.bottom.equalTo(restorePurchaseLabel.snp.top).offset(-87)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(0)
        }

        privacyLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
        }

        restorePurchaseLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
        }

        termsOfUseLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
        }
        
        exitButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(11)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(23)
        }
    }
    
    private func updateCollectionViewHeight() {
        let itemHeight: CGFloat = 54
        let spacing: CGFloat = 12
        let count = subscriptions.count
        let totalHeight = count > 0 ? (CGFloat(count) * itemHeight) + (CGFloat(count - 1) * spacing) : 0

        collectionView.snp.updateConstraints { make in
            make.height.equalTo(totalHeight)
        }
        
        view.layoutIfNeeded()
    }
    
    private func tokenCount() async {
        let userId = Apphud.userID()
        let bundle = Bundle.main.bundleIdentifier ?? "com.test.test"

        do {
            let updatedTokens = try await NetworkService.shared.getUserTokens(
                userId: userId,
                bundleId: bundle
            )

            DispatchQueue.main.async {
                self.moreGenerationsView.updateTokenCount(count: updatedTokens)
            }
        } catch {
            print("Token error: \(error.localizedDescription)")
        }
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func purchaseSubscription(at index: Int) async {
        guard index >= 0, index < tokenManager.productsApphud.count else { return }

        let selectedProduct = tokenManager.productsApphud[index]
        let tokens = Int(selectedProduct.productId.components(separatedBy: "_").first ?? "0") ?? 0
        let userId = Apphud.userID()
        let bundle = Bundle.main.bundleIdentifier ?? "com.test.test"
        
        await withCheckedContinuation { continuation in
            var isResumed = false

            tokenManager.startPurchase(produst: selectedProduct) { success in
                guard !isResumed else { return }
                isResumed = true

                if success {
                    Task {
                        do {
                            try await NetworkService.shared.buyTokens(
                                userId: userId,
                                bundleId: bundle,
                                generations: tokens
                            )

                            let updatedTokens = try await NetworkService.shared.getUserTokens(
                                userId: userId,
                                bundleId: bundle
                            )
                            
                            DispatchQueue.main.async {
                                self.moreGenerationsView.updateTokenCount(count: updatedTokens)
                            }
                        } catch {
                            print("Token update error:", error)
                        }
                    }
                } else {
                    print("Purchase failed.")
                }

                continuation.resume()
            }
        }
    }
    
    private func loadPaywallDetails() async {
        await withCheckedContinuation { continuation in
            tokenManager.loadPaywalls {
                continuation.resume()
            }
        }

        let products = tokenManager.productsApphud
        guard let firstProduct = products.first(where: { $0.skProduct != nil }),
              let firstSkProduct = firstProduct.skProduct else { return }

        let firstPrice = firstSkProduct.price.doubleValue
        let firstTokens = firstProduct.productId.components(separatedBy: "_").first ?? "N/A"

        subscriptions = products
            .filter { $0.skProduct != nil }
            .enumerated()
            .map { index, product in
                guard let skProduct = product.skProduct else {
                    fatalError("skProduct is expected to be non-nil after filtering.")
                }

                let priceString = skProduct.price.stringValue
                let currencySymbol = skProduct.priceLocale.currencySymbol ?? ""
                let tokens = product.productId.components(separatedBy: "_").first ?? "N/A"
                let currentPrice = skProduct.price.doubleValue
                let currentTokens = Double(tokens) ?? 0
                let currentPricePerToken = currentPrice / currentTokens
                let firstPricePerToken = firstPrice / (Double(firstTokens) ?? 1)
                let percentageBetter = ((firstPricePerToken - currentPricePerToken) / firstPricePerToken) * 100
                
                let discountString = percentageBetter > 0 ? String(format: "%.0f", percentageBetter) : nil
                let isFirst = index == 0
                
                return TokenSubscription(tokens: tokens, price: "\(currencySymbol)\(priceString)", discount: discountString, isFirst: isFirst)
            }

        DispatchQueue.main.async {
            self.collectionView.reloadData()
            self.updateCollectionViewHeight()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TokenViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscriptions.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TokenCell.identifier, for: indexPath) as? TokenCell else {
            return UICollectionViewCell()
        }
        let subscription = subscriptions[indexPath.item]
        cell.configure(tokens: subscription.tokens, price: subscription.price, discount: subscription.discount, isFirst: subscription.isFirst)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        UIView.animate(withDuration: 0.1, animations: {
            cell.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                cell.transform = .identity
            }
        }
        
        Task {
            await purchaseSubscription(at: indexPath.item)
        }
    }
}

// MARK: - SFRestrorePurchaseLabelDelegate
extension TokenViewController: SFRestrorePurchaseLabelDelegate {
    func didFailToRestorePurchases() {
        let alert = UIAlertController(title: L.failRestoreLabel,
                                      message: L.failRestoreMessage,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        alert.overrideUserInterfaceStyle = .dark
        present(alert, animated: true)
    }
}

// MARK: - SFTermsOfUseDelegate
extension TokenViewController: SFTermsOfUseDelegate {
    func termsOfUseTapped() {
        guard let url = URL(string: "https://docs.google.com/document/d/1LPUHYnvwuxAnOh3Gt4qfpSjyZzfpc3B7xcAeNnMslMk/edit?usp=sharing") else {
            print("Invalid URL")
            return
        }

        let webView = WKWebView()
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.load(URLRequest(url: url))

        let webViewViewController = UIViewController()
        webViewViewController.view = webView

        present(webViewViewController, animated: true, completion: nil)
    }
}

// MARK: - SFPrivacyDelegate
extension TokenViewController: SFPrivacyDelegate {
    func privacyTapped() {
        guard let url = URL(string: "https://docs.google.com/document/d/1PcGSiOj6c-UwwLae5R4X6oyL-2kVpQ9JJ59shLap8Bs/edit?usp=sharing") else {
            print("Invalid URL")
            return
        }

        let webView = WKWebView()
        webView.navigationDelegate = self as? WKNavigationDelegate
        webView.load(URLRequest(url: url))

        let webViewViewController = UIViewController()
        webViewViewController.view = webView

        present(webViewViewController, animated: true, completion: nil)
    }
}
