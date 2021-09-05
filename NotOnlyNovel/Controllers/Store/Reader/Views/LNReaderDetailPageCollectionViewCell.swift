//
//  FNReaderDetailPageCollectionViewCell.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/4.
//
/*
import UIKit

class LNReaderDetailPageCollectionViewCell: UICollectionViewCell {
    
    var indexPath: IndexPath = IndexPath(row: 0, section: 0)
    private var detailModel: LNBookChapterDetailModel?
    private var charLengthAndPageTextDict: [Int:String]?
    
    private lazy var pageTextContentView = LNPageTextContentView(frame: UIScreen.main.bounds)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 创建一个可显示的文本UILabel
        contentView.addSubview(pageTextContentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(with _charLengthAndPageTextDict: [Int:String], model: LNBookChapterDetailModel) {
        charLengthAndPageTextDict = _charLengthAndPageTextDict
        detailModel = model
        
        if let partText = _charLengthAndPageTextDict.values.first {
            pageTextContentView.setAttributedText(with: FNReadParser.getLabelAttributedString(withContent: partText))
        }
        pageTextContentView.setChapterName(with: model.chapterName ?? "", pageIndex: indexPath.row, totalPages: model.charLengthAndPageTextArray.count)
        if model.charLengthAndPageTextArray.count == 1 || indexPath.row == (model.charLengthAndPageTextArray.count - 1) { // 如果该章节只有一页，就让其文本居中居上显示
            pageTextContentView.setLabelSizeToFit()
        } else {
            pageTextContentView.setLabelRestoreSize(with: LNPageTextContentView.labelFrame)
        }
        pageTextContentView.chapterId = model.chapterId
        
    }
    
    // 日夜间模式切换
    func toggleNightMode(with isNightMode: Bool) {
        if isNightMode {
            backgroundColor = PublicColors.chapterListTitleColor
        } else {
            backgroundColor = PublicColors.chapterListTitleColorAtDay
        }
        for _v in subviews {
            if let __v = _v as? LNPageTextContentView {
                __v.toggleNightMode(with: isNightMode)
            }
        }
    }
    
}
*/
