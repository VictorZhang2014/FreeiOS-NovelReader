//
//  FNReaderDetailPageCollectionViewCell.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/08/01.
//

import UIKit

class LNReadingDetailCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    private var detailModel: LNBookChapterDetailModel?
    
    private var eventOfClickingTextView: (() -> Void)?
    
    private lazy var textView: UITextView = {
        let t = UITextView()
        t.backgroundColor = UIColor.white
        t.isEditable = false
        t.isSelectable = true
        t.textColor = PublicColors.novelTextColor
        t.font = UIFont.HelveticaNeue(size: 20)
        t.showsVerticalScrollIndicator = true
        t.showsHorizontalScrollIndicator = false
        t.textContainerInset = UIEdgeInsets(top: 0, left: 15, bottom: 10, right: 5)
        //t.dataDetectorTypes = .all
        t.bounces = false
        //t.isScrollEnabled = false
        return t
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
         
        textView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickTextView)))
        contentView.addSubview(textView)
        textView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didClickTextView() {
        eventOfClickingTextView?()
    }
    
    func setEventOfClickingTextView(execute work: @escaping @convention(block) () -> Void) {
        eventOfClickingTextView = work
    }
    
    func setContent(model: LNBookChapterDetailModel) {
        let textContent = model.content
        guard let _textContent = textContent else {
            return
        }
//        let headerTitleDesc = model.headerTitleDesc
//        guard let _headerTitleDesc = headerTitleDesc else {
//            return
//        }
//        let footerTitleDesc = model.footerTitleDesc
//        guard let _footerTitleDesc = footerTitleDesc else {
//            return
//        }
        
        textView.text = textContent
//        print("textView.contentSize1=\(textView.contentSize)")

        let mutableAttrStr = NSMutableAttributedString(string: _textContent)
        
//        let headerTitleDescRange = (_textContent as NSString).range(of: model.chapterName ?? "") //NSString(string: _textContent).range(of: model.chapterName ?? "")
//        let footerTitleDescRange = NSString(string: _textContent).range(of: _footerTitleDesc)
//        let contentRange = NSMakeRange(headerTitleDescRange.length, mutableAttrStr.length - headerTitleDescRange.length - footerTitleDescRange.length)
        let contentRange = NSMakeRange(0, mutableAttrStr.length)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 8
        style.lineBreakMode = .byWordWrapping
        mutableAttrStr.addAttributes([NSAttributedString.Key.paragraphStyle:style], range: NSMakeRange(0, mutableAttrStr.length))
        mutableAttrStr.addAttributes([NSAttributedString.Key.font: UIFont.HelveticaNeue(size: 18)!], range: contentRange)
        mutableAttrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], range: contentRange)
        
        // 设置章节标题的颜色
        //if _headerTitleDesc.count > 0 {
        //    mutableAttrStr.addAttributes([NSAttributedString.Key.foregroundColor: UIColor.blue], range: headerTitleDescRange)
        //}
        
        textView.attributedText = mutableAttrStr
        textView.sizeToFit()
    }
    
    // 日夜间模式切换
    func toggleNightMode(with isNightMode: Bool) {
        if isNightMode {
            contentView.backgroundColor = PublicColors.darkModeBackground
            textView.backgroundColor = PublicColors.darkModeBackground
            textView.textColor = UIColor.white.withAlphaComponent(0.35)
        } else {
            contentView.backgroundColor = PublicColors.dayModeBackground
            textView.backgroundColor = PublicColors.dayModeBackground
            textView.textColor = UIColor.black //PublicColors.novelTextColor
        }
    }
    
    func scrollToBottom() {
        let textCount: Int = textView.text.count
        guard textCount >= 1 else { return }
        textView.scrollRangeToVisible(NSRange(location: textCount - 1, length: 1))
    }
    
}
 
