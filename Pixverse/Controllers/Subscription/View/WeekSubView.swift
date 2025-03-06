import UIKit

protocol WeekSubViewDelegate: AnyObject {
    func didTapWeekSubView(isOn: Bool)
}

final class WeekSubView: UIControl {
    override var isSelected: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let underPriceLabel = UILabel()
    private let priceStackView = UIStackView()
    private let containerView = UIView()
    private let circleImageView = UIImageView()

    weak var delegate: WeekSubViewDelegate?

    var dynamicTitle: String?
    var dynamicPrice: String?

    private let weekLabel = UILabel()
    private let weekValueLabel = UILabel()

    init() {
        super.init(frame: .zero)
        setupView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        addGestureRecognizer(tapGesture)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        backgroundColor = .clear
        containerView.isUserInteractionEnabled = false
        circleImageView.image = UIImage(named: "sub_circle_empty")

        weekLabel.do { make in
            make.text = "/ week"
            make.textAlignment = .right
            make.font = UIFont.CustomFont.caption1Regular
            make.textColor = UIColor.labelsTertiary
        }

        containerView.do { make in
            make.backgroundColor = UIColor.bgTertiary
            make.layer.cornerRadius = 10
        }

        titleLabel.do { make in
            make.text = L.weekly
            make.textAlignment = .center
            make.font = UIFont.CustomFont.bodyRegular
            make.textColor = UIColor.labelsPrimary
        }

        priceLabel.do { make in
            make.text = "$14.99"
            make.textAlignment = .center
            make.font = UIFont.CustomFont.bodyEmphasized
            make.textColor = UIColor.labelsPrimary
        }

        underPriceLabel.do { make in
            make.text = "per week"
            make.textColor = UIColor.labelsTertiary
            make.font = UIFont.CustomFont.caption1Regular
            make.textAlignment = .center
        }

        priceStackView.do { make in
            make.axis = .vertical
            make.spacing = 2
            make.alignment = .trailing
            make.distribution = .fill
        }

        priceStackView.addArrangedSubviews([priceLabel, underPriceLabel])
        addSubviews(containerView, circleImageView, titleLabel, priceStackView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        circleImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(32)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(circleImageView.snp.trailing).offset(8)
        }

        priceStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }
    }

    private func configureAppearance() {
        if isSelected {
            circleImageView.image = UIImage(named: "sub_circle_fill")
            containerView.layer.borderColor = UIColor.colorsSecondary.cgColor
            containerView.layer.borderWidth = 1
        } else {
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0
            circleImageView.image = UIImage(named: "sub_circle_empty")
        }
    }

    func updateDetails(title: String, price: String) {
        dynamicTitle = title
        dynamicPrice = price

        titleLabel.text = dynamicTitle ?? L.weekly
        priceLabel.text = dynamicPrice ?? "$14.99"
        underPriceLabel.text = "per week"
    }

    // MARK: - Actions

    @objc private func didTapView() {
        guard !isSelected else { return }
        isSelected.toggle()
        delegate?.didTapWeekSubView(isOn: isSelected)
    }
}
