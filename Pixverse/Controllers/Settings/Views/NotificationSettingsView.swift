import SnapKit
import UIKit

protocol NotificationSettingsViewViewDelegate: AnyObject {
    func didTapNotificationView(switchValue: Bool)
}

final class NotificationSettingsView: UIControl {
    weak var delegate: NotificationSettingsViewViewDelegate?

    private let buttonBackgroundView = UIButton(type: .system)
    private let titleLabel = UILabel()
    private let switchControl = UISwitch()

    private var observation: NSKeyValueObservation?

    // MARK: - Init

    init(delegate: NotificationSettingsViewViewDelegate) {
        self.delegate = delegate

        super.init(frame: .zero)
        drawSelf()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Draw

    private func drawSelf() {
        buttonBackgroundView.backgroundColor = .white.withAlphaComponent(0.05)
        buttonBackgroundView.layer.cornerRadius = 16

        observation = buttonBackgroundView.observe(\.isHighlighted, options: [.old, .new], changeHandler: { [weak self] _, change in
            guard let self, let oldValue = change.oldValue, let newValue = change.newValue else {
                return
            }
            guard oldValue != newValue else { return }

            titleLabel.textColor = newValue ? .white.withAlphaComponent(0.7) : .white
        })

        buttonBackgroundView.isUserInteractionEnabled = true

        titleLabel.do { make in
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.title3Semobold
            make.text = L.notifications
        }

        switchControl.do { make in
            make.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
            make.onTintColor = UIColor(hex: "#30D158")
            make.thumbTintColor = UIColor(hex: "#E8E8E8")
            make.backgroundColor = .clear
            make.layer.cornerRadius = 32
        }

        addSubviews(buttonBackgroundView)
        buttonBackgroundView.addSubviews(titleLabel, switchControl)

        buttonBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        switchControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
        }

        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
    }

    // MARK: - Actions
    @objc private func switchValueChanged() {
        let value = switchControl.isOn

        delegate?.didTapNotificationView(switchValue: value)
    }
}
