// App/SceneDelegate.swift

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // 1. UIWindow 생성 및 windowScene 연결
        window = UIWindow(windowScene: windowScene)

        let splashViewController = SplashViewController()
        splashViewController.onFinish = { [weak self] in
            self?.showMainInterface()
        }

        window?.rootViewController = splashViewController
        window?.makeKeyAndVisible()
    }

    private func showMainInterface() {
        guard let window else { return }
        let tabBarController = makeMainTabBarController()

        UIView.transition(
            with: window,
            duration: 0.35,
            options: [.transitionCrossDissolve, .curveEaseInOut],
            animations: {
                window.rootViewController = tabBarController
            }
        )
    }

    private func makeMainTabBarController() -> MainTabBarController {
        // 1. 각 탭의 루트 뷰컨트롤러 생성
        let dashboardVC  = DashboardViewController()
        let calendarVC   = CalendarViewController()
        let ledgerVC     = LedgerViewController()
        let profileVC    = ProfileViewController()

        // 2. 각 뷰컨트롤러를 UINavigationController로 래핑 (Push/Pop 지원)
        let dashboardNav = UINavigationController(rootViewController: dashboardVC)
        let calendarNav  = UINavigationController(rootViewController: calendarVC)
        let ledgerNav    = UINavigationController(rootViewController: ledgerVC)
        let profileNav   = UINavigationController(rootViewController: profileVC)

        // 3. 탭바 아이템 설정 (SF Symbols 사용)
        dashboardNav.tabBarItem = UITabBarItem(
            title: "대시보드",
            image: UIImage(systemName: "chart.pie"),
            selectedImage: UIImage(systemName: "chart.pie.fill")
        )
        calendarNav.tabBarItem = UITabBarItem(
            title: "목표",
            image: UIImage(systemName: "target"),
            selectedImage: UIImage(systemName: "target")
        )
        ledgerNav.tabBarItem = UITabBarItem(
            title: "장부",
            image: UIImage(systemName: "list.bullet.rectangle"),
            selectedImage: UIImage(systemName: "list.bullet.rectangle.fill")
        )
        profileNav.tabBarItem = UITabBarItem(
            title: "프로필",
            image: UIImage(systemName: "person"),
            selectedImage: UIImage(systemName: "person.fill")
        )

        let tabBarController = MainTabBarController()
        tabBarController.viewControllers = [dashboardNav, ledgerNav, calendarNav, profileNav]
        tabBarController.selectedIndex = 0  // 앱 시작 시 대시보드 탭 선택
        return tabBarController
    }

    // 이하 생명주기 메서드 (기본 구현)
    func sceneDidDisconnect(_ scene: UIScene) {}
    func sceneDidBecomeActive(_ scene: UIScene) {}
    func sceneWillResignActive(_ scene: UIScene) {}
    func sceneWillEnterForeground(_ scene: UIScene) {}
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
