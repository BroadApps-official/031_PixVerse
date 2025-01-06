import StoreKit
import UIKit

protocol SFRestrorePurchaseLabelDelegate: AnyObject {
    func didFailToRestorePurchases()
}

class SFRestrorePurchaseLabel: UILabel {
    var mainColor: UIColor = UIColor.labelsTertiary {
        didSet {
            setupText()
        }
    }

    private let purchaseManager = SubscriptionManager()
    weak var delegate: SFRestrorePurchaseLabelDelegate?

    init() {
        super.init(frame: .zero)
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center

        textAlignment = .center
        backgroundColor = .clear
        numberOfLines = 0
        isUserInteractionEnabled = true
        sizeToFit()
        clipsToBounds = false
        setupText()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapRestorePurchases))
        addGestureRecognizer(tapGesture)
    }

    private func setupText() {
        let text = L.restorePurchases
        let attributedString = NSMutableAttributedString(string: text)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.CustomFont.caption1Regular,
            .foregroundColor: mainColor
        ]

        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.count))

        attributedText = attributedString
    }

    // MARK: - Actions

    @objc private func didTapRestorePurchases() {
        alpha = 0.5

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1.0
        }

        purchaseManager.restorePurchase { success in
            if success {
                debugPrint("restorePurchase succeed.")
            } else {
                debugPrint("restorePurchase failed.")
                self.delegate?.didFailToRestorePurchases()
            }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
