//
//  UITool.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/7/26.
//

import Foundation


let KScreenSize = UIScreen.main.bounds
let KScreenWidth: CGFloat = UIScreen.main.bounds.size.width
let KScreenHeight: CGFloat = UIScreen.main.bounds.size.height

///安全距离
let KTabbarSafeBottomMargin:CGFloat = getTabbarSafeBottomMargin()
let kTabBarHeight:CGFloat = 49 +  KTabbarSafeBottomMargin


public func KRatioX375(x : CGFloat) -> CGFloat {
    return KScreenWidth / 375.0 * (x)
}

public func KRatioY812(y : CGFloat) -> CGFloat {
    return KScreenHeight / 812.0 * (y)
}


///底部安全距离
private func getTabbarSafeBottomMargin() -> CGFloat {
    var safeBottom:CGFloat = 0
    if #available(iOS 11, *) {
        let safeArea = UIApplication.shared.keyWindow?.safeAreaInsets
        safeBottom = safeArea?.bottom ?? 0
    }
    return safeBottom
}
