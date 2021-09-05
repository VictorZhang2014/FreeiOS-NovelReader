//
//  Ext.swift
//  FortuneNovel
//
//  Created by Johnny Cheung on 2020/9/27.
//

import UIKit


extension UIView {
    
    // 仅圆角某个边角
    func roundCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.clipsToBounds = true
            self.layer.cornerRadius = radius
            self.layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
    }
    
    // https://stackoverflow.com/questions/37903124/set-background-gradient-on-button-in-swift
    func applyGradient(colours: [UIColor]) {
        applyGradient(colours: colours, locations: nil)
    }
     
    func applyGradient(colours: [UIColor], locations: [NSNumber]?) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.locations = locations
        layer.insertSublayer(gradient, at: 0)
        //layer.addSublayer(gradient)
        if frame.equalTo(CGRect()) {
            print("此视图frame是{0,0,0,0}，渐变背景不会生效！！！")
        }
    }
     
    func applyGradientFromTopToBottom(colours: [UIColor]) {
        self.applyGradient(colours: colours, locations: nil)
    }
     
    func applyGradientFromLeftToRight(colours: [UIColor]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // 如果是使用Autolayout布局，需要延迟设置背景渐变，因为背景渐变依赖frame的大小，
            // 而autolayout创建的没有frame，所以需要等创建视图流程结束才可以
            let gradient: CAGradientLayer = CAGradientLayer()
            gradient.frame = self.bounds
            gradient.colors = colours.map { $0.cgColor }
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
            self.layer.insertSublayer(gradient, at: 0)
            //layer.addSublayer(gradient)
            if self.frame.equalTo(CGRect()) {
                print("此视图frame是{0,0,0,0}，渐变背景不会生效！！！")
            }
        }
    }
    

}
