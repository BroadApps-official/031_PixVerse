import SnapKit
import UIKit

final class UnlockView: UIControl {
    private let mainLabel = UILabel()
    private let containerView = UIView()

    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()
    private let fourthLabel = UILabel()

    private let firstImageView = UIImageView()
    private let secondImageView = UIImageView()
    private let thirdImageView = UIImageView()
    private let fourthImageView = UIImageView()

    private let firstStackView = UIStackView()
    private let secondStackView = UIStackView()
    private let thirdStackView = UIStackView()
    private let fourthStackView = UIStackView()
    private let mainStackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
        setupConstraints()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func drawSelf() {
        backgroundColor = .clear
        firstImageView.image = UIImage(named: "sub_unlock_icon")
        secondImageView.image = UIImage(named: "sub_unlock_icon")
        thirdImageView.image = UIImage(named: "sub_unlock_icon")
        fourthImageView.image = UIImage(named: "sub_unlock_icon")

        containerView.do { make in
            make.backgroundColor = UIColor(hex: "#17171733").withAlphaComponent(0.2)
            make.layer.cornerRadius = 16
            make.layer.borderWidth = 1
            make.layer.borderColor = UIColor.white.withAlphaComponent(0.05).cgColor
        }

        mainLabel.do { make in
            make.text = L.unlockPremium
            make.font = UIFont.CustomFont.title1Emphasized
            make.textColor = UIColor.labelsPrimary
            make.textAlignment = .center
        }

        [firstLabel, secondLabel, thirdLabel, fourthLabel].forEach { label in
            label.do { make in
                make.font = UIFont.CustomFont.subheadlineRegular
                make.textColor = UIColor.labelsSecondary
                make.textAlignment = .left
                make.numberOfLines = 0
            }
        }

        firstLabel.text = L.get100
        secondLabel.text = L.exclusiveEffects
        thirdLabel.text = L.fullAccessNoLimits
        fourthLabel.text = L.earlyAccess

        [firstStackView, secondStackView, thirdStackView, fourthStackView].forEach { stackView in
            stackView.do { make in
                make.axis = .horizontal
                make.spacing = 0
                make.distribution = .fill
                make.alignment = .center
            }
        }

        mainStackView.do { make in
            make.axis = .vertical
            make.spacing = 10
            make.distribution = .fill
            make.alignment = .leading
        }

        firstStackView.addArrangedSubviews([firstImageView, firstLabel])
        secondStackView.addArrangedSubviews([secondImageView, secondLabel])
        thirdStackView.addArrangedSubviews([thirdImageView, thirdLabel])
        fourthStackView.addArrangedSubviews([fourthImageView, fourthLabel])
        mainStackView.addArrangedSubviews([firstStackView, secondStackView, thirdStackView, fourthStackView])
        containerView.addSubviews(mainStackView)

        addSubviews(mainLabel, containerView)
    }

    private func setupConstraints() {
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
        }

        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(mainLabel.snp.bottom).offset(10)
        }

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }

        [firstImageView, secondImageView, thirdImageView].forEach { imageView in
            imageView.snp.makeConstraints { make in
                make.size.equalTo(32)
            }
        }

        [firstStackView, secondStackView, thirdStackView].forEach { stackView in
            stackView.snp.makeConstraints { make in
                make.height.equalTo(32)
            }
        }

        fourthStackView.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
    }
}
