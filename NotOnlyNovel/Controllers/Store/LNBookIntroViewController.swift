//
//  LNBookIntroViewController.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/3.
//  小说介绍页

import UIKit
import MBProgressHUD

class LNBookIntroViewController: LNBaseViewController {

    public var bookId: Int = 0
    public var bookCover: String?
    public var tmpBookCoverImage: UIImage?
    public var bookName: String?
    
    private lazy var customNavigationBarView = UIView()
    private lazy var tableView = UITableView()
    
    private var itemModel: LNBookItemIntroModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.mainGrayColor
        
        setupNavigationBar()
        loadBookIntroData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        BuryPointUtil.beginLogPageView("小说介绍页面")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("小说介绍页面")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = PublicColors.whiteColor
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight)
        }
        
        let backArrowImg = UIButton(frame: CGRect())
        backArrowImg.setImage(UIImage(named: "black-left-arrow-icon"), for: .normal)
        backArrowImg.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backArrowImg.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.customNavigationBarView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            $0.top.equalTo(self.statusBarHeight)
            $0.left.equalTo(5)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
        
        let shareBtn = UIButton()
        shareBtn.setImage(UIImage(named: "gray-share-icon"), for: .normal)
        shareBtn.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        shareBtn.addTarget(self, action: #selector(shareApp), for: .touchUpInside)
        self.customNavigationBarView.addSubview(shareBtn)
        shareBtn.snp.makeConstraints {
            $0.top.equalTo(self.statusBarHeight)
            $0.right.equalTo(-5)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func shareApp() {
        if let name = URL(string: "https://apps.apple.com/us/app/lucknovel-web-online-novels/id1551893564"), !name.absoluteString.isEmpty {
            let objectsToShare = [name]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            present(activityVC, animated: true, completion: nil)
            BuryPointUtil.event("012", label: "书籍介绍页-分享")
        } else  {
            // show alert for not available
        }
    }
    
    private func setupViews() {
        // 背景虚化效果
        let backgroundBlurredImageView = UIImageView()
        var coverURL: URL? = nil
        if let coverUrl = bookCover {
            coverURL = URL(string: coverUrl)
        }
        if let coverUrl = itemModel?.bookCover {
            coverURL = URL(string: coverUrl)
        }
        if let _coverURL = coverURL {
            backgroundBlurredImageView.sd_setImage(with: _coverURL) { (downloadedImage, error, cacheType, imageUrl) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.customNavigationBarView.backgroundColor = UIColor.clear
                        self.tableView.backgroundColor = UIColor.clear
                    }
                }
            }
        }
        view.insertSubview(backgroundBlurredImageView, belowSubview: self.customNavigationBarView)
        backgroundBlurredImageView.snp.makeConstraints {
            //$0.left.top.right.equalToSuperview()
            //$0.height.equalTo(self.screenWidth * 1.15)
            $0.edges.equalToSuperview()
        }
        let effect = UIBlurEffect(style: .extraLight)
        let visualEffectView = UIVisualEffectView(effect: effect)
        view.insertSubview(visualEffectView, belowSubview: self.customNavigationBarView)
        visualEffectView.snp.makeConstraints {
            //$0.left.top.right.equalToSuperview()
            //$0.height.equalTo(self.screenWidth * 1.15)
            $0.edges.equalToSuperview()
        }
        
        tableView.backgroundColor = PublicColors.whiteColor
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.showsVerticalScrollIndicator = false
        //tableView.isScrollEnabled = false
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    private func loadBookIntroData() {
        let completionHandler: (([String:Any], Bool) -> Void) = { (dataDict: [String:Any], isRedrawing: Bool) in
            self.itemModel = LNBookItemIntroModel.deserialize(from: dataDict)
            self.itemModel?.introductionCollapse = false
            let contentLabel = self.calculateIntroTextHeight(with: self.itemModel?.introduction ?? "")
            if contentLabel.1 < 55 {
                self.itemModel?.introductionHeight = 55
            } else {
                self.itemModel?.introductionHeight = contentLabel.1 + 2
            }
            if isRedrawing {
                self.setupViews()
                self.setupBottomViews()
            }
            self.tableView.reloadData()
        }
        
        /*var isNotCached: Bool = true
        let cachedKey = "\(kBookIntroDataKey)_bookId-\(bookId)"
        if let cachedDataDict = LNCacheUtil().getDictValue(forKey: cachedKey) as? [String:Any] {
            completionHandler(cachedDataDict, true)
            isNotCached = false
        }
        if isNotCached {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookIntro, suffixParam: "?book_id=\(bookId)")
        httpManager.getWithUrl(apiurl) { (respDict, error) in
            if isNotCached {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            if let _err = error {
                self.view.makeToast(_err.localizedDescription, position: .center)
                return
            }
            if let status = respDict?["status"] as? Bool {
                if !status {
                    if let message = respDict?["message"] as? String {
                        self.view.makeToast(message)
                    }
                } else {
                    if let dataDict = respDict?["data"] as? [String:Any] {
                        debugPrint(dataDict)
                        completionHandler(dataDict, isNotCached)
                        
                        LNCacheUtil().saveDictValue(dataDict, forKey: cachedKey)
                    }
                }
            }
        }*/
        
        let mockData: [String:Any] = [
                        "author": "Bear Child",
                        "bookCover": "https://p.thoroscope.com/uploads/book/20201222/456858cc358d51d08f6a944800f028de.png",
                        "labels": "Gentleman",
                        "view_count": 171670,
                        "book_id": 510000192,
                        "write_status": "Updated 20 hrs ago",
                        "primary_label": "Gentleman",
                        "ratings": 9,
                        "total_words": 2709875,
                        "first_chapter_id": 10882,
                        "book_name": "My Dear Counselor",
                        "introduction": "In college Vivian gave advice about picking up the handsome guy named William for her best friend, but no one knew that she's also deeply in love with him. \r\n After graduation, her best friend broke up with William and went abroad to get married and have a child. \r\n A few years later, her best friend announced that she was officially divorced and would return to hometown to pursue her true love--William. \r\n By that time, Vivian had been living together with William for four years, but it was not the romantic relationship as everyone thought. They're just body mates. \r\n She felt that it was time for her to leave, so she secretly cleaned up all traces of herself and prepared to disappear. \r\n But the man pulled her and said to her, \"I love you, and whom I want is you!",
                        "chapter_count": 432
                    ]
        completionHandler(mockData, true)
    }
    
    deinit {
        print("LNBookIntroViewController has dealloated")
    }

}


extension LNBookIntroViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let aview = setupHeaderViews()
            cell.contentView.addSubview(aview)
            aview.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            return cell
        } else if indexPath.row == 1 {
            let cell = UITableViewCell()
            cell.backgroundColor = UIColor.clear
            cell.selectionStyle = .none
            let aview = setupContentIntroViews()
            cell.contentView.addSubview(aview)
            aview.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            return cell
        } else if indexPath.row == 2 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            let aview = setupAuthorViews()
            cell.contentView.addSubview(aview)
            aview.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            return cell
        }
        return UITableViewCell()
    }
}


extension LNBookIntroViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 270
        } else if indexPath.row == 1 {
            if let _bookIntroModel = itemModel {
                if _bookIntroModel.introductionCollapse || _bookIntroModel.introductionHeight == 0 {
                    // 收缩
                    return 15 + 115 + 55
                } else {
                    // 展开
                    return 15 + 115 + _bookIntroModel.introductionHeight
                }
            } else {
                return 7 + 170
            }
        } else if indexPath.row == 2 {
            return 7 + 130
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}


// 绘制UI
extension LNBookIntroViewController {
    
    private func setupHeaderViews() -> UIView {
        let bookHeaderView = UIView()
        bookHeaderView.backgroundColor = UIColor.clear

        let leftMargin: CGFloat = 15
        
        // 封面
        let coverImageView = UIImageView()
        if let _tmpBookCoverImage = tmpBookCoverImage {
            coverImageView.image = _tmpBookCoverImage
        }
        if let coverUrl = bookCover { // 先读取上一个页面传递过来的书籍封面
            coverImageView.sd_setImage(with: URL(string: coverUrl), completed: nil)
        }
        if let coverUrl = itemModel?.bookCover { // 再读取api请求返回的封面图
            coverImageView.sd_setImage(with: URL(string: coverUrl), completed: nil)
        }
        coverImageView.backgroundColor = PublicColors.mainGrayColor
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // 给书封面加阴影
            coverImageView.layer.shadowColor = UIColor.white.cgColor
            coverImageView.layer.shadowOpacity = 0.9
            coverImageView.layer.shadowOffset = CGSize(width: 7, height: 7)
            coverImageView.layer.shadowRadius = 4
            coverImageView.layer.shadowPath = UIBezierPath(roundedRect: coverImageView.bounds, cornerRadius: 4).cgPath
        }
        bookHeaderView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.left.equalTo(leftMargin)
            $0.width.equalTo(99)
            $0.height.equalTo(133)
        }

        // 书名
        let bookNameLabel = UILabel()
        if let _bookName = self.bookName {
            bookNameLabel.text = _bookName
        }
        bookNameLabel.text = itemModel?.bookName
        bookNameLabel.textColor = PublicColors.blackColor
        bookNameLabel.font = UIFont(name: "Avenir Heavy", size: KRatioX375(x: 20)) // UIFont.boldSystemFont(ofSize: 24)
        bookNameLabel.numberOfLines = 0
        bookNameLabel.lineBreakMode = .byCharWrapping
        let maxHalfWidth = view.bounds.size.width - leftMargin - 99 - 22 - 10
        let newHeight = bookNameLabel.sizeThatFits(CGSize(width: maxHalfWidth, height: 80)).height
        bookHeaderView.addSubview(bookNameLabel)
        bookNameLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.left.equalTo(coverImageView.snp.right).offset(22)
            if newHeight < 29 {
                $0.height.equalTo(29)
            } else {
                $0.height.equalTo(newHeight + 5)
            }
            $0.width.equalTo(maxHalfWidth)
        }
        
        // 作者名字
        let authorLabel = UILabel()
        authorLabel.text = itemModel?.author
        authorLabel.textColor = PublicColors.subTitleColor
        authorLabel.font = UIFont.boldSystemFont(ofSize: 14)
        bookHeaderView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints {
            $0.left.equalTo(coverImageView.snp.right).offset(22)
            $0.bottom.equalTo(bookNameLabel.snp.bottom).offset(25)
            $0.height.equalTo(20)
            $0.right.equalTo(-15)
        }
        
        // 字数
        let bookCharsCountLabel = UILabel()
        bookCharsCountLabel.text = "\(itemModel?.totalCountDisPlay() ?? "0") words" // | \(itemModel?.writeStatus ?? "")"
        bookCharsCountLabel.textColor = PublicColors.subTitleColor
        bookCharsCountLabel.font = UIFont.init(name: "Avenir Medium", size: KRatioX375(x: 14)) // UIFont.boldSystemFont(ofSize: 14)
        bookHeaderView.addSubview(bookCharsCountLabel)
        bookCharsCountLabel.snp.makeConstraints {
            $0.left.equalTo(coverImageView.snp.right).offset(22)
            $0.height.equalTo(20)
            $0.right.equalToSuperview()
            $0.bottom.equalTo(coverImageView.snp.bottom).offset(0)
        }
        
        // 阅读数视图
        let viewCountBGWidth: CGFloat = viewWidth - 16 * 2
        let viewCountBG = UIView()
        viewCountBG.backgroundColor = PublicColors.mainGrayColor
        viewCountBG.layer.cornerRadius = 14
        viewCountBG.layer.masksToBounds = true
        bookHeaderView.addSubview(viewCountBG)
        viewCountBG.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.bottom).offset(23)
            $0.left.equalTo(16)
            $0.width.equalTo(viewCountBGWidth)
            $0.height.equalTo(80)
        }
        
        // 阅读数
        let viewCountLabel = UILabel()
        viewCountLabel.text = "\(itemModel?.viewCount ?? 0)"
        viewCountLabel.textColor = PublicColors.titleColor
        viewCountLabel.font = UIFont(name: "Avenir Black", size: KRatioX375(x: 24)) // UIFont.boldSystemFont(ofSize: 24)
        let viewCountLabelNewWidth = viewCountLabel.sizeThatFits(CGSize(width: 130, height: 30)).width
        viewCountBG.addSubview(viewCountLabel)
        viewCountLabel.snp.makeConstraints {
            $0.left.equalTo(19)
            $0.top.equalTo(16)
            $0.height.equalTo(30)
            $0.width.equalTo(viewCountLabelNewWidth + 3)
        }
        
        let viewCountViewsLabel = UILabel()
        viewCountViewsLabel.text = "Views"
        viewCountViewsLabel.textColor = PublicColors.titleColor
        viewCountViewsLabel.font = UIFont(name: "Avenir Medium", size: KRatioX375(x: 16)) // UIFont.boldSystemFont(ofSize: 13)
        viewCountBG.addSubview(viewCountViewsLabel)
        viewCountViewsLabel.snp.makeConstraints {
            $0.left.equalTo(20)
            $0.bottom.equalTo(-16)
            $0.height.equalTo(15)
            $0.width.equalTo(50)
        }
        
        // 评分
        let rateLabel = UILabel()
        rateLabel.text = "\(itemModel?.ratings ?? 0)"
        rateLabel.textColor = PublicColors.subTitleColor
        rateLabel.font = UIFont(name: "Avenir Black", size: KRatioX375(x: 24)) //UIFont.boldSystemFont(ofSize: 24)
        viewCountBG.addSubview(rateLabel)
        rateLabel.snp.makeConstraints {
            $0.top.equalTo(16)
            $0.left.equalTo(viewCountBGWidth / 2 + 20)
            $0.height.equalTo(30)
            $0.width.equalTo(50)
        }
        
        // 五星icon
        let fiveStarImageView = UIImageView()
        fiveStarImageView.image = UIImage(named: "book-rate-five-star-icon")
        viewCountBG.addSubview(fiveStarImageView)
        fiveStarImageView.snp.makeConstraints {
            $0.left.equalTo(viewCountBGWidth / 2 + 20)
            $0.bottom.equalTo(-16)
            $0.width.equalTo(106)
            $0.height.equalTo(15)
        }
        
        return bookHeaderView
    }
    
    private func setupContentIntroViews() -> UIView {
        let contentIntroView = UIView()
        contentIntroView.backgroundColor = PublicColors.whiteColor
        contentIntroView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 15)

        /*let topLine = UIView()
        topLine.backgroundColor = PublicColors.mainGrayColor
        contentIntroView.addSubview(topLine)
        topLine.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(7)
        }*/
        
        let contentLabel = self.calculateIntroTextHeight(with: itemModel?.introduction ?? "")
        contentLabel.0.isUserInteractionEnabled = true
        contentLabel.0.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didShowMoreIntro)))
        contentIntroView.addSubview(contentLabel.0)
        contentLabel.0.snp.makeConstraints {
            $0.top.equalTo(31)
            $0.left.equalTo(16)
            $0.width.equalTo(viewWidth - 16 * 2)
            if let _bookIntroModel = self.itemModel {
                if _bookIntroModel.introductionCollapse || _bookIntroModel.introductionHeight == 0 {
                    $0.height.equalTo(55)
                } else {
                    $0.height.equalTo(_bookIntroModel.introductionHeight)
                }
            } else {
                $0.height.equalTo(55)
            }
        }
        
        let moreBtn = UIButton()
        if let _bookIntroModel = self.itemModel {
            moreBtn.setTitle(_bookIntroModel.introductionCollapse ? "Show" : "Hide", for: .normal)
        }
        moreBtn.setTitleColor(PublicColors.titleColor, for: .normal)
        moreBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        moreBtn.addTarget(self, action: #selector(didShowMoreIntro), for: .touchUpInside)
        contentIntroView.addSubview(moreBtn)
        moreBtn.snp.makeConstraints {
            $0.top.equalTo(contentLabel.0.snp.bottom).offset(-5)
            $0.right.equalTo(-16)
            $0.width.equalTo(40)
            $0.height.equalTo(15)
        }
        
        // 标签
        let tagsView = UIView()
        contentIntroView.addSubview(tagsView)
        tagsView.snp.makeConstraints {
            $0.top.equalTo(contentLabel.0.snp.bottom).offset(10)
            $0.left.equalTo(16)
            $0.right.equalTo(-16)
            $0.height.equalTo(25)
        }
        
        // 生成绘制书标签
        if let _itemModel = itemModel {
            if _itemModel.labels.count <= 0 {
                if let label = _itemModel.primaryLabel {
                    itemModel?.labels = [label]
                }
            }
            if let tagsArr = itemModel?.labels {
                var totalTagWidth: CGFloat = 0
                if tagsArr.count > 0 {
                    var lastLabel: UILabel?
                    for i in 0..<tagsArr.count {
                        let label = UILabel()
                        label.text = tagsArr[i]
                        label.textColor = PublicColors.titleColor
                        label.font = UIFont(name: "Avenir Medium", size: 11) // UIFont.systemFont(ofSize: 11)
                        label.backgroundColor = PublicColors.mainGrayColor
                        label.layer.cornerRadius = 11.5
                        label.layer.masksToBounds = true
                        label.textAlignment = .center
                        let labelNewWidth = label.sizeThatFits(CGSize(width: 150, height: 25)).width
                        totalTagWidth += (7 + labelNewWidth + 20)
                        if (16 + totalTagWidth + 16) > view.bounds.size.width {
                            // 标签已经超出了当前界面，则不再继续显示剩余的标签
                            break
                        }
                        tagsView.addSubview(label)
                        label.snp.makeConstraints {
                            $0.top.equalToSuperview()
                            if let _lastLabel = lastLabel {
                                $0.left.equalTo(_lastLabel.snp.right).offset(7)
                            } else {
                                $0.left.equalTo(0)
                            }
                            $0.height.equalTo(23)
                            $0.width.equalTo(labelNewWidth + 20)
                        }
                        
                        lastLabel = label
                    }
                }
            }
        }
        
        let chapterNameLabel = UILabel()
        chapterNameLabel.text = "\(itemModel?.chapterCount ?? 0) Chapters" //"0 Chapters"
        chapterNameLabel.textColor = PublicColors.titleColor
        chapterNameLabel.isUserInteractionEnabled = true
        chapterNameLabel.font = UIFont.systemFont(ofSize: 16)
        contentIntroView.addSubview(chapterNameLabel)
        chapterNameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewChaptersVC)))
        chapterNameLabel.snp.makeConstraints {
            $0.left.equalTo(16)
            $0.bottom.equalTo(-20)
            $0.width.equalToSuperview().dividedBy(2)
            $0.height.equalTo(20)
        }
        
        let updatedJustNowLabel = UILabel()
        updatedJustNowLabel.text = "Updated Recently"
        updatedJustNowLabel.textColor = PublicColors.subTitleColor
        updatedJustNowLabel.isUserInteractionEnabled = true
        updatedJustNowLabel.font = UIFont.AvenirMedium(size: 14)
        updatedJustNowLabel.textAlignment = .right
        updatedJustNowLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewChaptersVC)))
        contentIntroView.addSubview(updatedJustNowLabel)
        updatedJustNowLabel.snp.makeConstraints {
            $0.right.equalTo(-40)
            $0.bottom.equalTo(-20)
            $0.width.equalToSuperview().dividedBy(2)
            $0.height.equalTo(20)
        }
        
        let viewChaptersBtn = UIButton()
        viewChaptersBtn.setImage(UIImage(named: "tableviewcell-gray-disclosure-indicator"), for: .normal)
        viewChaptersBtn.addTarget(self, action: #selector(viewChaptersVC), for: .touchUpInside)
        contentIntroView.addSubview(viewChaptersBtn)
        viewChaptersBtn.snp.makeConstraints {
            $0.right.equalTo(-8)
            $0.bottom.equalTo(-20)
            $0.width.equalTo(25)
            $0.height.equalTo(20)
        }

        return contentIntroView
    }
    
    private func setupAuthorViews() -> UIView {
        // 作者简介
        let authorView = UIView()
        authorView.backgroundColor = PublicColors.whiteColor

        let topLine = UIView()
        topLine.backgroundColor = PublicColors.mainGrayColor
        authorView.addSubview(topLine)
        topLine.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(7)
        }
        /*
        let leftMargin: CGFloat = 16
        
        let aboutLabel = UILabel()
        aboutLabel.textColor = PublicColors.titleColor
        aboutLabel.font = UIFont.boldSystemFont(ofSize: 22)
        aboutLabel.text = "About the Author"
        authorView.addSubview(aboutLabel)
        aboutLabel.snp.makeConstraints {
            $0.top.left.equalTo(leftMargin)
            $0.right.equalToSuperview()
            $0.height.equalTo(24)
        }
        
        // 封面
        let coverImageView = UIImageView()
        if let coverUrl = itemModel?.bookCover {
            coverImageView.sd_setImage(with: URL(string: coverUrl), completed: nil)
        }
        coverImageView.backgroundColor = PublicColors.mainGrayColor
        authorView.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.top.equalTo(aboutLabel.snp.bottom).offset(18)
            $0.left.equalTo(leftMargin)
            $0.width.height.equalTo(37)
        }

        // 作者名
        let authorName = UILabel()
        authorName.text = itemModel?.author
        authorName.textColor = PublicColors.titleColor
        authorName.font = UIFont.boldSystemFont(ofSize: 14)
        authorView.addSubview(authorName)
        authorName.snp.makeConstraints {
            $0.top.equalTo(coverImageView.snp.top).offset(0)
            $0.left.equalTo(coverImageView.snp.right).offset(12)
            $0.height.equalTo(20)
            $0.right.equalTo(-5)
        }

        // 介绍
        let introLabel = UILabel()
        introLabel.text = "0 Stories"
        introLabel.textColor = PublicColors.subTitleColor
        introLabel.font = UIFont.systemFont(ofSize: 12)
        authorView.addSubview(introLabel)
        introLabel.snp.makeConstraints {
            $0.height.equalTo(13)
            $0.right.equalTo(-5)
            $0.left.equalTo(coverImageView.snp.right).offset(12)
            $0.bottom.equalTo(coverImageView.snp.bottom).offset(0)
        }*/
        
        return authorView
    }
    
    private func setupBottomViews() {
        // 底部阅读按钮
        let btmReadView = UIView()
        btmReadView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 15)
        btmReadView.backgroundColor = PublicColors.mainGrayColor
        view.addSubview(btmReadView)
        btmReadView.snp.makeConstraints {
            $0.height.equalTo(85)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        /*let btmReadTranslucentView = UIView()
        btmReadTranslucentView.backgroundColor = PublicColors.mainGrayColor
        btmReadView.addSubview(btmReadTranslucentView)
        btmReadTranslucentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }*/
        
        let favoriteBtn = UIButton()
        favoriteBtn.setImage(UIImage(named: "book-favorite-icon"), for: .normal)
        favoriteBtn.setImage(UIImage(named: "book-favorite-selected-icon"), for: .selected)
        favoriteBtn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        favoriteBtn.addTarget(self, action: #selector(didAddToFavoriteBook(_:)), for: .touchUpInside)
        btmReadView.addSubview(favoriteBtn)
        favoriteBtn.snp.makeConstraints {
            if LNDeviceUtil.shared().isiPhoneXFamily {
                $0.top.equalTo(10)
            } else {
                $0.centerY.equalToSuperview()
            }
            $0.width.height.equalTo(44)
            $0.left.equalTo(20)
        }
        
        if let _bookId = itemModel?.bookId {
            let model = LNFMDBManager.shared().getOneBookThatHasRead(withBookId: _bookId)
            if model != nil {
                favoriteBtn.isSelected = true
            }
        }
        
        let readBtn = UIButton()
        readBtn.applyGradientFromLeftToRight(colours: [PublicColors.mainLightPinkColor, PublicColors.mainPinkColor])
        readBtn.setTitle("READ", for: .normal)
        readBtn.setTitleColor(PublicColors.whiteColor, for: .normal)
        readBtn.titleLabel?.font = UIFont.ArialRoundedMTBold(size: 19)
        readBtn.layer.cornerRadius = 22
        readBtn.layer.masksToBounds = true
        readBtn.addTarget(self, action: #selector(willReadBook), for: .touchUpInside)
        btmReadView.addSubview(readBtn)
        readBtn.snp.makeConstraints {
            if LNDeviceUtil.shared().isiPhoneXFamily {
                $0.top.equalTo(10)
            } else {
                $0.centerY.equalToSuperview()
            }
            $0.height.equalTo(44)
            $0.width.equalTo(210)
            $0.centerX.equalToSuperview()
        }
    }
    
    @objc private func didShowMoreIntro() {
        if let _bookIntroModel = itemModel {
            itemModel?.introductionCollapse = !_bookIntroModel.introductionCollapse
        }
        tableView.reloadData()
        BuryPointUtil.event("015", label: "书籍介绍页-查看更多介绍")
    }
    
    // 计算介绍的文本高度
    private func calculateIntroTextHeight(with text: String) -> (UILabel, CGFloat) {
        let contentLabel = UILabel()
        contentLabel.text = text
        contentLabel.textColor = PublicColors.subTitleColor
        contentLabel.font = UIFont.AvenirMedium(size: 14)
        contentLabel.numberOfLines = 0
        contentLabel.lineBreakMode = .byWordWrapping
        let newHeight = contentLabel.sizeThatFits(CGSize(width: viewWidth - 16 * 2, height: 150)).height
        return (contentLabel, newHeight)
    }
    
    @objc func didAddToFavoriteBook(_ button: UIButton) {
        button.isSelected = true
        if button.isSelected {
            view.makeToast("You’ve favourited the book to your library!", position: .center)
        }
        
        // 添加到书架（本地缓存）
        guard let _itemModel = itemModel else { return }
        let bookCoverUrl = (bookCover ?? _itemModel.bookCover) ?? ""
        LNFMDBManager.shared().addBookToBookrack(withBookId: _itemModel.bookId, chapterCount: _itemModel.chapterCount, bookCover: bookCoverUrl, bookName: _itemModel.bookName ?? "", authorName: _itemModel.author ?? "", labels: _itemModel.labels.joined(separator: ","), lastChapterId: _itemModel.firstChapterId, progress: 0)
    }
    
    @objc func willReadBook() {
        /*if FNUserModelUtil.shared().model == nil {
            let vc = FNSignInViewController()
            vc.modalPresentationStyle = .fullScreen
            self.present(vc, animated: true, completion: nil)
            return
        }*/
        
        guard let _itemModel = itemModel else { return }
        
        let detailVC = LNReadingDetailViewController()
        detailVC.bookId = self.bookId
        detailVC.specifiedChapterId = _itemModel.firstChapterId
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        
        /*let vc = LNReaderDetailViewController()
        vc.bookId = self.bookId
        vc.lastChapterId = _itemModel.firstChapterId
        self.navigationController?.pushViewController(vc, animated: true)*/
        
        BuryPointUtil.event("013", label: "书籍介绍页-点击阅读")
        
        // 添加到书架（本地缓存）
        let bookCoverUrl = (bookCover ?? _itemModel.bookCover) ?? ""
        LNFMDBManager.shared().addBookToBookrack(withBookId: _itemModel.bookId, chapterCount: _itemModel.chapterCount, bookCover: bookCoverUrl, bookName: _itemModel.bookName ?? "", authorName: _itemModel.author ?? "", labels: _itemModel.labels.joined(separator: ","), lastChapterId: _itemModel.firstChapterId, progress: 0)
    }
    
    // 查看章节列表
    @objc private func viewChaptersVC() {
        guard let _itemModel = itemModel else { return }
        
        let chapterListVC = LNBookChapterListViewController()
        chapterListVC.bookId = self.bookId
        chapterListVC.titleLabel.text = "\(_itemModel.chapterCount) Chapters"
        chapterListVC.handleSelectedChapter = { (bookId: Int, chapterId: Int) in
            // 跳转到指定章节
            
            let detailVC = LNReadingDetailViewController()
            detailVC.bookId = bookId
            detailVC.specifiedChapterId = chapterId
            detailVC.lastChapterId = chapterId
            self.navigationController?.pushViewController(detailVC, animated: true)
            
            //let vc = LNReaderDetailViewController()
            //vc.bookId = bookId
            //vc.specifiedChapterId = chapterId
            //vc.lastChapterId = chapterId
            //self.navigationController?.pushViewController(vc, animated: true)
            
            // 添加到书架（本地缓存）
            let bookCoverUrl = (self.bookCover ?? _itemModel.bookCover) ?? ""
            LNFMDBManager.shared().addBookToBookrack(withBookId: _itemModel.bookId, chapterCount: _itemModel.chapterCount, bookCover: bookCoverUrl, bookName: _itemModel.bookName ?? "", authorName: _itemModel.author ?? "", labels: _itemModel.labels.joined(separator: ","), lastChapterId: chapterId, progress: 0)
        }
        chapterListVC.modalPresentationStyle = .overFullScreen
        present(chapterListVC, animated: true, completion: nil)
        BuryPointUtil.event("014", label: "书籍介绍页-查看章节")
    }
    
}
