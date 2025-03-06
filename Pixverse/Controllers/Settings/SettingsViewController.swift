import ApphudSDK
import MessageUI
import SafariServices
import StoreKit
import UIKit
import WebKit

final class SettingsViewController: UIViewController {
    // MARK: - Properties

    private let stackView = UIStackView()
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var upgradeView = UpgradeSettingsView(delegate: self)
    private lazy var notificationsView = NotificationSettingsView(delegate: self)
    private lazy var rateView = RateSettingsView(delegate: self)
    private lazy var contactView = ContactSettingsView(delegate: self)
    private lazy var privacyPolicyView = PrivacySettingsView(delegate: self)
    private lazy var usagePolicyView = UsageSettingsView(delegate: self)
    private lazy var tokensView = TokensView(delegate: self)

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        tabBarController?.tabBar.isTranslucent = true
        tabBarController?.tabBar.backgroundImage = UIImage()
        tabBarController?.tabBar.shadowImage = UIImage()

        title = L.settings
        view.backgroundColor = UIColor.bgPrimary

        drawSelf()

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false

        configureConstraints()
        
        Task {
            await tokenCount()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await tokenCount()
        }
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
                self.tokensView.tokensValue(value: updatedTokens)
            }
        } catch {
            print("Token error: \(error.localizedDescription)")
        }
    }

    private func drawSelf() {
        stackView.do { make in
            make.axis = .vertical
            make.spacing = 12
        }

        stackView.addArrangedSubviews(
            [upgradeView, rateView, contactView,
             privacyPolicyView, usagePolicyView,
             notificationsView]
        )
        
        upgradeView.addSubviews(tokensView)

        scrollView.addSubviews(contentView)

        contentView.addSubviews(
            stackView
        )

        view.addSubviews(scrollView)
    }

    private func configureConstraints() {
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
            make.height.equalTo(scrollView.snp.height)
        }

        stackView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(24)
            make.trailing.leading.equalToSuperview().inset(16)
            make.height.equalTo(610)
        }

        [rateView, contactView,
         privacyPolicyView, usagePolicyView,].forEach { label in
            label.snp.makeConstraints { make in
                make.height.equalTo(81)
            }
        }

        upgradeView.snp.makeConstraints { make in
            make.height.equalTo(163)
        }
        
        tokensView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview().inset(16)
            make.height.equalTo(52)
        }

        notificationsView.snp.makeConstraints { make in
            make.height.equalTo(63)
        }
    }
}

// MARK: - NotificationSettingsViewViewDelegate
extension SettingsViewController: NotificationSettingsViewViewDelegate {
    func didTapNotificationView(switchValue: Bool) {
        print("notifications switchValue: \(switchValue)")
    }
}

// MARK: - UpgradeSettingsViewDelegate
extension SettingsViewController: UpgradeSettingsViewDelegate {
    func didTapUpgradeView() {
        let subscriptionVC = SubscriptionViewController(isFromOnboarding: false, isExitShown: false)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }
}

// MARK: - UpgradeSettingsViewDelegate
extension SettingsViewController: TokensViewDelegate {
    func didTapTokensView() {
        let tokensVC = TokenViewController()
        tokensVC.modalPresentationStyle = .fullScreen
        present(tokensVC, animated: true, completion: nil)
    }
}

// MARK: - RateSettingsViewDelegate
extension SettingsViewController: RateSettingsViewDelegate {
    func didTapRateView() {
        DispatchQueue.main.async {
            guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6739500119?action=write-review") else {
                return
            }

            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                print("Unable to open App Store")
            }
        }
    }
}

// MARK: - ContactSettingsViewDelegate
extension SettingsViewController: ContactSettingsViewDelegate {
    func didTapContactView() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Error", message: "Mail services are not available", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setToRecipients(["erbolatttsaliev12@yandex.kz"])
        mailComposeVC.setSubject("Support Request")
        let userId = Apphud.userID()
        let messageBody = """
        Please describe your issue here.

        User ID: \(userId)
        """
        mailComposeVC.setMessageBody(messageBody, isHTML: false)
        mailComposeVC.mailComposeDelegate = self

        present(mailComposeVC, animated: true, completion: nil)
    }
}

// MARK: - PrivacySettingsViewDelegate
extension SettingsViewController: PrivacySettingsViewDelegate {
    func didTapPrivacyView() {
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

// MARK: - UsageSettingsViewDelegate
extension SettingsViewController: UsageSettingsViewDelegate {
    func didTapUsageView() {
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

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - SKPaymentQueueDelegate
extension SettingsViewController: SKPaymentQueueDelegate {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        let alert = UIAlertController(title: "Restore Purchases", message: "Your purchases have been restored.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        let alert = UIAlertController(title: "Error", message: "There was an error restoring your purchases. Please try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
