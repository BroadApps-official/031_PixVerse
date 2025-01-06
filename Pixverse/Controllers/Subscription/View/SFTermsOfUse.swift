import UIKit

protocol SFTermsOfUseDelegate: AnyObject {
    func termsOfUseTapped()
}

class SFTermsOfUse: UILabel {
    weak var delegate: SFTermsOfUseDelegate?
    var mainColor: UIColor = UIColor.labelsQuaternary {
        didSet {
            setupText()
        }
    }

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

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTermsOfUse))
        addGestureRecognizer(tapGesture)
    }

    private func setupText() {
        let text = L.termsOfUse
        let attributedString = NSMutableAttributedString(string: text)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.CustomFont.caption2Regular,
            .foregroundColor: mainColor
        ]

        attributedString.addAttributes(attributes, range: NSRange(location: 0, length: text.count))

        attributedText = attributedString
    }

    // MARK: - Actions

    @objc private func didTapTermsOfUse() {
        alpha = 0.5

        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.alpha = 1.0
        }

        delegate?.termsOfUseTapped()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
