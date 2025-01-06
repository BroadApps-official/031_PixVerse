
import SnapKit
import UIKit

final class SubscribeView: UIControl {
    private let mainLabel = UILabel()

    private let firstView = UILabel()
    private let secondView = UILabel()
    private let thirdView = UILabel()

    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let thirdLabel = UILabel()

    private let firstImageView = UIImageView()
    private let secondImageView = UIImageView()
    private let thirdImageView = UIImageView()

    private let firstStackView = UIStackView()
    private let secondStackView = UIStackView()
    private let thirdStackView = UIStackView()
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
        firstImageView.image = UIImage(named: "sub_first_image")
        secondImageView.image = UIImage(named: "sub_second_image")
        thirdImageView.image = UIImage(named: "sub_third_image")

        [firstView, secondView, thirdView].forEach { view in
            view.do { make in
                make.layer.cornerRadius = 10
                make.layer.borderColor = UIColor.colorsSeparator.cgColor
                make.layer.borderWidth = 1
            }
        }

        mainLabel.do { make in
            make.text = L.subscribe
            make.font = UIFont.CustomFont.title1Bold
            make.textColor = UIColor.text
            make.textAlignment = .center
        }

        [firstLabel, secondLabel, thirdLabel].forEach { label in
            label.do { make in
                make.font = UIFont.CustomFont.subheadlineRegular
                make.textColor = .white.withAlphaComponent(0.7)
                make.textAlignment = .left
                make.numberOfLines = 0
            }
        }

        firstLabel.text = L.exclusiveEffects
        secondLabel.text = L.fullAccess
        thirdLabel.text = L.earlyAccess

        [firstStackView, secondStackView, thirdStackView].forEach { stackView in
            stackView.do { make in
                make.axis = .horizontal
                make.spacing = 18
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
        firstView.addSubviews(firstStackView)
        secondView.addSubviews(secondStackView)
        thirdView.addSubviews(thirdStackView)
        mainStackView.addArrangedSubviews([firstView, secondView, thirdView])

        addSubviews(mainLabel, mainStackView)
    }

    private func setupConstraints() {
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(6)
        }

        mainStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(mainLabel.snp.bottom).offset(16)
        }

        [firstImageView, secondImageView, thirdImageView].forEach { imageView in
            imageView.snp.makeConstraints { make in
                make.size.equalTo(24)
            }
        }

        [firstStackView, secondStackView, thirdStackView].forEach { stackView in
            stackView.snp.makeConstraints { make in
                make.top.bottom.equalToSuperview().inset(8)
                make.leading.trailing.equalToSuperview().inset(24)
            }
        }

        [firstView, secondView].forEach { view in
            view.snp.makeConstraints { make in
                make.width.equalToSuperview()
                make.height.equalTo(44)
            }
        }

        thirdView.snp.makeConstraints { make in
            make.width.equalToSuperview()
            make.height.equalTo(56)
        }
    }
}
