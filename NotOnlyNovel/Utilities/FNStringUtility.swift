//
//  LNStringUtility.swift
//  LuckyNovel
//
//  Created by ZhangQiang on 2020/11/11.
//

import UIKit

final class LNStringUtility {
    
    // 对一段落文字的，高亮 --> 设置不同字体 -->  设置不同颜色 --> 设置加粗 --> 设置下划线
    public class func attributedText(withString string: String, highlightedString: [String], font: UIFont, color: UIColor, isBold: Bool=true, isUnderline: Bool=false) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        // 字体加粗
        var boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: font.pointSize)]
        if isBold {
            boldFontAttribute = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        }
        for s in highlightedString {
            let range = (string as NSString).range(of: s)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        // 下划线
        if isUnderline {
            let underlineAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            for s in highlightedString {
                let range = (string as NSString).range(of: s)
                attributedString.addAttributes(underlineAttribute, range: range)
            }
        }
        // 变颜色
        let colorAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color]
        for s in highlightedString {
            let range = (string as NSString).range(of: s)
            attributedString.addAttributes(colorAttribute, range: range)
        }
        return attributedString
    }
    
    public class func attributedText(withString string: String, boldString: String, font: UIFont, isUnderline: Bool=false) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        // 粗字体
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        
        let range1 = (string as NSString).range(of: "Privacy Policy")
        attributedString.addAttributes(boldFontAttribute, range: range1)
        
        // 下划线
        if isUnderline {
            let underlineAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
            let range1 = (string as NSString).range(of: boldString)
            attributedString.addAttributes(underlineAttribute, range: range1)
        }
        return attributedString
    }
    
    /// 对指定文字加颜色，加粗
    public class func attributedText(withString string: String, subString: String, font: UIFont, color: UIColor, isBold: Bool=true) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                         attributes: [NSAttributedString.Key.font: font])
        if isBold {
            // 粗字体
            let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
            let range = (string as NSString).range(of: subString)
            attributedString.addAttributes(boldFontAttribute, range: range)
        }
        // 变颜色
        let colorAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.foregroundColor: color]
        let range1 = (string as NSString).range(of: subString)
        attributedString.addAttributes(colorAttribute, range: range1)
        return attributedString
    }
    
    // 点击部分UILabel的text，以进行响应
    public class func respondEventWithinPartOfLabel(label: UILabel, inRange targetRange: NSRange, inPoint targetPoint: CGPoint) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = targetPoint
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                              //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
                                                        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
