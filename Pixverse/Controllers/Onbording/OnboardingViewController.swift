import UIKit
import StoreKit

final class OnboardingViewController: UIViewController {
    // MARK: - Life cycle

    private let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private var pagesViewControllers = [UIViewController]()

    private var currentPage: OnboardingPageViewController.Page = .animation
    private var trackButtonTapsCount = 0

    private lazy var first = OnboardingPageViewController(page: .animation)
    private lazy var second = OnboardingPageViewController(page: .video)
    private lazy var third = OnboardingPageViewController(page: .effects)
    private lazy var fourth = OnboardingPageViewController(page: .save)
    private lazy var fifth = OnboardingPageViewController(page: .rate)
    private lazy var sixth = OnboardingPageViewController(page: .notification)

    private let continueButton = GeneralButton()

    var isFirstTap = true

    private let firstCircleView = UIView()
    private let secondCircleView = UIView()
    private let thirdCircleView = UIView()
    private let fourthCircleView = UIView()
    private let fifthCircleView = UIView()
    private let sixthCircleView = UIView()
    private let circleStackView = UIStackView()

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        pagesViewControllers += [first, second, third, fourth, fifth, sixth]
        drawSelf()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func drawSelf() {
        view.backgroundColor = .white

        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)

        addChildController(pageViewController, inside: view)
        if let pageFirst = pagesViewControllers.first {
            pageViewController.setViewControllers([pageFirst], direction: .forward, animated: false)
        }
        pageViewController.dataSource = self

        for subview in pageViewController.view.subviews {
            if let subview = subview as? UIScrollView {
                subview.isScrollEnabled = false
                break
            }
        }

        firstCircleView.backgroundColor = .white
        secondCircleView.backgroundColor = .white.withAlphaComponent(0.5)
        thirdCircleView.backgroundColor = .white.withAlphaComponent(0.5)
        fourthCircleView.backgroundColor = .white.withAlphaComponent(0.5)
        fifthCircleView.backgroundColor = .white.withAlphaComponent(0.5)
        sixthCircleView.backgroundColor = .white.withAlphaComponent(0.5)

        [firstCircleView, secondCircleView, thirdCircleView,
         fourthCircleView, fifthCircleView, sixthCircleView].forEach { view in
            view.do { make in
                make.layer.cornerRadius = 4
            }
        }

        circleStackView.do { make in
            make.axis = .horizontal
            make.spacing = 8
            make.distribution = .fill
        }

        circleStackView.addArrangedSubviews(
            [firstCircleView, secondCircleView, thirdCircleView,
             fourthCircleView, fifthCircleView, sixthCircleView]
        )
        view.addSubviews(continueButton, circleStackView)

        [secondCircleView, thirdCircleView,
         fourthCircleView, fifthCircleView, sixthCircleView].forEach { view in
            view.snp.makeConstraints { make in
                make.size.equalTo(8)
            }
        }

        firstCircleView.snp.makeConstraints { make in
            make.width.equalTo(25)
            make.height.equalTo(8)
        }

        continueButton.snp.makeConstraints { make in
            make.bottom.equalTo(circleStackView.snp.top).offset(-16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(58)
        }

        circleStackView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-26)
            make.width.equalTo(105)
            make.height.equalTo(8)
        }
    }
}

// MARK: - OnboardingPageViewControllerDelegate
extension OnboardingViewController {
    @objc private func didTapContinueButton() {
        switch currentPage {
        case .animation:
            pageViewController.setViewControllers([second], direction: .forward, animated: true)
            currentPage = .video
            circleStackView.addArrangedSubviews(
                [secondCircleView, firstCircleView, thirdCircleView,
                 fourthCircleView, fifthCircleView, sixthCircleView]
            )
        case .video:
            pageViewController.setViewControllers([third], direction: .forward, animated: true)
            currentPage = .effects
            circleStackView.addArrangedSubviews(
                [secondCircleView, thirdCircleView, firstCircleView,
                 fourthCircleView, fifthCircleView, sixthCircleView]
            )
        case .effects:
            pageViewController.setViewControllers([fourth], direction: .forward, animated: true)
            currentPage = .save
            circleStackView.addArrangedSubviews(
                [secondCircleView, thirdCircleView, fourthCircleView,
                 firstCircleView, fifthCircleView, sixthCircleView]
            )
        case .save:
            pageViewController.setViewControllers([fifth], direction: .forward, animated: true)
            currentPage = .rate
            circleStackView.addArrangedSubviews(
                [secondCircleView, thirdCircleView, fourthCircleView,
                 fifthCircleView, firstCircleView, sixthCircleView]
            )
        case .rate:
            DispatchQueue.main.async {
                if #available(iOS 15.0, *) {
                    if let scene = self.view.window?.windowScene {
                        SKStoreReviewController.requestReview(in: scene)
                    }
                }
            }

            pageViewController.setViewControllers([sixth], direction: .forward, animated: true)
            currentPage = .notification
            circleStackView.addArrangedSubviews(
                [secondCircleView, thirdCircleView, fourthCircleView,
                 fifthCircleView, sixthCircleView, firstCircleView]
            )

        case .notification:
            UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, _ in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.openSubVC()
                }
            }
        }
    }

    @objc private func openSubVC() {
        let subscriptionVC = SubscriptionViewController(isFromOnboarding: true, isExitShown: true)
        subscriptionVC.modalPresentationStyle = .fullScreen
        present(subscriptionVC, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pagesViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        return pagesViewControllers[index + 1]
    }
}

extension UIViewController {
    func addChildController(_ childViewController: UIViewController, inside containerView: UIView?) {
        childViewController.willMove(toParent: self)
        containerView?.addSubview(childViewController.view)

        addChild(childViewController)

        childViewController.didMove(toParent: self)
    }
}
