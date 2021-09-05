//
//  LNReadingDetailViewController.swift
//  NotOnlyNovel
//
//  Created by JohnnyCheung on 2021/2/4.
//

import UIKit
import MBProgressHUD
import SnapKit
import MJRefresh


class LNReadingDetailViewController: LNBaseViewController {

    public var bookId: Int = 0
    
    // 加载顺序为:
    //  1.指定章节
    //  2.最后一次阅读的章节
    //  3.从本书第一章开始
    public var specifiedChapterId: Int = 0 // 加载指定的章节
    public var lastChapterId: Int = 0 // 最后一次阅读的章节ID，如果是首次，那就是第一章的章节的ID
    
    private lazy var customNavigationBarView = UIView()
    private var customNavigationBarViewTopConstraint: Constraint?
    private lazy var navTitleLabel = UILabel()
    private lazy var backArrowImg = UIButton()
    private var payToReadBtn: UIView?
    
    private lazy var customFooterView = UIView()
    private var customFooterViewBottomConstrait: Constraint?
    private lazy var chapterBtn = UIButton()
    //private lazy var textSizeBtn = UIButton()
    private let dayNightBtn = UIButton()
    
    private lazy var isHiddenNavBar: Bool = false // 是否隐藏导航栏
    private lazy var isNightMode: Bool = false //FNReadConfig.shared().getDarkMode() // 是否是夜间模式
    
    private var collectionView: UICollectionView?
    private lazy var waterFallCollectionViewReuseCellIdentifier: String = "kReaderDetailWaterFallCollectionViewReuseCellIdentifier"
    
    private lazy var chapterDetailList: [LNBookChapterDetailModel] = [] // 章节详情
    private lazy var currentReadingChapterId: Int = 0 // 当前正在阅读的章节Id
    
    //private lazy var isRequestingNextChapter: Bool = false // 是否正在请求下一章节
    //private lazy var isRequestingNextCoinsChapter: Bool = false // 是否正在请求下一收费章节
    
    private var refreshFooter: MJRefreshAutoNormalFooter?
    
    //override var prefersStatusBarHidden: Bool {
    //    return !isHiddenNavBar
    //}
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContentTextReadingViews()
        setupNavigationBar()
        setupFooterView()
        loadDefaultChapterModel()
        //toggleNightMode()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserSignedIn(_:)), name: NSNotification.Name(rawValue: NotificationNameUserSignedInSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnlockChaptersSuccessNotification(_:)), name: NSNotification.Name(rawValue: NotificationNameUserUnlockChaptersSuccess), object: nil)
    }
    
    // 用户登录成功
    @objc func onSuccessOfUserSignedIn(_ notification: Notification) {
        currentLoggedInUserModel = LNUserModelUtil.shared().model
    }
    
    // 章节购买成功通知
    @objc func didUnlockChaptersSuccessNotification(_ notification: Notification) {
        if let _chapter_id = notification.userInfo?["chapter_id"] as? Int {
            chapterDetailList = chapterDetailList.filter { $0.chapterId != _chapter_id } // 先删除付费章节的预览内容
            loadChapterData(with: _chapter_id) // 然后重新请求
        }
    }
    
    @objc func didTapTextContentView() {
        isHiddenNavBar = !isHiddenNavBar
        if isHiddenNavBar {
            // 显示
            customNavigationBarViewTopConstraint?.update(offset: 0)
            customFooterViewBottomConstrait?.update(offset: 0)
        } else {
            // 隐藏
            customNavigationBarViewTopConstraint?.update(offset: -100)
            customFooterViewBottomConstrait?.update(offset: 100)
        }
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func setupContentTextReadingViews() {
        let waterfallLayout = LNReadingDetailCollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: waterfallLayout)
        collectionView.backgroundColor = UIColor.clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LNReadingDetailCollectionViewCell.self, forCellWithReuseIdentifier: self.waterFallCollectionViewReuseCellIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.alwaysBounceVertical = false
        collectionView.bounces = false
        //collectionView.contentInset = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        
        let refreshFooter = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            if let _nextChapterId = self?.chapterDetailList.last?.nextChapterId {
                if _nextChapterId > 0 {
                    self?.loadChapterData(with: _nextChapterId, endRefreshing: true)
                }
            }
        })
        refreshFooter.setTitle("Loading next chapter..", for: .refreshing)
        refreshFooter.setTitle("Pull to load next chapter", for: .idle)
        refreshFooter.setTitle("Release to load next chapter", for: .pulling)
        collectionView.mj_footer = refreshFooter
        self.refreshFooter = refreshFooter
        view.addSubview(collectionView)
        self.collectionView = collectionView
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = PublicColors.whiteColor //PublicColors.readPageNavigationBarColorAtDay
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            self.customNavigationBarViewTopConstraint = $0.top.equalToSuperview().constraint
            $0.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight + 5)
        }
         
        navTitleLabel.textColor = FNReadConfig.shared().fontColor
        navTitleLabel.font = UIFont.AvenirMedium(size: FNReadConfig.shared().fontSize - 1)
        navTitleLabel.textAlignment = .center
        self.customNavigationBarView.addSubview(navTitleLabel)
        navTitleLabel.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight) 
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.height.equalTo(44)
        }
        
        backArrowImg.backgroundColor = PublicColors.whiteColor //.readPageNavigationBarColorAtDay
        backArrowImg.setImage(UIImage(named: "black-left-arrow-icon"), for: .normal)
        backArrowImg.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backArrowImg.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.customNavigationBarView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight)
            $0.left.equalTo(5)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
    }
    
    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func setupFooterView() {
        var footerHeight: CGFloat = 80
        if LNDeviceUtil.shared().isiPhoneXFamily {
            footerHeight = 100
        }
        self.customFooterView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        self.customFooterView.backgroundColor = PublicColors.whiteColor //.readPageNavigationBarColorAtDay
        self.view.addSubview(self.customFooterView)
        self.customFooterView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            self.customFooterViewBottomConstrait = $0.bottom.equalToSuperview().constraint
            $0.height.equalTo(footerHeight)
        }
        
        /*
        let grayView = UIView()
        grayView.backgroundColor = UIColor(rgb: 0x191A1B)
        self.customFooterView.addSubview(grayView)
        grayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }*/
        
        let btnsView = UIView()
        self.customFooterView.addSubview(btnsView)
        btnsView.snp.makeConstraints {
            $0.height.equalTo(footerHeight)
            $0.left.bottom.right.equalToSuperview()
        }
         
        let btnWidth: CGFloat = 44
        let btnMargin: CGFloat = (self.view.bounds.size.width - btnWidth * 2) / 3
        
        // 章节按钮
        chapterBtn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        chapterBtn.setImage(UIImage(named: "show-chaper-list-black"), for: .normal)
        chapterBtn.addTarget(self, action: #selector(didShowChapterList), for: .touchUpInside)
        btnsView.addSubview(chapterBtn)
        chapterBtn.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.left.equalTo(btnMargin)
            $0.width.height.equalTo(44)
        }
        
        /*
        // 文字大小
        textSizeBtn.setImage(UIImage(named: "novel-text-size-black"), for: .normal)
        btnsView.addSubview(textSizeBtn)
        textSizeBtn.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(chapterBtn.snp.right).offset(btnMargin)
            $0.width.height.equalTo(44)
        }*/
        
        // 日夜间模式切换按钮
        dayNightBtn.imageEdgeInsets = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
        dayNightBtn.setImage(UIImage(named: "detail-night-mode"), for: .normal)
        dayNightBtn.addTarget(self, action: #selector(didChangeNightOrDayModel(_:)), for: .touchUpInside)
        btnsView.addSubview(dayNightBtn)
        dayNightBtn.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.right.equalTo(-btnMargin)
            $0.width.height.equalTo(44)
        }
    }
    
    // 日夜间模式切换
    @objc func didChangeNightOrDayModel(_ button: UIButton) {
        button.isSelected = !button.isSelected
        toggleNightMode()
    }
    
    func toggleNightMode() {
        isNightMode = !isNightMode
        
        if isNightMode {
            // 进入夜间模式
            view.backgroundColor = PublicColors.darkModeBackground
            collectionView?.backgroundColor = PublicColors.darkModeBackground
            self.refreshFooter?.backgroundColor = PublicColors.darkModeBackground
            
            dayNightBtn.setImage(UIImage(named: "detail-day-mode"), for: .normal)
            
            customNavigationBarView.backgroundColor = PublicColors.readPageNavigationBarColor
            navTitleLabel.textColor = .white.withAlphaComponent(0.8)
            backArrowImg.backgroundColor = PublicColors.readPageNavigationBarColor
            backArrowImg.setImage(UIImage(named: "white-left-arrow-icon"), for: .normal)
        
            customFooterView.backgroundColor = PublicColors.readPageNavigationBarColor
            chapterBtn.setImage(UIImage(named: "show-chaper-list-white"), for: .normal)
            //textSizeBtn.setImage(UIImage(named: "novel-text-size-white"), for: .normal)
            
        } else {
            // 进入日间模式
            view.backgroundColor = PublicColors.dayModeBackground
            collectionView?.backgroundColor = PublicColors.dayModeBackground
            self.refreshFooter?.backgroundColor = PublicColors.dayModeBackground
            
            dayNightBtn.setImage(UIImage(named: "detail-night-mode"), for: .normal)
            
            customNavigationBarView.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
            navTitleLabel.textColor = FNReadConfig.shared().fontColor
            backArrowImg.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
            backArrowImg.setImage(UIImage(named: "black-left-arrow-icon"), for: .normal)
            
            customFooterView.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
            chapterBtn.setImage(UIImage(named: "show-chaper-list-black"), for: .normal)
            //textSizeBtn.setImage(UIImage(named: "novel-text-size-black"), for: .normal)
        }
        
        collectionView?.reloadData()
        
        //FNReadConfig.shared().cacheDarkMode(isNightMode)
        
        if isNightMode {
            BuryPointUtil.event("017", label: "书籍详情页-切换Night模式")
        } else {
            BuryPointUtil.event("018", label: "书籍详情页-切换Day模式")
        }
    }
    
    // 显示章节列表
    @objc func didShowChapterList() {
        let chapterListVC = LNBookChapterListViewController()
        chapterListVC.bookId = self.bookId
        chapterListVC.currentReadingChapterId = currentReadingChapterId
        chapterListVC.titleLabel.text = "Chapters"
        chapterListVC.handleSelectedChapter = { (bookId: Int, chapterId: Int) in
            // 切换章节
            self.chapterDetailList = []
            self.loadChapterData(with: chapterId)
            BuryPointUtil.event("020", label: "书籍详情页-章节列表-切换章节")
        }
        chapterListVC.isNightMode = isNightMode
        chapterListVC.modalPresentationStyle = .overFullScreen
        present(chapterListVC, animated: true, completion: nil)
        BuryPointUtil.event("019", label: "书籍详情页-查看章节列表")
    }
    
    private func loadDefaultChapterModel() {
        // 加载顺序为:
        //  1.指定章节
        //  2.最后一次阅读的章节
        //  3.从本书第一章开始
        
        if specifiedChapterId > 0 {
            loadChapterData(with: specifiedChapterId)
            return
        }
        
        // 从DB缓存中查询最后阅读的那一章节
        let lastReadingChapter = LNFMDBManager.shared().getLastReadingChapter(fromBookId: bookId)
        if let chapterId = lastReadingChapter.first as? Int, chapterId > 0, let _ = lastReadingChapter.last {
            // 加载最后阅读的那一章节
            loadChapterData(with: chapterId)
            return
        }
        
        loadChapterData(with: lastChapterId)
    }
    
    // 加载书的某一章节的具体内容
    private func loadChapterData(with chapterId: Int, endRefreshing: Bool = false) {
        var hud: MBProgressHUD?
        if !endRefreshing {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.label.text = "The chapter is downloading..."
        }
        
        self.payToReadBtn?.removeFromSuperview()
        self.payToReadBtn = nil
        
        let completionHandler: (([String:Any]) -> Void) = { (dataDict: [String:Any]) in
            hud?.hide(animated: true)
            let model = LNBookChapterDetailModel.deserialize(from: dataDict)
            if let _model = model {
                self.navTitleLabel.text = _model.chapterName
                
                let headerContent = "\r\n\r\n \(_model.chapterName ?? "") \r\n\r\n"
                let footerContent = "\r\n\r\n\r\n\r\n ↓↓↓ Go to read next chapter... ↓↓↓ \r\n\r\n"
                _model.headerTitleDesc = headerContent
                _model.footerTitleDesc = footerContent
                if let _content = _model.content?.replacingOccurrences(of: "\r\n", with: "\r\n \r\n") {
                    if !_model.isPaid && _model.coins > 0 {
                        // 需要付款的章节，在未成功支付时，仅显示预览一小部分章节内容和页面中间的付款按钮
                        _model.content = "\(headerContent)\(_content)"
                    } else {
                        _model.content = "\(headerContent)\(_content)\(footerContent)"
                    }
                }
                
                if let _content = _model.content, _content.count > 0 {
                    // 此章节不需要支付，直接显示到界面上
                    self.chapterDetailList = self.chapterDetailList.filter { $0.chapterId != _model.chapterId }
                    self.chapterDetailList.append(_model)
                    
                    // 存储此章节已读
                    LNFMDBManager.shared().addingHaveReadChapterIntoTable(withBookId: self.bookId, chapterId: _model.chapterId)
                    
                    if !_model.isPaid && _model.coins > 0 {
                        // 如果只有chapterDetailList只有一章节，并且是待支付的，那么就显示一个按钮
                        self.payToReadBtn = self.createPayToReadBtn()
                        
                        // 弹出付费界面，或者自动支付
                        self.payTheLockedChapter(detailModel: _model)
                    }
                    
                    if endRefreshing {
                        self.view.makeToast("The next chapter is ready for you to read~", duration: 1.5)
                    }
                }
            }
            self.collectionView?.reloadData()
            
            // 缓存起来
            // FNCacheUtil().saveValue(dataDict, forKey: cacheKey)
            
            if endRefreshing {
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                    // 1.只所以需要把上一章节的文本内容滑到底部，是因为在UICollectionView滑动到底部时，它会自动的把上一章节不可见的UITextView的text滑动到首部
                    var indexPath: IndexPath?
                    if self.chapterDetailList.count > 0 {
                        if self.chapterDetailList.count == 1 {
                            indexPath = IndexPath(item: 0, section: 0)
                        } else {
                            indexPath = IndexPath(item: self.chapterDetailList.count - 2, section: 0)
                        }
                    }
                    if let _indexPath = indexPath, let cell = self.collectionView?.cellForItem(at: _indexPath) as? LNReadingDetailCollectionViewCell {
                        cell.scrollToBottom()
                    }
                    // 2.请求完数据后，自动滑动到下一章节
                    self.collectionView?.scrollToItem(at: IndexPath(item: self.chapterDetailList.count - 1, section: 0), at: .top, animated: true)
                    // self.view.makeToast("This is the last chapter~");
                    self.collectionView?.mj_footer?.endRefreshing()
                }
            }
        }
        
        // 2.从网络请求数据
        /*let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookChapterDetail, suffixParam: "?chapter_id=\(chapterId)")
        httpManager.getWithUrl(apiurl) { (respDict, error) in
            hud?.hide(animated: true)
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
                    if let dataDict = respDict?["data"] as? [String:Any] {
                        debugPrint(dataDict)
                        completionHandler((dataDict))
                    }
                }
            }
        }*/
        
        let mockData: [String: Any] = [
            "prev_chapter_id": 0,
            "chapter_id": 10882,
            "next_chapter_id": 10883,
            "min_chapter_id": 10882,
            "max_chapter_id": 11313,
            "word_num": 3822,
            "book_id": 510000192,
            "is_paid": 0,
            "coins": 0,
            "chapter_name": "Chapter 1 Our Relationship",
            "content": """
                    Vivian just washed the dishes. When she went to the living room to take paper to wipe the water on the hand, she received a call from her best friend.
                        
                        "Vivian, I'm going home! I finally won my divorce case!"Angie's voice was cheerful.

                        Vivian was so surprised that do not know what to respond to her for a long time.

                        Angie's voice continued to come from the cellphone, "Vivian, you are right. Everyone have the right to pursue happiness. I love William, and I should not miss him!"

                        "Well."replied Vivian, and she unexpectedly found herself sound a little dry.

                        "I will deal with the things here as soon as possible and back in a week at most. See you then, Vivian!"Angie hanged up the phone soon. Vivian stood there with the phone and the beep sound has been ringing in her ears.

                        A slender figure from the bedroom came out, saw Vivian with a mobile phone standing there, and asked, "what is wrong?"

                        Vivian looked over her shoulder.

                        William must have just taken a bath. He was wearing a dark blue robe, wiping his wet hair with a towel.

                        "Nothing."Vivian put the phone into the bag, casually said, "Angie said she was coming back."

                        When bending over to put down the phone, Vivian peeked at William, who was still wiping his hair, but his movement was slow down a bit because of her words, and the rigid face was as cold as always.

                        "Well."This matter seemed to have little effect on William, "Go take a bath."

                        "Ok."Vivian's nose became sore.

                        After tidying up the living room, Vivian went back to her room and took her pajamas to the bathroom. Holding her knees in the bathtub, she remained in a daze for nearly an hour.

                        When she went out, the light in the bedroom had been turned off, leaving only a small lamp on the nightstand, warm and yellow.

                        William did not rest all day because of two big cases. After the trial, he had time to come back. He went to bed very early these days.

                        Vivian walked gently in the past, lifted the quilt and slipped in. When the body just touched the bed, a big hand stretched over, took her thin body into the arms, with lazy obviously sleepy voice, William said, "Sleep."

                        Vivian did not say anything, cuddling up in his arms.

                        After a while, there was a rhythmic breathing sound above her head. She moved her head out and raised it little by little, and look from William's chin to the bridge of his nose and then to his handsome face.

                        With her fingers, she traced the shape of the man's lips before her.

                        Four years, she kept him for four years, accompanied him for four years, and slept with him for four years.

                        Their relationship is not boyfriend and girlfriend, but more like friends with benefits.

                        William has never publicly acknowledged their relationship, and she fears it will be exposed.

                        After all, William is Angie's ex-boyfriend...

                        All this, will not be with the return of Angie, and completely come to an end?

                        She was anxious and uneasy.

                        ...

                        The second day early in the morning, she got up early to prepare breakfast, called William to get up, began to pack their own things in the apartment, clothes, cosmetics, towel toothbrush, even to clean off the hair.

                        After waiting for Vivian to pull the suitcase out, William is obviously some displeasure, frowning to look at her, "What is wrong, it seems that you want to move from my house this same?"

                        "No..."Vivian kept things to the trunk, try to put the sound of some natural.

                        "You also know now is the busy season, and our shop is in the prime location. Sometimes we do the promotion and it is very busy, it is not convenient to back every day, I go to live there for a period of time, when the things are finished I will come back soon. Just a short time.
                    """
        ]
        completionHandler(mockData)
    }
   
    private func createPayToReadBtn() -> UIView {
        let unlockBtn = UIButton()
        unlockBtn.setImage(UIImage(named: "white-lock-smaller"), for: .normal)
        unlockBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        unlockBtn.setTitle("Pay to Read", for: .normal)
        unlockBtn.setTitleColor(PublicColors.whiteColor, for: .normal)
        unlockBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        unlockBtn.layer.cornerRadius = 24
        unlockBtn.layer.masksToBounds = true
        unlockBtn.applyGradientFromLeftToRight(colours: [PublicColors.goldTint1Color, PublicColors.goldTint2Color])
        unlockBtn.addTarget(self, action: #selector(didOpenUnlockVC), for: .touchUpInside)
        collectionView?.addSubview(unlockBtn)
        unlockBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(20)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(260)
            $0.height.equalTo(48)
        }
        return unlockBtn
    }
    
    @objc func didOpenUnlockVC() {
        // 弹出付费界面
        if let model = chapterDetailList.first {
            LNUnlockChapterViewController.show(in: self, model: model)
            BuryPointUtil.event("016", label: "书籍详情页-点击页面上支付按钮")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("\(self) has deallocated!")
    }

}


extension LNReadingDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chapterDetailList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model: LNBookChapterDetailModel = chapterDetailList[indexPath.item]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.waterFallCollectionViewReuseCellIdentifier, for: indexPath) as? LNReadingDetailCollectionViewCell {
            cell.indexPath = indexPath
            cell.setContent(model: model)
            cell.toggleNightMode(with: isNightMode)
            cell.setEventOfClickingTextView {
                self.didTapTextContentView()
            }
            return cell
        }
        return UICollectionViewCell()
    }
    
}


extension LNReadingDetailViewController: UICollectionViewDelegate {
    
//    func requestNextChapter(with chapterId: Int) {
//        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
//        hud.label.text = "The next chapter is downloading now..."
//        let httpManager = LNHttpManager()
//        let apiurl = httpManager.getAPIUrlPath(.v1BookChapterDetail, suffixParam: "?chapter_id=\(chapterId)")
//        httpManager.getWithUrl(apiurl) { (respDict, error) in
//            hud.hide(animated: true)
//            if let _err = error {
//                self.view.makeToast(_err.localizedDescription, position: .center)
//                return
//            }
//            if let status = respDict?["status"] as? Bool {
//                if !status {
//                    if let message = respDict?["message"] as? String {
//                        self.view.makeToast(message, position: .center)
//                    }
//                } else {
//                    if let dataDict = respDict?["data"] as? [String:Any] {
//                        let model = LNBookChapterDetailModel.deserialize(from: dataDict)
//                        if let _model = model {
//                            if let _content = _model.content, _content.count > 0 {
//                                // 不需要支付，直接显示小说文本
//                                // _model.charLengthAndPageTextArray = LNReaderDetailViewController.parseChapterText(with: _content)
//                                // _model.everyPagePercentile = ceil(100.0 / Float(_model.charLengthAndPageTextArray.count))
//                                self.chapterDetailList = self.chapterDetailList.filter { $0.chapterId != _model.chapterId }
//                                self.chapterDetailList.append(_model)
//                                self.collectionView?.reloadData()
//                                self.navTitleLabel.text = model?.chapterName
//
//                                self.view.makeToast("The next chapter is ready for you to read~")
//                            }
//
//                            if _model.coins > 0 && !_model.isPaid {
//                                // 弹出付费界面，或者自动支付
//                                self.payTheLockedChapter(detailModel: _model)
//                                return
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let model = chapterDetailList[indexPath.section]
//        currentReadingChapterId = model.chapterId
//
//        navTitleLabel.text = model.chapterName
//
//        // 缓存最后阅读的那一章
//        LNFMDBManager.shared().addToLastReadingChapterTable(withBookId: bookId, chapterId: model.chapterId, pageIndex: indexPath.row)
//
//        // 加载下一章节
//        let nextChapterId = chapterDetailList[indexPath.section].nextChapterId
//        if nextChapterId > 0 {
//            if model.coins > 0 && !model.isPaid {
//                // 弹出付费界面，或者自动支付
//                payTheLockedChapter(detailModel: model)
//                return
//            }
//            // 请求下一章节，先判断数组里有没有已经下载好的此章节
//            if chapterDetailList.filter({ $0.chapterId == nextChapterId }).count <= 0 {
//                //requestNextChapter(with: nextChapterId)
//                loadChapterData(with: nextChapterId, isRedownloaded: false)
//
//                (cell as? LNReadingDetailCollectionViewCell)?.scrollsToTop()
//            }
//        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//
//    }
    
    private func payTheLockedChapter(detailModel: LNBookChapterDetailModel) {
        // 1.如果用户已订阅，则自动支付此章节
        if let _isSubscribed = LNUserModelUtil.shared().model?.isSubscribed {
            if _isSubscribed {
                // 2.自动去支付
                unlockChaptersAutomatically(detailModel: detailModel)
                return
            }
        }

        // 3.如果用户没有开启自动订阅服务，则就弹出付费界面
        LNUnlockChapterViewController.show(in: self, model: detailModel)
    }

    // 自动解锁付费章节
    private func unlockChaptersAutomatically(detailModel: LNBookChapterDetailModel) {
        if currentLoggedInUserModel == nil {
            return
        }
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "Auto-Unlock chapter is in progress, wait..."
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookChapterDetail, suffixParam: nil)
        httpManager.post(apiurl, formData: ["chapter_id": detailModel.chapterId, "coins": detailModel.coins]) { (respDict, error) in
            hud.hide(animated: true)
            if let _error = error {
                self.view.makeToast(_error.localizedDescription, position: .center)
                return
            }
            if let status = respDict?["status"] as? Bool {
                if !status {
                    if let err_msg = respDict?["err_msg"] as? String {
                        self.view.makeToast(err_msg, position: .top)
                        if let total_coins = respDict?["total_coins"] as? Int {
                            if total_coins < detailModel.coins { // 所剩余额不足以支付，那么就出支付弹框，让用户付款
                                LNUnlockChapterViewController.show(in: self, model: detailModel)
                            }
                        }
                        return
                    }
                }
                // 更新本地的coins值
                if let total_coins = respDict?["total_coins"] as? Int {
                    if let userModel = LNUserModelUtil.shared().model {
                        userModel.coins = total_coins
                        LNUserModelUtil.shared().saveModel(toDisk: userModel)
                    }
                    self.currentLoggedInUserModel?.coins = total_coins
                }
                self.loadChapterData(with: detailModel.chapterId) //, isRedownloaded: true)
            }
        }
    }
    
    
}
