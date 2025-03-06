import UIKit

class TokenCell: UICollectionViewCell {
    static let identifier = "TokenCell"
    
    private let valueTokenLabel = UILabel()
    private let tokenLabel = UILabel()
    private let priceLabel = UILabel()
    
    private let saveLabel = UILabel()
    private let saveImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = UIColor.bgTertiary
        contentView.layer.cornerRadius = 10
        saveImageView.image = UIImage(named: "sub_save_container")
        
        tokenLabel.do { make in
            make.text = L.tokens
            make.font = UIFont.CustomFont.bodyRegular
            make.textColor = .white.withAlphaComponent(0.5)
            make.textAlignment = .left
        }
        
        [valueTokenLabel, priceLabel].forEach { view in
            view.do { make in
                make.font = UIFont.CustomFont.bodySemibold
                make.textColor = .white
            }
        }
        
        saveLabel.do { make in
            make.text = "SAVE 80%"
            make.textAlignment = .center
            make.font = UIFont.CustomFont.caption2Emphasized
            make.textColor = UIColor.labelsPrimary
        }
        
        saveImageView.addSubviews(saveLabel)
        contentView.addSubview(valueTokenLabel)
        contentView.addSubview(tokenLabel)
        contentView.addSubview(priceLabel)
        contentView.addSubview(saveImageView)
        
        valueTokenLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        tokenLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(valueTokenLabel.snp.trailing).offset(4)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
        }
        
        saveImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(priceLabel.snp.leading).offset(-6)
        }

        saveLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func configure(tokens: String, price: String, discount: String?, isFirst: Bool) {
        valueTokenLabel.text = tokens
        priceLabel.text = price
        saveLabel.text = discount != nil ? "SAVE \(discount!)%" : "SAVE 80%"
        saveImageView.isHidden = isFirst ? true : false
    }
}
