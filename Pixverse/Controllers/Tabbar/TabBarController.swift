import UIKit
import SnapKit

final class TabBarController: UITabBarController {
    static let shared = TabBarController()

    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()

        let homeVC = UINavigationController(
            rootViewController: HomeViewController()
        )
        let animationsVC = UINavigationController(
            rootViewController: MyAnimationsViewController()
        )
        let settingsVC = UINavigationController(
            rootViewController: SettingsViewController()
        )
        
        homeVC.tabBarItem = UITabBarItem(
            title: L.home,
            image: UIImage(systemName: "house.fill"),
            tag: 0
        )
        
        animationsVC.tabBarItem = UITabBarItem(
            title: L.myAnimations,
            image: UIImage(systemName: "play.rectangle.fill"),
            tag: 1
        )
        
        settingsVC.tabBarItem = UITabBarItem(
            title: L.settings,
            image: UIImage(systemName: "gearshape.fill"),
            tag: 2
        )

        let viewControllers = [homeVC, animationsVC, settingsVC]
        self.viewControllers = viewControllers

        addSeparatorLine()
        updateTabBar()
    }

    func updateTabBar() {
        tabBar.backgroundColor = UIColor(hex: "#2D2D2D")
        tabBar.tintColor = UIColor.colorsPrimary
        tabBar.unselectedItemTintColor = UIColor(hex: "#999999")
        tabBar.itemPositioning = .centered
    }
    
    private func addSeparatorLine() {
        let separatorLine = UIView()
        separatorLine.backgroundColor = .white.withAlphaComponent(0.15)
        tabBar.addSubview(separatorLine)

        separatorLine.snp.makeConstraints { make in
            make.height.equalTo(0.33)
            make.leading.trailing.equalTo(tabBar)
            make.top.equalTo(tabBar.snp.top)
        }
    }
}
