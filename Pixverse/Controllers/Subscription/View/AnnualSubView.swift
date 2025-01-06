import UIKit

protocol AnnualSubViewDelegate: AnyObject {
    func didTapAnnualSubView(isOn: Bool)
}

final class AnnualSubView: UIControl {
    override var isSelected: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let underPriceLabel = UILabel()
    private let underTitleLabel = UILabel()
    private let priceStackView = UIStackView()
    private let titleStackView = UIStackView()
    private let containerView = UIView()

    private let saveLabel = UILabel()
    private let saveImageView = UIImageView()

    private let circleImageView = UIImageView()

    weak var delegate: AnnualSubViewDelegate?

    var dynamicTitle: String?
    var dynamicPrice: String?

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
        saveImageView.image = UIImage(named: "sub_save_container")

        containerView.do { make in
            make.backgroundColor = UIColor.bgTertiary
            make.layer.cornerRadius = 10
        }

        saveLabel.do { make in
            make.text = "SAVE 80%"
            make.textAlignment = .center
            make.font = UIFont.CustomFont.caption2Emphasized
            make.textColor = UIColor.labelsPrimary
        }

        titleLabel.do { make in
            make.text = L.annual
            make.textAlignment = .center
            make.font = UIFont.CustomFont.bodyRegular
            make.textColor = UIColor.labelsPrimary
        }

        underTitleLabel.do { make in
            make.text = "$0.87 per week"
            make.textColor = UIColor.labelsSecondary
            make.font = UIFont.CustomFont.caption1Regular
            make.textAlignment = .center
        }

        priceLabel.do { make in
            make.font = UIFont.CustomFont.bodyEmphasized
            make.text = "$39.99"
            make.textAlignment = .center
            make.textColor = UIColor.labelsPrimary
        }

        underPriceLabel.do { make in
            make.text = "per year"
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

        titleStackView.do { make in
            make.axis = .vertical
            make.spacing = 2
            make.alignment = .leading
            make.distribution = .fill
        }
        
        titleStackView.addArrangedSubviews([titleLabel, underTitleLabel])
        priceStackView.addArrangedSubviews([priceLabel, underPriceLabel])
        saveImageView.addSubviews(saveLabel)
        addSubviews(containerView, circleImageView, titleStackView, priceStackView, saveImageView)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        circleImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.size.equalTo(32)
        }

        titleStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(circleImageView.snp.trailing).offset(8)
        }

        priceStackView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.centerY.equalToSuperview()
        }

        saveImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8.5)
            make.trailing.equalTo(priceLabel.snp.leading).offset(-6)
        }

        saveLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    private func configureAppearance() {
        if isSelected {
            containerView.layer.borderColor = UIColor.colorsSecondary.cgColor
            containerView.layer.borderWidth = 1
            circleImageView.image = UIImage(named: "sub_circle_fill")
        } else {
            containerView.layer.borderColor = UIColor.clear.cgColor
            containerView.layer.borderWidth = 0
            circleImageView.image = UIImage(named: "sub_circle_empty")
        }
    }

    func updateDetails(title: String, price: String) {
        dynamicTitle = title
        dynamicPrice = price

        titleLabel.text = dynamicTitle ?? L.annual
        priceLabel.text = dynamicPrice ?? "$39.99"
        underPriceLabel.text = "per year"
        saveLabel.text = "SAVE 80%"
    }
    
    func updateUnderTitleLabel(text: String) {
        underTitleLabel.text = text
    }

    // MARK: - Actions

    @objc private func didTapView() {
        guard !isSelected else { return }
        isSelected.toggle()
        delegate?.didTapAnnualSubView(isOn: isSelected)
    }
}
