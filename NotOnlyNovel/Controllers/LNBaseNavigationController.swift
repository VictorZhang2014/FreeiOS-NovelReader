//
//  LNBaseNavigationController.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/2/1.
//

import UIKit

class LNBaseNavigationController: UINavigationController {

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
        } else {
            viewController.hidesBottomBarWhenPushed = false
        }
        super.pushViewController(viewController, animated: animated)
    }

}
