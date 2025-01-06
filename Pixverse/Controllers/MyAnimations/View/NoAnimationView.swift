import SnapKit
import UIKit

protocol NoAnimationViewDelegate: AnyObject {
    func createButtonTapped()
}

final class NoAnimationView: UIControl {
    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let createButton = GeneralButton()
    weak var delegate: NoAnimationViewDelegate?

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

        firstLabel.do { make in
            make.text = L.emptyPage
            make.font = UIFont.CustomFont.title2Bold
            make.textAlignment = .center
            make.textColor = UIColor.labelsPrimary
        }

        secondLabel.do { make in
            make.text = L.emptyPageSublabel
            make.font = UIFont.CustomFont.bodyRegular
            make.textAlignment = .center
            make.textColor = UIColor.labelsSecondary
            make.numberOfLines = 0
        }

        createButton.do { make in
            make.createMode()
            let tapSelectGesture = UITapGestureRecognizer(target: self, action: #selector(createButtonTapped))
            make.addGestureRecognizer(tapSelectGesture)
        }

        addSubviews(firstLabel, secondLabel, createButton)
    }

    private func setupConstraints() {
        firstLabel.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }

        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(215)
        }

        createButton.snp.makeConstraints { make in
            make.top.equalTo(secondLabel.snp.bottom).offset(38)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(46)
            make.width.equalTo(154)
        }
    }

    @objc private func createButtonTapped() {
        delegate?.createButtonTapped()
    }
}
