import Lottie
import UIKit

final class GenerationTimeViewController: UIViewController {
    // MARK: - Properties

    private let firstLabel = UILabel()
    private let secondLabel = UILabel()
    private let backButton = UIButton(type: .system)
    let animation = LottieAnimation.named("LottieAnimation")
    private var animationView = LottieAnimationView()

    private let loadingIndicatorView = UIView()
    private let maskLayer = CALayer()

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = false

        setupBackButton()
        view.backgroundColor = UIColor.bg

        drawSelf()
        configureConstraints()
        animationView.play()
    }

    private func drawSelf() {
        firstLabel.do { make in
            make.text = L.videoGeneration
            make.font = UIFont.CustomFont.title3Semobold
            make.textColor = UIColor.labelsPrimary
            make.textAlignment = .center
        }

        secondLabel.do { make in
            make.text = L.videoGenerationTime
            make.font = UIFont.CustomFont.footnoteRegular
            make.textColor = UIColor.labelsSecondary
            make.textAlignment = .center
            make.numberOfLines = 0
        }

        animationView = LottieAnimationView(animation: animation)
        animationView.frame = view.frame
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.0

        loadingIndicatorView.do { make in
            make.backgroundColor = UIColor.bgQuaternary
            make.layer.cornerRadius = 3
            make.masksToBounds = true
        }

        maskLayer.do { make in
            make.backgroundColor = UIColor.colorsPrimary.cgColor
            make.cornerRadius = 3
            make.masksToBounds = true
        }

        view.addSubviews(firstLabel, secondLabel, animationView, loadingIndicatorView)
        loadingIndicatorView.layer.addSublayer(maskLayer)
    }

    private func configureConstraints() {
        animationView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height * (142.0 / 844.0))
            make.size.equalTo(263)
            make.centerX.equalToSuperview()
        }

        firstLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom)
            make.centerX.equalToSuperview()
        }

        secondLabel.snp.makeConstraints { make in
            make.top.equalTo(firstLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalTo(260)
        }

        loadingIndicatorView.snp.makeConstraints { make in
            make.bottom.equalToSuperview().offset(-UIScreen.main.bounds.height * (181.0 / 844.0))
            make.height.equalTo(6)
            make.centerX.equalToSuperview()
            make.width.equalTo(160)
        }

        var currentPercentage = 0
        let maxPercentage = 600

        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            currentPercentage += 1
            self.updateMaskLayerWidth(percentage: CGFloat(currentPercentage))
            if currentPercentage >= maxPercentage {
                timer.invalidate()
                self.didTapCloseButton()
            }
        }
    }

    private func setupBackButton() {
        backButton.do { make in
            make.setTitle(L.cancel, for: .normal)
            make.tintColor = .white
            make.addTarget(self, action: #selector(didTapCloseButton), for: .touchUpInside)
        }

        let backBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.leftBarButtonItem = backBarButtonItem
    }

    private func updateMaskLayerWidth(percentage: CGFloat) {
        let maxPercentage = 600
        let width = loadingIndicatorView.frame.width * (percentage / CGFloat(maxPercentage))
        maskLayer.frame = CGRect(x: 0, y: 0, width: width, height: loadingIndicatorView.frame.height)
    }

    @objc private func didTapCloseButton() {
        dismiss(animated: true)
    }
}
