import SnapKit
import UIKit

protocol PrivacySettingsViewDelegate: AnyObject {
    func didTapPrivacyView()
}

final class PrivacySettingsView: UIControl {
    weak var delegate: PrivacySettingsViewDelegate?
    
    private let buttonBackgroundView = UIButton(type: .system)
    private let typeImageView = UIImageView()
    private let titleLabel = UILabel()
    
    private var observation: NSKeyValueObservation?
    
    // MARK: - Init
    
    init(delegate: PrivacySettingsViewDelegate) {
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
        
        typeImageView.image = UIImage(named: "set_privacy_icon")
        typeImageView.contentMode = .scaleAspectFit
        buttonBackgroundView.isUserInteractionEnabled = true
        
        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.title3Semobold
            make.text = L.privacy
        }
        
        addSubviews(buttonBackgroundView)
        buttonBackgroundView.addSubview(titleLabel)
        buttonBackgroundView.addSubview(typeImageView)
        
        buttonBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        typeImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
        }
    }
    
    // MARK: - Actions
    
    @objc private func didTapView() {
        delegate?.didTapPrivacyView()
    }
}
