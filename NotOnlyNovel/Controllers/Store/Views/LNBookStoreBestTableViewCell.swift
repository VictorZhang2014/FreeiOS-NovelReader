//
//  LNBookStoreBestTableViewCell.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/3.
//

import UIKit


protocol LNBookStoreBestTableViewCellDelegate {
    
    func bookStoreBestTableViewCellEvent(with cell: LNBookStoreBestTableViewCell, didOpenTheBook indexPath: IndexPath?)
    
}

class LNBookStoreBestTableViewCell: UITableViewCell {
    
    public var cellDelegate: LNBookStoreBestTableViewCellDelegate?
    public var indexPath: IndexPath?
    
    public var models: [LNBookStoreItemIntroModel] = []
    
    public static let cellHeight: CGFloat = 380
    
    private lazy var categoryTitleLabel = UILabel()
    private lazy var leftView = UIView()
    private lazy var centerView = UIView()
    private lazy var rightView = UIView()
    private lazy var bookCardWidth: CGFloat = 260
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.backgroundColor = PublicColors.whiteColor
        
        let leftMargin: CGFloat = 20
        
        // 类别标题
        categoryTitleLabel.text = "" //"Best Luck"
        categoryTitleLabel.textColor = PublicColors.titleColor
        categoryTitleLabel.font = UIFont.Avenir(size: 18)
        self.contentView.addSubview(categoryTitleLabel)
        categoryTitleLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.left.equalTo(leftMargin)
            $0.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        let height = LNBookStoreBestTableViewCell.cellHeight - (15 + 24 + 10)
        
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: 15 + 24 + 10, width: UIScreen.main.bounds.size.width, height: height)
        scrollView.contentSize = CGSize(width: bookCardWidth * 3, height: 0)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        contentView.addSubview(scrollView)
        
        // 左边
        leftView.frame = CGRect(x: 0, y: 0, width: bookCardWidth, height: height)
        leftView.backgroundColor = UIColor.clear
        scrollView.addSubview(leftView)
        
        // 中间
        centerView.frame = CGRect(x: bookCardWidth, y: 0, width: bookCardWidth, height: height)
        centerView.backgroundColor = UIColor.clear
        scrollView.addSubview(centerView)
        
        // 右边
        rightView.frame = CGRect(x: bookCardWidth * 2, y: 0, width: bookCardWidth, height: height)
        rightView.backgroundColor = UIColor.clear
        scrollView.addSubview(rightView)
        
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
    
    private func createBookCard(with model: LNBookStoreItemIntroModel, index: Int) -> UIView {
        let card = UIView()
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didOpenBook(_:))))
        
        let margin: CGFloat = 5
        let leftMargin: CGFloat = 20
        
        // 阴影
        let shadowView = UIView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // 给书封面加阴影
            shadowView.layer.shadowColor = UIColor.gray.cgColor
            shadowView.layer.shadowOpacity = 0.5
            shadowView.layer.shadowOffset = CGSize.zero
            shadowView.layer.shadowRadius = 3
            shadowView.layer.shadowPath = UIBezierPath(roundedRect: shadowView.bounds, cornerRadius: 3).cgPath
        }
        card.addSubview(shadowView)
        shadowView.snp.makeConstraints {
            $0.top.equalTo(margin)
            $0.left.equalTo(leftMargin)
            $0.bottom.equalTo(-margin)
            $0.width.equalTo(65)
        }
        
        // 封面
        let coverImageViewWidth: CGFloat = 65
        let coverImageView = UIImageView()
        coverImageView.backgroundColor = PublicColors.mainGrayColor
        if let coverUrl = model.bookCover {
            coverImageView.sd_setImage(with: URL(string: coverUrl)) { (downloadedImage, error, cacheType, downloadedUrl) in
                if downloadedImage != nil {
                    model.tmpBookCoverImage = downloadedImage
                }
            }
        } 
        coverImageView.layer.cornerRadius = 3
        coverImageView.layer.masksToBounds = true
        card.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.top.equalTo(margin)
            $0.left.equalTo(leftMargin)
            $0.bottom.equalTo(-margin)
            $0.width.equalTo(coverImageViewWidth)
        }
        
        // 排名
        let rankLabel = UILabel()
        rankLabel.text = "\(index+1)"
        rankLabel.font = UIFont.systemFont(ofSize: 13)
        rankLabel.textColor = PublicColors.whiteColor
        rankLabel.textAlignment = .center
        rankLabel.roundCorners(.layerMaxXMaxYCorner, radius: 8)
        if index < 3 {
            rankLabel.backgroundColor = PublicColors.mainLightPinkColor
        } else if index >= 3 && index < 6 {
            rankLabel.backgroundColor = PublicColors.mainOrangeColor
        } else if index >= 6 && index < 9 {
            rankLabel.backgroundColor = PublicColors.mainBlackColor
        }
        coverImageView.addSubview(rankLabel)
        rankLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.width.height.equalTo(18)
        }

        // 书名
        let bookName = UILabel()
        bookName.text = model.bookName
        bookName.textColor = PublicColors.blackColor
        bookName.font = UIFont.AvenirMedium(size: 14)// UIFont.boldSystemFont(ofSize: 14)
        bookName.numberOfLines = 0
        bookName.lineBreakMode = .byWordWrapping
        let maxNameWidth = bookCardWidth - leftMargin - coverImageViewWidth - margin * 2
        let newHeight = bookName.sizeThatFits(CGSize(width: maxNameWidth, height: 60)).height
        card.addSubview(bookName)
        bookName.snp.makeConstraints {
            $0.top.equalTo(margin)
            $0.left.equalTo(coverImageView.snp.right).offset(margin * 2)
            if newHeight < 20 {
                $0.height.equalTo(20)
            } else {
                $0.height.equalTo(newHeight + 3)
            }
            $0.right.equalTo(0)
        }
        
        // 作者
        let authorNameLabel = UILabel()
        authorNameLabel.text = model.authorName
        authorNameLabel.textColor = PublicColors.titleColor
        authorNameLabel.font = UIFont.Avenir(size: 12)
        card.addSubview(authorNameLabel)
        authorNameLabel.snp.makeConstraints {
            $0.top.equalTo(bookName.snp.bottom).offset(margin + 2)
            $0.left.equalTo(bookName.snp.left).offset(0)
            $0.height.equalTo(16)
            $0.right.equalToSuperview()
        }

        // 标签
        let tagsView = UIView()
        card.addSubview(tagsView)
        tagsView.snp.makeConstraints {
            $0.bottom.equalTo(coverImageView.snp.bottom).offset(0)
            $0.left.equalTo(coverImageView.snp.right).offset(margin * 2)
            $0.height.equalTo(25)
            $0.right.equalToSuperview()
        }
        
        // 生成绘制书标签
        guard let _tagsString = model.tags else {
            return card
        }
        let tagsArr = _tagsString.split(separator: Character(","))
        if tagsArr.count > 0 {
            var lastLabel: UILabel?
            for i in 0..<tagsArr.count {
                let label = UILabel()
                label.text = String(tagsArr[i])
                label.textColor = PublicColors.titleColor
                label.font = UIFont.systemFont(ofSize: 10)
                //label.layer.borderWidth = 0.5
                //label.layer.borderColor = PublicColors.titleColor.cgColor
                label.layer.cornerRadius = 9
                label.layer.masksToBounds = true
                label.textAlignment = .center
                label.backgroundColor = PublicColors.mainGrayColor
                let labelNewWidth = label.sizeThatFits(CGSize(width: 150, height: 18)).width
                tagsView.addSubview(label)
                label.snp.makeConstraints {
                    $0.top.equalToSuperview()
                    if let _lastLabel = lastLabel {
                        $0.left.equalTo(_lastLabel.snp.right).offset(7)
                    } else {
                        $0.left.equalTo(0)
                    }
                    $0.height.equalTo(18)
                    $0.width.equalTo(labelNewWidth + 20)
                }
                
                lastLabel = label
            }
        }
        
        return card
    }
    
    public func updateData(with models: [LNBookStoreItemIntroModel], indexPath: IndexPath?) {
        self.models = models
        self.indexPath = indexPath
        
        if models.count <= 0 {
            return
        }
        categoryTitleLabel.text = models.first?.categoryName
        
        var lastCard: UIView?
        
        for i in 0..<models.count {
            let card = self.createBookCard(with: models[i], index: i)
            card.tag = i + 1
            if i < 3 {
                leftView.addSubview(card)
            } else if i >= 3 && i < 6 {
                if i == 3 {
                    lastCard = nil
                }
                centerView.addSubview(card)
            } else if i >= 6 && i < 9 {
                if i == 6 {
                    lastCard = nil
                }
                rightView.addSubview(card)
            }
            card.snp.makeConstraints {
                if let _lastCard = lastCard {
                    $0.top.equalTo(_lastCard.snp.bottom).offset(0)
                } else {
                    $0.top.equalToSuperview()
                }
                $0.left.right.equalToSuperview()
                $0.height.equalToSuperview().dividedBy(3)
            }
            lastCard = card
        }
    }
    
    @objc func didOpenBook(_ gesture: UIGestureRecognizer) {
        if let tag = gesture.view?.tag {
            let row = tag - 1
            if row >= 0 && row < self.models.count {
                let _indexPath = IndexPath(row: row, section: indexPath?.section ?? 0)
                cellDelegate?.bookStoreBestTableViewCellEvent(with: self, didOpenTheBook: _indexPath)
            }
        }
    }
    
}

