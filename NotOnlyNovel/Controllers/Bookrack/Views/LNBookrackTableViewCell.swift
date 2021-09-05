//
//  LNBookrackTableViewCell.swift
//  NotOnlyNovel
//
//  Created by JohnnyCheung on 2021/3/2.
//

import UIKit
import SnapKit

class LNBookrackTableViewCell: UITableViewCell {

    private var dataModel: LNBookrackItemModel?
    
    //private lazy var screenSize = UIScreen.main.bounds.size
    private lazy var coverImageView = UIImageView()
    private lazy var authorLabel = UILabel()
    private lazy var haveReadLabel = UILabel()
    private lazy var bookNameLabel = UILabel()
    private var bookNameLabelWidthConstraint: Constraint?
    private var bookNameLabelHeightConstraint: Constraint?
    private lazy var bookLabel = UILabel()
    private var bookLabelWidthConstraint: Constraint?
    private lazy var chapterCountLabel = UILabel()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        let margin15: CGFloat = 15
        
        let shadowView = UIView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 给书封面加阴影
            shadowView.layer.shadowColor = UIColor.gray.cgColor
            shadowView.layer.shadowOpacity = 0.55
            shadowView.layer.shadowOffset = CGSize.zero
            shadowView.layer.shadowRadius = 4
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 4).cgPath
        }
        contentView.addSubview(shadowView)
        shadowView.snp.makeConstraints {
            $0.top.left.equalTo(margin15)
            $0.width.equalTo(75)
            $0.height.equalTo(105)
        }
        
        // 封面
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.layer.cornerRadius = 5
        coverImageView.layer.masksToBounds = true
        coverImageView.backgroundColor = PublicColors.mainGrayColor
        contentView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.top.left.equalTo(margin15)
            $0.width.equalTo(75)
            $0.height.equalTo(105)
        }
        
        // 作者名字
        authorLabel.textColor = PublicColors.subTitleColor
        authorLabel.font = UIFont.AvenirMedium(size: 13) //.systemFont(ofSize: 13)
        contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints {
            $0.left.equalTo(self.coverImageView.snp.right).offset(margin15)
            $0.top.equalTo(self.coverImageView.snp.top).offset(7)
            $0.height.equalTo(20)
            $0.right.equalTo(-15)
        }
        
        // 几天前读过
        haveReadLabel.textColor = PublicColors.subTitleColor
        haveReadLabel.font = UIFont.AvenirMedium(size: 12)  //.systemFont(ofSize: 12)
        haveReadLabel.textAlignment = .right
        contentView.addSubview(haveReadLabel)
        haveReadLabel.snp.makeConstraints {
            $0.right.equalTo(-margin15)
            $0.top.equalTo(self.coverImageView.snp.top).offset(7)
            $0.height.equalTo(20)
            $0.width.equalTo(150)
        }
        
        // 书名
        bookNameLabel.textColor = PublicColors.blackColor
        bookNameLabel.font = UIFont.AvenirMedium(size: 16) //.boldSystemFont(ofSize: 16)
        bookNameLabel.numberOfLines = 0
        bookNameLabel.lineBreakMode = .byWordWrapping
        contentView.addSubview(bookNameLabel)
        bookNameLabel.snp.makeConstraints {
            $0.top.equalTo(self.authorLabel.snp.bottom).offset(5)
            $0.left.equalTo(self.coverImageView.snp.right).offset(margin15)
            self.bookNameLabelHeightConstraint = $0.height.equalTo(25).constraint
            self.bookNameLabelWidthConstraint = $0.width.equalTo(100).constraint
        }
        
        // 标签
        bookLabel.textColor = PublicColors.titleColor
        bookLabel.font = UIFont.AvenirMedium(size: 10)
        bookLabel.backgroundColor = PublicColors.mainGrayColor
        bookLabel.layer.cornerRadius = 9
        bookLabel.layer.masksToBounds = true
        bookLabel.textAlignment = .center
        contentView.addSubview(bookLabel)
        bookLabel.snp.makeConstraints {
            $0.left.equalTo(self.coverImageView.snp.right).offset(margin15)
            $0.height.equalTo(18)
            self.bookLabelWidthConstraint = $0.width.equalTo(0).constraint
            $0.bottom.equalTo(self.coverImageView.snp.bottom).offset(0)
        }
        
        // 章节数量
        chapterCountLabel.textColor = PublicColors.subTitleColor
        chapterCountLabel.font = UIFont.AvenirMedium(size: 13) //.systemFont(ofSize: 13)
        chapterCountLabel.textAlignment = .right
        contentView.addSubview(chapterCountLabel)
        chapterCountLabel.snp.makeConstraints {
            $0.right.equalTo(-margin15)
            $0.bottom.equalTo(self.coverImageView.snp.bottom).offset(0)
            $0.height.equalTo(23)
            $0.width.equalTo(100)
        }
        
        let btmLine = UIView()
        btmLine.backgroundColor = PublicColors.mainGrayColor
        contentView.addSubview(btmLine)
        btmLine.snp.makeConstraints {
            $0.left.equalTo(margin15)
            $0.right.equalTo(-margin15)
            $0.height.equalTo(1)
            $0.top.equalTo(self.coverImageView.snp.bottom).offset(margin15)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(model: LNBookrackItemModel)  {
        dataModel = model
        
        let margin15: CGFloat = 15
        let maxHalfWidth = bounds.size.width - margin15 - margin15 - margin15 - margin15 - margin15
        
        if let _bookCover = model.bookCover, let url = URL(string: _bookCover) {
            coverImageView.sd_setImage(with: url, completed: nil)
        }
        authorLabel.text = model.authorName
        
        haveReadLabel.text = "Read in \((Date.stringToDateTime(model.updatetime ?? "") as NSDate?)?.dateTimeAgoRoughly() ?? "")"
        
        bookNameLabel.text = model.bookName
        var newHeight = bookNameLabel.sizeThatFits(CGSize(width: maxHalfWidth, height: 80)).height
        self.bookNameLabelWidthConstraint?.update(offset: maxHalfWidth)
        if newHeight > 25 {
            newHeight = newHeight + 10
        }
        self.bookNameLabelHeightConstraint?.update(offset: newHeight)
        
        bookLabel.text = model.labels
        let labelNewWidth = bookLabel.sizeThatFits(CGSize(width: 150, height: 22)).width
        bookLabelWidthConstraint?.update(offset: 9 + labelNewWidth + 9)
        
        chapterCountLabel.text = "\(model.chapterCount) chapters"
    }

}
