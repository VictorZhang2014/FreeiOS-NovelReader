//
//  LNBookChapterListViewController.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/4.
//

import UIKit
import MBProgressHUD
import SnapKit


class LNBookChapterListViewController: LNBaseViewController {
    
    public var bookId: Int = 0
    public var isNightMode: Bool = false
    
    public var handleSelectedChapter: ((_ bookId: Int, _ chapterId: Int) -> (Void))?
    
    public lazy var titleLabel = UILabel()
    public var currentReadingChapterId: Int = 0 // 当前正在阅读的chapterId，用于在cell上标记使用
    
    private lazy var backgroundAlphaView = UIView()
    private lazy var backArrowImg = UIButton()
    private lazy var chapterListView = UIView()
    private lazy var tableView = UITableView()
    private lazy var dataList: [LNBookChapterModel] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.clear
        
        self.setupViews()
        self.loadData()
    }
    
    private func setupViews() {
        backgroundAlphaView.backgroundColor = PublicColors.blackColor
        backgroundAlphaView.alpha = 0.0
        view.addSubview(backgroundAlphaView)
        backgroundAlphaView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) {
            UIView.animate(withDuration: 2) {
                self.backgroundAlphaView.alpha = 0.1
            }
        }
        
        var chapterListViewHeight = view.bounds.size.height - 205 - statusBarHeight
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            chapterListViewHeight = view.bounds.size.height - 205 - statusBarHeight - 150
        }
        
        let chapterListView = UIView()
        chapterListView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 15)
        chapterListView.backgroundColor = PublicColors.whiteColor
        self.chapterListView = chapterListView
        self.view.addSubview(chapterListView)
        chapterListView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(chapterListViewHeight)
        }
        
        // 顶部bar视图
        let topNavBarView = UIView()
        topNavBarView.backgroundColor = UIColor.clear
        chapterListView.addSubview(topNavBarView)
        topNavBarView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(15 + 35 + 15)
        }
        
        //titleLabel.text = "0 Chapters"
        titleLabel.textColor = PublicColors.chapterListTitleColor
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.AvenirMedium(size: 18)  // UIFont(name: "Avenir Medium", size: 18) // UIFont.boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping
        let newHeightForTitleLabel = titleLabel.sizeThatFits(CGSize(width: 200, height: 75)).height
        topNavBarView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(23)
            $0.width.equalTo(200)
            $0.height.equalTo(newHeightForTitleLabel + 5)
        }
        
        // 关闭按钮
        let backArrowImg = UIButton()
        backArrowImg.setImage(UIImage(named: "black-X-close-icon")?.sd_resizedImage(with: CGSize(width: 22, height: 22), scaleMode: .aspectFit), for: .normal)
        backArrowImg.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.backArrowImg = backArrowImg
        chapterListView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            $0.top.equalTo(10)
            $0.right.equalTo(-10)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
         
        self.tableView.separatorStyle = .none
        self.tableView.delegate = self
        self.tableView.dataSource = self
        chapterListView.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.top.equalTo(topNavBarView.snp.bottom).offset(0)
            $0.left.bottom.right.equalToSuperview()
            //$0.bottom.equalTo(-40)
        }
        
        toggleNightMode(with: isNightMode)
    }
    
    @objc func goBack() {
        self.backgroundAlphaView.removeFromSuperview()
        self.dismiss(animated: true, completion: nil)
    }

    private func loadData() {
        /*
        let cacheKey = "\(kBookChapterListDataKey)_\(bookId)"
        var isCached: Bool = false
        
        // 1.先从本地缓存里读取 -- 一律走网络请求
        if let chaptersArr = LNCacheUtil().getArrayValue(forKey: cacheKey) as? [[String:Any]] {
            self.parseDataArrayToModel(with: chaptersArr)
            if dataList.count > 0 {
                isCached = true
            }
        }
        if !isCached {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        
        // 2.从网络请求数据
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookChapterList, suffixParam: "?book_id=\(bookId)")
        httpManager.getWithUrl(apiurl) { (respDict, error) in
            //if !isCached {
                MBProgressHUD.hide(for: self.view, animated: true)
            //}
            if let _err = error {
                self.view.makeToast(_err.localizedDescription, position: .center)
                return
            }
            if let status = respDict?["status"] as? Bool {
                if !status {
                    if let message = respDict?["message"] as? String {
                        self.view.makeToast(message, position: .center)
                    }
                } else {
                    if let chaptersArr = respDict?["data"] as? [[String:Any]] {
                        debugPrint(chaptersArr)
                        self.parseDataArrayToModel(with: chaptersArr)

                        // 缓存起来
                        //FNCacheUtil().saveValue(chaptersArr, forKey: cacheKey)
                    }
                }
            }
        }*/
        
        let mockData = [
            ["id": 16883, "chapter_name": "Chapter 1 Intrusion of a Strange Man", "is_lock": 0],
            ["id": 16884, "chapter_name": "Chapter 2 Aflame With Sexual Desire", "is_lock": 0],
            ["id": 16885, "chapter_name": "Chapter 3 Marry Her ? She does Not Deserve", "is_lock": 0],
            ["id": 16886, "chapter_name": "Chapter 4 President 's New Wife", "is_lock": 0],
            ["id": 16887, "chapter_name": "Chapter 5 A Man Who Like a Demon", "is_lock": 0],
            ["id": 16888, "chapter_name": "Chapter 6 Give Herself Freely to a Man in the Morning?", "is_lock": 0],
            ["id": 16889, "chapter_name": "Chapter 7 The Little Wild Cat Must Belong to Him.", "is_lock": 0],
            ["id": 16890, "chapter_name": "Chapter 8 Unprecedented Humiliation", "is_lock": 1],
            ["id": 16891, "chapter_name": "Chapter 9 My Wife? You Do Not Deserve", "is_lock": 1],
            ["id": 16892, "chapter_name": "Chapter 10 Leo Howard's Gentleness", "is_lock": 1],
        ]
        self.parseDataArrayToModel(with: mockData)
    }
    
    private func parseDataArrayToModel(with dataArray: [[String:Any]]) {
        let haveReadChapterIds = LNFMDBManager.shared().getHaveReadChapterIdsBookId(bookId)

        var chapters: [LNBookChapterModel] = []
        for _dict in dataArray {
            let model = LNBookChapterModel.deserialize(from: _dict)
            if let _model = model {
                if _model.id == currentReadingChapterId {
                    _model.isReading = true
                }
                if haveReadChapterIds.filter({
                    if let _id = $0 as? Int {
                        if _id == _model.id {
                            return true
                        }
                    }
                    return false
                }).count > 0 {
                    _model.haveRead = true
                }
                chapters.append(_model)
            }
        }
        self.dataList = chapters
        self.tableView.reloadData()
        titleLabel.text = "\(chapters.count) Chapters"
    }
    
    // 日夜间模式切换
    private func toggleNightMode(with isNightMode: Bool) {
        if isNightMode {
            // 进入夜间模式
            titleLabel.textColor = FNReadConfig.shared().fontColor
            backArrowImg.setImage(UIImage(named: "white-X-close-icon")?.sd_resizedImage(with: CGSize(width: 22, height: 22), scaleMode: .aspectFit), for: .normal)
            chapterListView.backgroundColor = PublicColors.readPageNavigationBarColor
            tableView.backgroundColor = PublicColors.readPageNavigationBarColor
        } else {
            // 进入日间模式
            titleLabel.textColor = PublicColors.chapterListTitleColor
            backArrowImg.setImage(UIImage(named: "black-X-close-icon")?.sd_resizedImage(with: CGSize(width: 22, height: 22), scaleMode: .aspectFit), for: .normal)
            chapterListView.backgroundColor = PublicColors.whiteColor
            tableView.backgroundColor = PublicColors.whiteColor
        }
    }
    
    deinit {
        print("LNBookChapterListViewController has deallocated!")
    }
    
}



extension LNBookChapterListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = self.dataList[indexPath.row]
        let reuseCellId: String = "kReaderBookChapterListViewCellReuseId"
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseCellId) as? LNBookChapterListTableViewCell
        if cell == nil {
            cell = LNBookChapterListTableViewCell(style: .default, reuseIdentifier: reuseCellId)
        }
        cell?.textLabel?.text = model.chapterName
        cell?.textLabel?.font = UIFont.AvenirMedium(size: 16) // UIFont(name: "Avenir Medium", size: 16)
        
        if model.isReading {
            cell?.textLabel?.textColor = PublicColors.goldCoinColor
        } else if !(model.isReading) && model.haveRead {
            cell?.textLabel?.textColor = UIColor.lightGray
        } else {
            cell?.textLabel?.textColor = PublicColors.titleColor
        }
        
        cell?.toggleNightMode(with: isNightMode)
        cell?.hideLockBtn(isHidden: !model.isLock, index: indexPath.row)
        
        if let _cell = cell {
            return _cell
        }
        
        return UITableViewCell()
    }
    
}



extension LNBookChapterListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = self.dataList[indexPath.row]
        handleSelectedChapter?(bookId, model.id)
        goBack()
    }
    
}


fileprivate class LNBookChapterListTableViewCell : UITableViewCell {
    
    private var lockBtn: UIButton?
    private lazy var btmLine = UIView()
    private var btmLineHeightConstraint: Constraint?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        btmLine.backgroundColor = PublicColors.mainGrayColor
        contentView.addSubview(btmLine)
        btmLine.snp.makeConstraints {
            $0.left.equalTo(16)
            $0.right.equalTo(-16)
            $0.bottom.equalToSuperview()
            self.btmLineHeightConstraint = $0.height.equalTo(1.0).constraint
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideLockBtn(isHidden: Bool, index: Int)  {
        if index < 7 {
            lockBtn?.removeFromSuperview()
            accessoryView = nil
            return
        }
        lockBtn = UIButton()
        lockBtn?.frame = CGRect(x: 0, y: 0, width: 21, height: 20)
        //lockBtn?.setTitle("Locked", for: .normal)
        //lockBtn?.setTitleColor(PublicColors.subTitleColor, for: .normal)
        //lockBtn?.titleLabel?.font = UIFont(name: "Avenir Medium", size: 14) // UIFont.systemFont(ofSize: 14)
        //lockBtn?.titleLabel?.textAlignment = .center
        if isHidden {
            lockBtn?.setBackgroundImage(UIImage(named: "icon_chapter_unlocked"), for: .normal)
        } else {
            lockBtn?.setBackgroundImage(UIImage(named: "icon_chapter_lock"), for: .normal)
        }
        accessoryView = lockBtn
    }
    
    // 日夜间模式切换
    func toggleNightMode(with isNightMode: Bool) {
        if isNightMode {
            // 进入夜间模式
            backgroundColor = PublicColors.readPageNavigationBarColor
            btmLine.alpha = 0.3
            btmLineHeightConstraint?.update(offset: 0.5)
        } else {
            // 进入日间模式
            backgroundColor = PublicColors.whiteColor
            btmLine.alpha = 1.0
            btmLineHeightConstraint?.update(offset: 1.0)
        }
    }
    
}
