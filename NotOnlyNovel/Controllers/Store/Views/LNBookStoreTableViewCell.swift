//
//  LNBookStoreTableViewCell.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/2/3.
//

import UIKit


protocol LNBookStoreTableViewCellDelegate {
    func bookTableViewCellEvent(in tableViewCell: LNBookStoreTableViewCell, section: NSInteger, index: NSInteger)
}


class LNBookStoreTableViewCell: UITableViewCell {
    
    public var cellDelegate: LNBookStoreTableViewCellDelegate?
    public static let cellHeight: CGFloat = 270
    
    public var indexPath: IndexPath?
    
    private let bookScrollView = UIScrollView()
    private let categoryTitleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = PublicColors.whiteColor
        
        let leftMargin: CGFloat = 20
        
        // 类别标题
        categoryTitleLabel.text = "Original"
        categoryTitleLabel.textColor = PublicColors.titleColor
        categoryTitleLabel.font = UIFont.Avenir(size: 18) //ArialRoundedMTBold(size: 18)
        self.contentView.addSubview(categoryTitleLabel)
        categoryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.left.equalTo(leftMargin)
            $0.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        // 横向滚动的
        let bookScrollViewMaxHeight = LNBookStoreTableViewCell.cellHeight - (15 + 24 + 10 + 3)
        bookScrollView.contentSize = CGSize(width: UIScreen.main.bounds.size.width, height: bookScrollViewMaxHeight)
        self.contentView.addSubview(bookScrollView)
        bookScrollView.snp.makeConstraints {
            $0.top.equalTo(categoryTitleLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(-3)
        }
        
        let btmLine = UIView()
        btmLine.backgroundColor = PublicColors.mainGrayColor
        self.contentView.addSubview(btmLine)
        btmLine.snp.makeConstraints {
            $0.height.equalTo(7)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func updateData(with models: [LNBookStoreItemIntroModel], categoryName: String, indexPath: IndexPath?) {
        self.indexPath = indexPath
        categoryTitleLabel.text = categoryName
         
        let margin: CGFloat = 20
        var cardWidth: CGFloat = 110
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            cardWidth = 143
        }
        let bookScrollViewHeight = bookScrollView.contentSize.height
        let maxContentWidth = margin + cardWidth * CGFloat(models.count) + margin
        bookScrollView.contentSize = CGSize(width: maxContentWidth, height: bookScrollViewHeight)
         
        // 先删除已存在的书籍卡片
        for v in bookScrollView.subviews {
            v.removeFromSuperview()
        }
        
        // 再添加新的书籍卡片
        var x: CGFloat = 0
        for i in 0..<models.count {
            let detailModel = models[i]
            let card = self.createCardView(with: detailModel, cardWidth: cardWidth)
            x = margin + cardWidth * CGFloat(i)
            card.frame = CGRect(x: x, y: 0, width: cardWidth, height: bookScrollViewHeight)
            card.tag = i
            bookScrollView.addSubview(card)
        }
    }
    
    private func createCardView(with model: LNBookStoreItemIntroModel, cardWidth: CGFloat) -> UIView {
        let card = UIView()
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didOpenBook(_:))))
        
        let margin: CGFloat = 10
        
        // 阴影
        let shadowView = UIView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 给书封面加阴影
            shadowView.layer.shadowColor = UIColor.gray.cgColor
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = CGSize.zero
            shadowView.layer.shadowRadius = 4
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 4).cgPath
        }
        card.addSubview(shadowView)
        shadowView.snp.makeConstraints {
            $0.top.equalTo(margin)
            $0.left.equalToSuperview()
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                $0.width.equalTo(133)
            } else {
                $0.width.equalTo(100)
            }
            $0.height.equalTo(133)
        }
        
        // 封面
        let coverImgView = UIImageView()
        if let coverUrl = URL(string: model.bookCover ?? "") {
            coverImgView.sd_setImage(with: coverUrl) { (downloadedImage, error, cacheType, downloadedUrl) in
                if downloadedImage != nil {
                    model.tmpBookCoverImage = downloadedImage
                }
            }
        }
        coverImgView.backgroundColor = PublicColors.mainGrayColor
        coverImgView.contentMode = .scaleAspectFill
        coverImgView.layer.cornerRadius = 3
        coverImgView.layer.masksToBounds = true
        card.addSubview(coverImgView)
        coverImgView.snp.makeConstraints {
            $0.top.equalTo(margin)
            $0.left.equalToSuperview()
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                $0.width.equalTo(133)
            } else {
                $0.width.equalTo(100)
            }
            $0.height.equalTo(133)
        }

        let bookNameLabel = UILabel()
        bookNameLabel.text = model.bookName
        bookNameLabel.textColor = PublicColors.blackColor
        bookNameLabel.font = UIFont.Avenir(size: 14)
        //bookNameLabel.textAlignment = .justified
        bookNameLabel.numberOfLines = 3
        card.addSubview(bookNameLabel)
        bookNameLabel.snp.makeConstraints {
            $0.top.equalTo(coverImgView.snp.bottom).offset(5)
            $0.left.equalToSuperview()
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                $0.width.equalTo(133)
            } else {
                $0.width.equalTo(100)
            }
            $0.height.equalTo(60)
        }

//        let authorLabel = UILabel()
//        authorLabel.text = model.author
//        authorLabel.textColor = PublicColors.titleColor
//        authorLabel.font = UIFont.systemFont(ofSize: 12)
//        authorLabel.textAlignment = .center
        //card.addSubview(authorLabel)
//        authorLabel.snp.makeConstraints {
//            $0.top.equalTo(bookNameLabel.snp.bottom).offset(5)
//            $0.left.equalToSuperview()
//            $0.width.equalTo(100)
//            $0.height.equalTo(20)
//        }
        
        return card
    }
    
    @objc func didOpenBook(_ gesture: UIGestureRecognizer) {
        guard let section = indexPath?.section else { return }
        guard let index = gesture.view?.tag else { return }
        self.cellDelegate?.bookTableViewCellEvent(in: self, section: section, index: index)
    }
    
}
