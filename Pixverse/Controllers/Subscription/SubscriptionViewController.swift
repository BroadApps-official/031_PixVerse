import AVFoundation
import SafariServices
import StoreKit
import UIKit
import WebKit

final class SubscriptionViewController: UIViewController {
    // MARK: - Properties

    private let subImageView = UIImageView()
    private let gradientImageView = UIImageView()
    private let benefitsView = SubscribeView()
    private let annualView = AnnualSubView()
    private let weeklyView = WeekSubView()
    private let unlockView = UnlockView()

    private let privacyLabel = SFPrivacyLabel()
    private let termsOfUseLabel = SFTermsOfUse()
    private let restorePurchaseLabel = SFRestrorePurchaseLabel()

    private let continueButton = GeneralButton()
    private let exitButton = UIButton(type: .system)

    private var plan: Int = 0
    private let isFromOnboarding: Bool
    private let isExitShown: Bool
    private var purchaseManager: SubscriptionManager

    private let videoView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    private var experimentV = String()

    // MARK: - Initializer

    init(isFromOnboarding: Bool, isExitShown: Bool) {
        self.isFromOnboarding = isFromOnboarding
        self.isExitShown = isExitShown
        purchaseManager = SubscriptionManager()
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

        annualView.delegate = self
        weeklyView.delegate = self
        restorePurchaseLabel.delegate = self

        annualView.isSelected = true
        weeklyView.isSelected = false
        plan = 0

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(continueButtonTapped))
        continueButton.addGestureRecognizer(tapGesture)

        Task {
            await loadPaywallDetails()
        }

        if !isExitShown {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                UIView.animate(withDuration: 1.0) {
                    self?.exitButton.alpha = 1
                }
            }
        }

        termsOfUseLabel.delegate = self
        privacyLabel.delegate = self

        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            experimentV = appDelegate.experimentV
        }
    }

    // MARK: - Private methods

    private func drawSelf() {
        setupVideo()

        subImageView.image = UIImage(named: "sub_sub_image")
        gradientImageView.image = UIImage(named: "sub_gradient_image")

        continueButton.setTitle(to: L.continue)

        exitButton.do { make in
            make.setImage(UIImage(named: "sub_exit_icon"), for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            make.alpha = 0
            if isExitShown {
                make.isHidden = true
            }
        }

        view.addSubviews(
            subImageView,
            videoView,
            gradientImageView,
            annualView,
            weeklyView,
            privacyLabel,
            restorePurchaseLabel,
            termsOfUseLabel,
            continueButton,
            exitButton
        )

        if experimentV == "v2" {
            view.addSubviews(unlockView)
        } else {
            view.addSubviews(benefitsView)
        }

        subImageView.snp.makeConstraints { make in
            make.top.trailing.leading.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (414.0 / 844.0))
        }
        
        videoView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(videoView.snp.width).multipliedBy(1080.0 / 1000.0)
        }

        gradientImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            if UIDevice.isIpad {
                make.top.equalTo(benefitsView.snp.top).offset(-250)
            } else {
                make.height.equalTo(UIScreen.main.bounds.height * (708.0 / 844.0))
            }
        }

        if experimentV == "v2" {
            unlockView.snp.makeConstraints { make in
                make.height.equalTo(225)
                make.leading.trailing.equalToSuperview().inset(16)
                if UIDevice.isIphoneBelowX {
                    make.bottom.equalTo(annualView.snp.top).offset(-12)
                } else {
                    make.bottom.equalTo(annualView.snp.top).offset(-30)
                }
            }
        } else {
            benefitsView.snp.makeConstraints { make in
                make.height.equalTo(214)
                make.leading.trailing.equalToSuperview().inset(16)
                if UIDevice.isIphoneBelowX {
                    make.bottom.equalTo(annualView.snp.top).offset(-12)
                } else {
                    make.bottom.equalTo(annualView.snp.top).offset(-42)
                }
            }
        }

        annualView.snp.makeConstraints { make in
            make.bottom.equalTo(weeklyView.snp.top).offset(-12)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
        }

        weeklyView.snp.makeConstraints { make in
            make.bottom.equalTo(continueButton.snp.top).offset(-24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(56)
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

        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(restorePurchaseLabel.snp.top).offset(-18)
            make.leading.trailing.equalToSuperview().inset(16)
            if UIDevice.isIphoneBelowX {
                make.height.equalTo(40)
            } else {
                make.height.equalTo(58)
            }
        }

        exitButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(11)
            make.trailing.equalToSuperview().inset(16)
            make.size.equalTo(23)
        }
    }

    // MARK: - Video
    private func setupVideo() {
        guard let videoURL = Bundle.main.url(forResource: "sub_video", withExtension: "mp4") else {
            print("Video not found")
            return
        }
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = .resizeAspectFill
        playerLayer?.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer!)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartVideo),
            name: .AVPlayerItemDidPlayToEndTime,
            object: player?.currentItem
        )

        player?.play()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = videoView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause()
    }

    @objc private func restartVideo() {
        player?.seek(to: .zero)
        player?.play()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }

    // MARK: - Actions
    @objc private func closeButtonTapped() {
        if isFromOnboarding {
            let tabBarController = TabBarController.shared
            let navigationController = UINavigationController(rootViewController: tabBarController)
            navigationController.modalPresentationStyle = .fullScreen
            navigationController.navigationBar.isHidden = true
            present(navigationController, animated: true, completion: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func continueButtonTapped() {
        Task {
            await purchaseSubscription(at: plan)
        }
    }

    private func purchaseSubscription(at index: Int) async {
        guard index >= 0, index < purchaseManager.productsApphud.count else { return }

        let selectedProduct = purchaseManager.productsApphud[index]
        await withCheckedContinuation { continuation in
            var isResumed = false

            purchaseManager.startPurchase(produst: selectedProduct) { success in
                guard !isResumed else { return }
                isResumed = true

                if success {
                    print("succseed purchase!")
                } else {
                    print("failed purchase.")
                }

                continuation.resume()
            }
        }
    }
    
    private func loadPaywallDetails() async {
        await withCheckedContinuation { continuation in
            purchaseManager.loadPaywalls {
                continuation.resume()
            }
        }

        let products = purchaseManager.productsApphud
        let availableProductIds = products.map { $0.productId }

        if let firstProduct = products.first, let skProduct = firstProduct.skProduct {
            let priceString = skProduct.price.stringValue
            let currencySymbol = skProduct.priceLocale.currencySymbol ?? ""
            annualView.updateDetails(title: "Annual", price: "\(currencySymbol)\(priceString)")
            
            if let price = Double(priceString) {
                let weeklyPrice = price / 52.0
                let weeklyText = String(format: "\(currencySymbol)%.2f", weeklyPrice)
                annualView.updateUnderTitleLabel(text: weeklyText)
            }
        } else {
            print("Annual sub not found.")
        }

        if products.count > 1, let secondProduct = products[safe: 1], let skProduct = secondProduct.skProduct {
            let priceString = skProduct.price.stringValue
            let currencySymbol = skProduct.priceLocale.currencySymbol ?? ""
            weeklyView.updateDetails(title: "Weekly", price: "\(currencySymbol)\(priceString)")
        } else {
            print("Weekly sub not found.")
        }
    }
}

// MARK: - AnnualSubViewDelegate
extension SubscriptionViewController: AnnualSubViewDelegate {
    func didTapAnnualSubView(isOn: Bool) {
        annualView.isSelected = true
        weeklyView.isSelected = false
        plan = 0
    }
}

// MARK: - WeekSubViewDelegate
extension SubscriptionViewController: WeekSubViewDelegate {
    func didTapWeekSubView(isOn: Bool) {
        weeklyView.isSelected = true
        annualView.isSelected = false
        plan = 1
    }
}

// MARK: - SFRestrorePurchaseLabelDelegate
extension SubscriptionViewController: SFRestrorePurchaseLabelDelegate {
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
extension SubscriptionViewController: SFTermsOfUseDelegate {
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
extension SubscriptionViewController: SFPrivacyDelegate {
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
