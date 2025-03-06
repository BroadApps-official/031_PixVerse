import UIKit

protocol HeaderViewDelegate: AnyObject {
    func didTapHeaderButton(sectionIndex: Int)
}

class HeaderView: UICollectionReusableView {
    static let identifier = "HeaderView"
    weak var delegate: HeaderViewDelegate?
    private var sectionIndex: Int = 0
    
    private let titleLabel = UILabel()
    private let headerButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func drawSelf() {
        headerButton.do { make in
            make.setImage(UIImage(named: "token_arrow_image")?.withRenderingMode(.alwaysOriginal), for: .normal)
            make.addTarget(self, action: #selector(headerTapped), for: .touchUpInside)
        }
        
        titleLabel.do { make in
            make.font = UIFont.CustomFont.title3Semobold
            make.textColor = .white
            make.textAlignment = .left
        }
        
        addSubviews(titleLabel, headerButton)
        
        titleLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalToSuperview().offset(19.5)
        }
        
        headerButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.centerY.equalTo(titleLabel.snp.centerY)
            make.size.equalTo(32)
        }
    }
    
    @objc private func headerTapped() {
        delegate?.didTapHeaderButton(sectionIndex: sectionIndex)
    }

    func configure(with title: String, sectionIndex: Int) {
        self.sectionIndex = sectionIndex
        titleLabel.text = title
    }
}
