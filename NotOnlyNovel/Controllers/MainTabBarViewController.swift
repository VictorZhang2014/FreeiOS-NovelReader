//
//  MainTabBarViewController.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/1/31.
//

import UIKit


class MainTabBarViewController: UITabBarController {

    private lazy var bookrackVC = LNBookrackViewController()
    private lazy var storeVC = LNStoreViewController()
    private lazy var meVC = LNMeViewController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        registerNotifications()
        createSubVCs()
    }
    
    private func registerNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(didChangeTabBar(_:)), name: NSNotification.Name(rawValue: NotificationNameChangeTabBar), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveAPNSNotification(_:)), name: NSNotification.Name(rawValue: NotificationNameAPNSMessage), object: nil)
    }
    
    @objc func didChangeTabBar(_ notification: Notification) {
        if let index = notification.userInfo?["index"] as? Int {
            self.selectedIndex = index
        }
    }
    
    @objc func didReceiveAPNSNotification(_ notification: Notification) {
        if let model = notification.userInfo?["model"] as? LNRemotePushNotificationModel {
            if model.type == .openBook {
                if model.bookId > 0 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(700)) {
                        let vc = LNBookIntroViewController()
                        vc.bookId = model.bookId
                        (self.selectedViewController as? LNBaseNavigationController)?.pushViewController(vc, animated: true)
                        
                        BuryPointUtil.event("026", label: "APNS打开小说", attributes: ["type":"local"])
                    }
                }
            }
        }
    }
    
    private func createSubVCs() {
        
        let navBookrackVC = LNBaseNavigationController(rootViewController: bookrackVC)
        navBookrackVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: "tabbar-library-unselected"), selectedImage: UIImage(named: "tabbar-library-selected"))
        navBookrackVC.tabBarItem.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        
        let navStoreVC = LNBaseNavigationController(rootViewController: storeVC)
        navStoreVC.tabBarItem = UITabBarItem(title: "Discover", image: UIImage(named: "tabbar-store-unselected"), selectedImage: UIImage(named: "tabbar-store-selected"))
         navStoreVC.tabBarItem.imageInsets = UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0)
        
        let navMeVC = LNBaseNavigationController(rootViewController: meVC)
        navMeVC.tabBarItem = UITabBarItem(title: "Profile", image: UIImage(named: "tabbar-profile-unselected"), selectedImage: UIImage(named: "tabbar-profile-selected"))
        
        self.viewControllers = [navBookrackVC, navStoreVC, navMeVC]
        
        self.tabBar.barTintColor = PublicColors.whiteColor
        self.tabBar.isTranslucent = false
        self.tabBar.tintColor = PublicColors.mainRedColor
        self.tabBar.unselectedItemTintColor = UIColor(rgb: 0xe8e8e8)
        
        self.selectedIndex = 1 // 默认选中中间那个tab
        
        self.delegate = self
    }
    

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension MainTabBarViewController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        let impactor = UIImpactFeedbackGenerator(style: .medium)
        impactor.impactOccurred()
    }
    
}
