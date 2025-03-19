import AVKit
import UIKit

final class OnboardingPageViewController: UIViewController {
    // MARK: - Types

    enum Page {
        case video, effects, save, rate, notification
    }

    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    private let imageView = UIImageView()
    private let shadowImageView = UIImageView()

    private let videoView = UIView()
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?

    // MARK: - Properties info

    private let page: Page

    // MARK: - Init

    init(page: Page) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.bgPrimary

        switch page {
        case .video: drawVideo()
        case .effects: drawEffects()
        case .save: drawSave()
        case .rate: drawRate()
        case .notification: drawNotification()
        }
    }

    // MARK: - Draw

    private func drawVideo() {
        imageView.image = UIImage(named: "onb_video_image")
        shadowImageView.image = UIImage(named: "onb_shadow_image")

        mainLabel.do { make in
            make.text = L.videoLabel.uppercased()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.onbFont
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.videoSublabel
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, shadowImageView, subLabel, mainLabel)

        shadowImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (407.0 / 844.0))
        }

        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (635.0 / 844.0))
        }

        mainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subLabel.snp.top).offset(-12)
        }

        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-141)
        }
    }

    private func drawEffects() {
        imageView.image = UIImage(named: "onb_effects_image")
        shadowImageView.image = UIImage(named: "onb_shadow_image")

        mainLabel.do { make in
            make.text = L.effectsLabel.uppercased()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.onbFont
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.effectsSublabel
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, shadowImageView, subLabel, mainLabel)

        shadowImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (407.0 / 844.0))
        }

        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subLabel.snp.top).offset(-12)
        }

        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-141)
        }
    }

    private func drawSave() {
        imageView.image = UIImage(named: "onb_save_image")
        shadowImageView.image = UIImage(named: "onb_shadow_image")

        mainLabel.do { make in
            make.text = L.saveLabel.uppercased()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.onbFont
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.saveSublabel
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, shadowImageView, subLabel, mainLabel)

        shadowImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (407.0 / 844.0))
        }

        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subLabel.snp.top).offset(-12)
        }

        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-141)
        }
    }

    private func drawRate() {
        imageView.image = UIImage(named: "onb_rate_image")
        shadowImageView.image = UIImage(named: "onb_shadow_image")

        mainLabel.do { make in
            make.text = L.rateLabel.uppercased()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.onbFont
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.rateSublabel
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, shadowImageView, subLabel, mainLabel)

        shadowImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (407.0 / 844.0))
        }

        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subLabel.snp.top).offset(-12)
        }

        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-141)
        }
    }

    private func drawNotification() {
        imageView.image = UIImage(named: "onb_notification_image")
        shadowImageView.image = UIImage(named: "onb_shadow_image")

        mainLabel.do { make in
            make.text = L.notificationLabel.uppercased()
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.onbFont
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        subLabel.do { make in
            make.text = L.notificationSublabel
            make.textColor = UIColor.labelsPrimary
            make.font = UIFont.CustomFont.calloutRegular
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        view.addSubviews(imageView, shadowImageView, subLabel, mainLabel)

        shadowImageView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(UIScreen.main.bounds.height * (407.0 / 844.0))
        }

        imageView.snp.makeConstraints { make in
            make.leading.trailing.top.bottom.equalToSuperview()
        }

        mainLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(subLabel.snp.top).offset(-12)
        }

        subLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-141)
        }
    }
}
