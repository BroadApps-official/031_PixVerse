import SnapKit
import UIKit

protocol TokensViewDelegate: AnyObject {
    func didTapTokensView()
}

final class TokensView: UIControl {
    weak var delegate: TokensViewDelegate?

    private let buttonBackgroundView = UIButton(type: .system)
    private let arrowImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subLabel = UILabel()

    private var observation: NSKeyValueObservation?

    // MARK: - Init

    init(delegate: TokensViewDelegate) {
        self.delegate = delegate

        super.init(frame: .zero)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw

    private func drawSelf() {
        buttonBackgroundView.addTarget(self, action: #selector(didTapView), for: .touchUpInside)
        buttonBackgroundView.backgroundColor = .white.withAlphaComponent(0.05)
        buttonBackgroundView.layer.cornerRadius = 16

        observation = buttonBackgroundView.observe(\.isHighlighted, options: [.old, .new], changeHandler: { [weak self] _, change in
            guard let self, let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            guard oldValue != newValue else { return }

            titleLabel.textColor = newValue ? .white.withAlphaComponent(0.7) : .white
        })

        arrowImageView.image = UIImage(named: "token_arrow_image")
        arrowImageView.contentMode = .scaleAspectFit
        buttonBackgroundView.isUserInteractionEnabled = true

        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutSemibold
            make.text = L.tokensGenerate
        }

        subLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutSemibold
            make.text = ""
        }

        addSubviews(buttonBackgroundView)
        buttonBackgroundView.addSubview(titleLabel)
        buttonBackgroundView.addSubview(subLabel)
        buttonBackgroundView.addSubview(arrowImageView)

        buttonBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        subLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
        }
        
        arrowImageView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(8)
            make.centerY.equalToSuperview()
        }
    }
    
    func tokensValue(value: Int) {
        subLabel.text = "\(value * 10) / 2000"
    }

    // MARK: - Actions

    @objc private func didTapView() {
        delegate?.didTapTokensView()
    }
}
