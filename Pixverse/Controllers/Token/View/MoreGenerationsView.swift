import SnapKit
import UIKit

final class MoreGenerationsView: UIControl {
    private let mainLabel = UILabel()
    private let tokenLabel = UILabel()
    private let tokenValueLabel = UILabel()
    private let buyLabel = UILabel()
    private let tokenStackView = UIStackView()

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

        mainLabel.do { make in
            make.text = L.moreGenerations.uppercased()
            make.font = .systemFont(ofSize: 28, weight: .bold)
            make.textColor = .white
            make.textAlignment = .center
            make.numberOfLines = 0
        }
        
        tokenLabel.do { make in
            make.text = L.myTokens
            make.font = UIFont.CustomFont.calloutRegular
            make.textColor = UIColor.text
            make.textAlignment = .center
        }       
        
        tokenValueLabel.do { make in
            make.text = ""
            make.font = UIFont.CustomFont.calloutRegular
            make.textColor = UIColor.colorsPrimary
            make.textAlignment = .center
        }       
        
        buyLabel.do { make in
            make.text = L.buyTokens
            make.font = UIFont.CustomFont.footnoteRegular
            make.textColor = .white.withAlphaComponent(0.5)
            make.textAlignment = .center
        }
        
        tokenStackView.do { make in
            make.axis = .horizontal
            make.spacing = 5
            make.alignment = .center
            make.distribution = .fill
        }

        tokenStackView.addArrangedSubviews([tokenLabel, tokenValueLabel])
        addSubviews(mainLabel, tokenStackView, buyLabel)
    }

    private func setupConstraints() {
        mainLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        tokenStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mainLabel.snp.bottom).offset(12)
        }
        
        buyLabel.snp.makeConstraints { make in
            make.top.equalTo(tokenStackView.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
    }
    
    func updateTokenCount(count: Int) {
        tokenValueLabel.text = "\(count * 10)"
    }
}
