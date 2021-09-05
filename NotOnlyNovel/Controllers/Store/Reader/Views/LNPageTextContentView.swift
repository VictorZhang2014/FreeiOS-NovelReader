//
//  LNPageTextContentView.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/4.
//
/*
import UIKit
import SnapKit


class LNPageTextContentView: UIView {
    
    var chapterId: Int = 0 // 章节ID
    
    private let chapterNameTopLabel = UILabel()
    private let chapterNameFirstPageLabel = UILabel()
    private var chapterNameFirstPageLabelHeightConstraint: Constraint?
    private let chapterPageNumberLabel = UILabel()
     
    private let label = UILabel()
    static var labelFrame: CGRect {
        get {
            let screenSize = UIScreen.main.bounds.size
            
            let topmargin: CGFloat = self.statusBarHeight + 44
            var btmmargin: CGFloat = 30
            if LNDeviceUtil.shared().isiPhoneXFamily {
                btmmargin = 50
            }
            let leftmargin: CGFloat = 20
            let rightmargin: CGFloat = 10
            let labelFrame = CGRect(origin: CGPoint(x: leftmargin, y: topmargin), size: CGSize(width: screenSize.width-leftmargin-rightmargin, height: screenSize.height-topmargin-btmmargin))
            return labelFrame
        }
    }
    
    private static let statusBarHeight: CGFloat = {
        var statusBarHeight: CGFloat = 0
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
            statusBarHeight = window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        return statusBarHeight
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        chapterNameTopLabel.text = "Chapter 1"
        chapterNameTopLabel.textColor = PublicColors.subTitleColor
        chapterNameTopLabel.font = UIFont.systemFont(ofSize: 16)
        addSubview(chapterNameTopLabel)
        chapterNameTopLabel.snp.makeConstraints {
            $0.top.equalTo(LNPageTextContentView.statusBarHeight + 5)
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(25)
        }
        
        chapterNameFirstPageLabel.text = "Chapter 1"
        chapterNameFirstPageLabel.textColor = PublicColors.titleColor
        chapterNameFirstPageLabel.font = UIFont.boldSystemFont(ofSize: 19)
        //chapterNameFirstPageLabel.numberOfLines = 0
        addSubview(chapterNameFirstPageLabel)
        chapterNameFirstPageLabel.snp.makeConstraints {
            $0.top.equalTo(LNPageTextContentView.statusBarHeight + 15)
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            self.chapterNameFirstPageLabelHeightConstraint = $0.height.equalTo(40).constraint
        }
        
        label.textColor = FNReadConfig.shared().fontColor // PublicColors.novelTextColor
        label.font = UIFont.systemFont(ofSize: FNReadConfig.shared().fontSize)
        //label.font = UIFont.HelveticaNeue(size: 16)
        label.numberOfLines = 0
        label.lineBreakMode = FNReadConfig.shared().lineBreakMode
        label.frame = LNPageTextContentView.labelFrame
        addSubview(label)
        
        chapterPageNumberLabel.text = "1/1"
        chapterPageNumberLabel.textColor = PublicColors.subTitleColor
        chapterPageNumberLabel.font = UIFont.systemFont(ofSize: 11)
        chapterPageNumberLabel.textAlignment = .right
        addSubview(chapterPageNumberLabel)
        chapterPageNumberLabel.snp.makeConstraints {
            if LNDeviceUtil.shared().isiPhoneXFamily {
                $0.right.bottom.equalTo(-20)
            } else {
                $0.right.bottom.equalTo(-10)
            }
            $0.width.equalTo(30)
            $0.height.equalTo(15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func toggleNightMode(with isNightMode: Bool) {

    }
    
    // 设置页面的章节标题
    func setChapterName(with name: String, pageIndex: Int, totalPages: Int=0) {
        chapterNameTopLabel.text = name
        chapterNameFirstPageLabel.text = name
        chapterPageNumberLabel.text = "\(pageIndex+1)/\(totalPages)"
        
        if pageIndex == 0 {
            chapterNameTopLabel.isHidden = true
            chapterNameFirstPageLabel.isHidden = false
            
            let screenSize = UIScreen.main.bounds.size
            let newHeight = chapterNameFirstPageLabel.sizeThatFits(CGSize(width: screenSize.width - 20 * 2, height: 80)).height
            self.chapterNameFirstPageLabelHeightConstraint?.update(offset: newHeight)
        } else {
            chapterNameTopLabel.isHidden = false
            chapterNameFirstPageLabel.isHidden = true
        }
    }
    
    func updateText(with text: String) {
        self.label.text = text
    }
    
    func setAttributedText(with attributedText: NSAttributedString)  {
        label.attributedText = attributedText
    }
    
    func setLabelSizeToFit()  {
        label.sizeToFit()
    }
    
    func setLabelRestoreSize(with rect: CGRect)  {
        label.frame = rect
    }
    
}
*/
