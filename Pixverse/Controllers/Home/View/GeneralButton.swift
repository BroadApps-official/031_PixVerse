import UIKit

final class GeneralButton: UIControl {
    // MARK: - Properties

    override var isHighlighted: Bool {
        didSet {
            configureAppearance()
        }
    }

    private let titleLabel = UILabel()
    let buttonContainer = UIView()
    
    private let stackView = UIStackView()
    private let createImageview = UIImageView()
    private let shareImageview = UIImageView()
    private let selectImageview = UIImageView()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private methods

    private func drawSelf() {
        createImageview.image = UIImage(named: "video_create_icon")
        shareImageview.image = UIImage(named: "video_share_icon")
        selectImageview.image = UIImage(named: "main_select_icon")
        
        buttonContainer.do { make in
            make.backgroundColor = UIColor.colorsPrimary
            make.layer.cornerRadius = 16
            make.isUserInteractionEnabled = false
        }

        titleLabel.do { make in
            make.text = L.next
            make.textColor = UIColor.text
            make.font = UIFont.CustomFont.bodyEmphasized
            make.isUserInteractionEnabled = false
        }
        
        stackView.do { make in
            make.axis = .horizontal
            make.alignment = .center
            make.spacing = 10
            make.distribution = .fillProportionally
            make.isUserInteractionEnabled = false
        }

        buttonContainer.addSubview(titleLabel)
        addSubviews(buttonContainer)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        buttonContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func configureAppearance() {
        alpha = isHighlighted ? 0.7 : 1
    }

    func setTitle(to title: String) {
        titleLabel.text = title
    }

    func setTextColor(_ color: UIColor) {
        titleLabel.textColor = color
    }

    func setBackgroundColor(_ color: UIColor) {
        buttonContainer.backgroundColor = color
    }
    
    func createMode() {
        titleLabel.removeFromSuperview()
        titleLabel.text = L.create
        stackView.addArrangedSubviews([titleLabel, createImageview])
        addSubviews(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }    
    
    func shareMode() {
        titleLabel.removeFromSuperview()
        titleLabel.text = L.previewShare
        stackView.addArrangedSubviews([titleLabel, shareImageview])
        addSubviews(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func selectMode() {
        titleLabel.removeFromSuperview()
        titleLabel.text = L.selectEffect
        stackView.addArrangedSubviews([titleLabel, selectImageview])
        addSubviews(stackView)
        
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
