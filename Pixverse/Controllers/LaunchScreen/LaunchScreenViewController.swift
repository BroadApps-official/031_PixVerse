import SnapKit
import UIKit

final class LaunchScreenViewController: UIViewController {
    private let loadingLabel = UILabel()
    private let loadingIndicatorView = UIView()
    private let maskLayer = CALayer()

    private let mainImageView = UIImageView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.bg
        mainImageView.image = UIImage(named: "launch_image")

        loadingLabel.do { make in
            make.textColor = UIColor.text
            make.textAlignment = .center
            make.font = UIFont.CustomFont.bodyRegular
        }

        loadingIndicatorView.do { make in
            make.backgroundColor = UIColor.colorsSeparator
            make.layer.cornerRadius = 5
            make.masksToBounds = true
        }

        maskLayer.do { make in
            make.backgroundColor = UIColor.colorsPrimary.cgColor
            make.cornerRadius = 5
            make.masksToBounds = true
        }

        view.addSubviews(loadingLabel, mainImageView, loadingIndicatorView)
        loadingIndicatorView.layer.addSublayer(maskLayer)

        mainImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIScreen.main.bounds.height * (219.0 / 844.0))
            make.centerX.equalToSuperview()
        }

        loadingLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-UIScreen.main.bounds.height * (167.0 / 844.0))
            make.height.equalTo(23)
        }

        loadingIndicatorView.snp.makeConstraints { make in
            make.bottom.equalTo(loadingLabel.snp.top).offset(-14)
            make.height.equalTo(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(204.5 / 390.0)
        }

        var currentPercentage = 0
        Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { timer in
            currentPercentage += 1
            self.loadingLabel.text = "Loading \(currentPercentage)%"
            self.updateMaskLayerWidth(percentage: CGFloat(currentPercentage))
            if currentPercentage >= 100 {
                timer.invalidate()
            }
        }
    }

    private func updateMaskLayerWidth(percentage: CGFloat) {
        let width = loadingIndicatorView.frame.width * (percentage / 100)
        maskLayer.frame = CGRect(x: 0, y: 0, width: width, height: loadingIndicatorView.frame.height)
    }
}
