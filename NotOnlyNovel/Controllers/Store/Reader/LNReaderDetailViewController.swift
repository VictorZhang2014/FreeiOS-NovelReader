//
//  LNReaderDetailViewController.swift
//  NotOnlyNovel
//
//  Created by JohnnyCheung on 2021/2/4.
//
/*
import UIKit
import MBProgressHUD


class LNReaderDetailViewController: LNBaseViewController {

    public var bookId: Int = 0
    
    // 加载顺序为:
    //  1.指定章节
    //  2.最后一次阅读的章节
    //  3.从本书第一章开始
    public var specifiedChapterId: Int = 0 // 加载指定的章节
    public var lastChapterId: Int = 0 // 最后一次阅读的章节ID，如果是首次，那就是第一章的章节的ID
    
    private lazy var customNavigationBarView = UIView()
    private lazy var navTitleLabel = UILabel()
    private lazy var backArrowImg = UIButton()
    private var payToReadBtn: UIView?
    
    private lazy var customFooterView = UIView()
    private lazy var chapterBtn = UIButton()
    private lazy var textSizeBtn = UIButton()
    private lazy var valueSlider = UISlider()
    private lazy var percentOfReadingLabel = UILabel()
    
    private lazy var isNightMode: Bool = false // 是否是夜间模式
    
    private var collectionView: UICollectionView?
    private lazy var waterFallCollectionViewReuseCellIdentifier: String = "kReaderDetailWaterFallCollectionViewReuseCellIdentifier"
    
    private lazy var chapterDetailList: [LNBookChapterDetailModel] = [] // 章节详情
    private lazy var currentReadingChapterId: Int = 0 // 当前正在阅读的章节Id
    
    private lazy var isRequestingNextChapter: Bool = false // 是否正在请求下一章节
    private lazy var isRequestingNextCoinsChapter: Bool = false // 是否正在请求下一收费章节
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupContentTextReadingViews()
        setupNavigationBar()
        setupFooterView()
        loadDefaultChapterModel()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserSignedIn(_:)), name: NSNotification.Name(rawValue: NotificationNameUserSignedInSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didUnlockChaptersSuccessNotification(_:)), name: NSNotification.Name(rawValue: NotificationNameUserUnlockChaptersSuccess), object: nil)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapTextContentView)))
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
        let duration: TimeInterval = 0.25
        if self.customFooterView.isHidden {
            // 即将显示
            UIView.animate(withDuration: duration) {
                self.customFooterView.isHidden = false
                self.customNavigationBarView.isHidden = false
            }
        } else {
            // 即将隐藏
            UIView.animate(withDuration: duration) {
                self.customFooterView.isHidden = true
                self.customNavigationBarView.isHidden = true
            }
        }
    }
    
    private func setupContentTextReadingViews() {
        let waterfallLayout = LNReaderDetailWaterFallCollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(), collectionViewLayout: waterfallLayout)
        collectionView.backgroundColor = PublicColors.mainGrayColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LNReaderDetailPageCollectionViewCell.self, forCellWithReuseIdentifier: self.waterFallCollectionViewReuseCellIdentifier)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(collectionView)
        self.collectionView = collectionView
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight + 5)
        }
         
        navTitleLabel.textColor = FNReadConfig.shared().fontColor
        navTitleLabel.font = UIFont.systemFont(ofSize: FNReadConfig.shared().fontSize)
        navTitleLabel.textAlignment = .center
        self.customNavigationBarView.addSubview(navTitleLabel)
        navTitleLabel.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight)
            //$0.left.equalTo(50)
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.height.equalTo(44)
        }
        
        backArrowImg.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
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
        var footerHeight: CGFloat = 110
        if LNDeviceUtil.shared().isiPhoneXFamily {
            footerHeight = 140
        }
        
        self.customFooterView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        self.customFooterView.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
        self.view.addSubview(self.customFooterView)
        self.customFooterView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(footerHeight)
        }
        
        /*
        let grayView = UIView()
        grayView.backgroundColor = UIColor(rgb: 0x191A1B)
        self.customFooterView.addSubview(grayView)
        grayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }*/
        
        percentOfReadingLabel.text = "1%"
        percentOfReadingLabel.textColor = PublicColors.subTitleColor
        percentOfReadingLabel.font = UIFont.systemFont(ofSize: 10)
        percentOfReadingLabel.textAlignment = .center
        self.customFooterView.addSubview(percentOfReadingLabel)
        percentOfReadingLabel.snp.makeConstraints {
            $0.top.equalTo(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(15)
        }
        
        // 控制进度条
        valueSlider.minimumValue = 0
        valueSlider.maximumValue = 1
        valueSlider.value = 0.1
        valueSlider.minimumTrackTintColor = PublicColors.mainLightPinkColor //.slimLineColorAtDay
        //valueSlider.isContinuous = false
        valueSlider.setThumbImage(UIImage.from(color: PublicColors.whiteColor, size: CGSize(width: 20, height: 20)), for: .normal)
        valueSlider.addTarget(self, action: #selector(didSlideTheBar(_:)), for: .valueChanged)
        self.customFooterView.addSubview(valueSlider)
        valueSlider.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.height.equalTo(40)
            $0.left.equalTo(35)
            $0.right.equalTo(-35)
        }
        
        let btnsView = UIView()
        self.customFooterView.addSubview(btnsView)
        btnsView.snp.makeConstraints {
            if LNDeviceUtil.shared().isiPhoneXFamily {
                $0.height.equalTo(footerHeight/2 + 12)
            } else {
                $0.height.equalTo(footerHeight/2)
            }
            $0.left.bottom.right.equalToSuperview()
        }
         
        let btnWidth: CGFloat = 44
        let btnMargin: CGFloat = (self.view.bounds.size.width - btnWidth * 2) / 3
        
        // 章节按钮
        chapterBtn.setImage(UIImage(named: "show-chaper-list-black"), for: .normal)
        chapterBtn.addTarget(self, action: #selector(didShowChapterList), for: .touchUpInside)
        btnsView.addSubview(chapterBtn)
        chapterBtn.snp.makeConstraints {
            $0.top.equalToSuperview()
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
        let dayNightBtn = UIButton()
        dayNightBtn.setImage(UIImage(named: "detail-night-mode"), for: .normal)
        dayNightBtn.addTarget(self, action: #selector(didChangeNightOrDayModel(_:)), for: .touchUpInside)
        btnsView.addSubview(dayNightBtn)
        dayNightBtn.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.right.equalTo(-btnMargin)
            $0.width.height.equalTo(44)
        }
    }
    
    // 滑动滚动条切换页面
    @objc func didSlideTheBar(_ slider: UISlider) {
        // 1.找出当前正在阅读的章节
        var model: LNBookChapterDetailModel?
        var modelSection: Int = 0
        for i in 0..<chapterDetailList.count {
            if chapterDetailList[i].chapterId == currentReadingChapterId {
                model = chapterDetailList[i]
                modelSection = i
                break
            }
        }
        // 2.滑动到该章节指定的页面
        if let _model = model {
            let row = Int(round(slider.value))
            let indexPath = IndexPath(row: row, section: modelSection)
            if _model.charLengthAndPageTextArray.count > indexPath.row {    
                //if collectionView?.cellForItem(at: indexPath) != nil {
                    collectionView?.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
                //}
            }
            setPercentValueinSlidingLabel(totalCount: _model.charLengthAndPageTextArray.count, currentIndex: row)
        }
        BuryPointUtil.event("021", label: "书籍详情页-章节滑竿拖动")
    }
    
    // 设置当前滑竿的进度显示
    private func setPercentValueinSlidingLabel(totalCount: Int, currentIndex: Int) {
        let percentVal = Int((100 / totalCount) * currentIndex)
        percentOfReadingLabel.text = "\(percentVal)%"
        //let sliderVal = Float(round(Double(percentVal) / 100.0))
        //valueSlider.setValue(sliderVal, animated: true)
    }
    
    // 日夜间模式切换
    @objc func didChangeNightOrDayModel(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            // 进入夜间模式
            button.setImage(UIImage(named: "detail-day-mode"), for: .normal)
            
            customNavigationBarView.backgroundColor = PublicColors.readPageNavigationBarColor
            backArrowImg.backgroundColor = PublicColors.readPageNavigationBarColor
            backArrowImg.setImage(UIImage(named: "white-left-arrow-icon"), for: .normal)
        
            customFooterView.backgroundColor = PublicColors.readPageNavigationBarColor
            valueSlider.minimumTrackTintColor = PublicColors.mainPinkColor //.slimLineColor
            chapterBtn.setImage(UIImage(named: "show-chaper-list-white"), for: .normal)
            textSizeBtn.setImage(UIImage(named: "novel-text-size-white"), for: .normal)
            
        } else {
            // 进入日间模式
            button.setImage(UIImage(named: "detail-night-mode"), for: .normal)
            
            customNavigationBarView.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
            backArrowImg.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
            backArrowImg.setImage(UIImage(named: "black-left-arrow-icon"), for: .normal)
            
            customFooterView.backgroundColor = PublicColors.readPageNavigationBarColorAtDay
            valueSlider.minimumTrackTintColor = PublicColors.mainLightPinkColor
            chapterBtn.setImage(UIImage(named: "show-chaper-list-black"), for: .normal)
            textSizeBtn.setImage(UIImage(named: "novel-text-size-black"), for: .normal)
        }
        
        isNightMode = !isNightMode
        collectionView?.reloadData()
        
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
    private func loadChapterData(with chapterId: Int, isRedownloaded: Bool = false) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        if isRedownloaded {
            hud.label.text = "This chapter is re-downloading now..."
        } else {
            hud.label.text = "The chapter is downloading..."
        }
        
        self.payToReadBtn?.removeFromSuperview()
        self.payToReadBtn = nil
        
        // 2.从网络请求数据
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookChapterDetail, suffixParam: "?chapter_id=\(chapterId)")
        httpManager.getWithUrl(apiurl) { (respDict, error) in
            hud.hide(animated: true)
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
                        let model = LNBookChapterDetailModel.deserialize(from: dataDict)
                        if let _model = model {
                            self.navTitleLabel.text = _model.chapterName
                            if let _content = _model.content, _content.count > 0 {
                                // 此章节不需要支付，直接显示到界面上
                                _model.charLengthAndPageTextArray = LNReaderDetailViewController.parseChapterText(with: _content)
                                _model.everyPagePercentile = ceil(100.0 / Float(_model.charLengthAndPageTextArray.count))
                                self.chapterDetailList = self.chapterDetailList.filter { $0.chapterId != _model.chapterId }
                                self.chapterDetailList.append(_model)
                                
                                // 每次切换章节时，默认把collectionView的cell设置为第一个的位置
                                if self.chapterDetailList.count == 1 {
                                    self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
                                }
                                
                                // 设置滑竿的最大值
                                self.valueSlider.maximumValue = Float(_model.charLengthAndPageTextArray.count)
                                
                                // 存储此章节已读
                                LNFMDBManager.shared().addingHaveReadChapterIntoTable(withBookId: self.bookId, chapterId: _model.chapterId)
                                
                                if !_model.isPaid && _model.coins > 0 {
                                    // 如果只有chapterDetailList只有一章节，并且是待支付的，那么就显示一个按钮
                                    self.payToReadBtn = self.createPayToReadBtn()
                                }
                                
                                if isRedownloaded {
                                    self.view.makeToast("The next chapter is ready for you to read~")
                                }
                            }
                        }
                        self.collectionView?.reloadData()
                        
                        // 缓存起来
                        //FNCacheUtil().saveValue(dataDict, forKey: cacheKey)
                    }
                }
            }
        } 
        
        /*
        let model = LNBookChapterDetailModel()
        model.chapterId = 26835
        model.bookId = 510000228
        model.chapterName = "Chapter 13 That\'s not what you said at that night."
        model.wordNum = 3704
        model.content = "I never expect Frances Louis would bring up a request like this.\r\n     I am stunned and don\'t know what to say.\r\n     Until his cold lips against mine. Suddenly I get my conscious and push him away.\r\n     \"Mr. Louis, I am not that kind of woman!\"\r\n     I step back and keep a distance between us.\r\n     This man has a smell of danger. Maybe I shouldn\'t come at first.\r\n     \"Not that kind of woman?\" Frances Louis raises his mouth slightly. His words are sarcastic, \"That\'s not what you said at that night.\"\r\n     Immediately, it feels that someone is slapping on my face.\r\n     That night, in order to persuade Frances Louis to save me, I really say all kinds of things. But people shouldn\'t take serious about someone\'s words which are said under an emergency situation!\r\n     I can tell from the look of Frances Louis, no matter what I say, that would be superfluous.\r\n     \"I will repay your debt as soon as I can. Please give me some time.\"\r\n     I say and stride out. I close the door quickly.\r\n     His ambiguous words are still ringing in my ears. My ears are burning.\r\n     When I go down stairs, the maid looks at me significantly and walk me to the gate. She say repeatedly that when I come next time, she will treat me in delicious food.\r\n     Today is Sunday. I have hotpot outside alone and go home.\r\n     There are two people sitting at the door. They make me as panic as the red paint on the door.\r\n     I come up and say, \"Dad, Mom.\"\r\n     I am extremely upset.\r\n     I know clearly that it would never be something good for my parents coming to me.\r\n     My mother sees me and pulls my father up from ground. They walk towards me.\r\n     My mother raises her head. I see her red eyes. She must have cried.\r\n     What happened? My heart clenches. I can never don\'t care about them no matter how cold I am\r\n     \"Jane, you finally come back. We don\'t have another place to go. We can only come to you.\" My mother wipes her eyes and says.\r\n     I didn\'t tell them I lived here. It must because of Andrew Malan that they can find me here.\r\n     \"What happened?\"\r\n     I frown and open the door. My parents come in along with me.\r\n     \"It\'s you! You insist divorcing against Andrew Malan!\"\r\n     My mother doesn\'t say what happened. She scolds me at first. Until now, she still thinks it is my fault. I am her daughter, but I\'m not as good as an outsider in her heart. How sad it is!\r\n     My face is sullen and say coldly, \"Since you like Andrew Malan, you can ask him for help, then why come to me?\"\r\n     I am not heartless, but what they did is really hurtful. They only care about their own interests, and the future of my brother. They never care about my feelings. That\'s why they don\'t allow me to divorce Andrew Malan even if they know exactly what he did to me.\r\n     And now, they are still blaming on me.\r\n     My mother is panic to see my attitude and says softly holding my hands, \"Jane, mom is not blaming on you. I am blaming Andrew Malan to be so cruel. Now he asks his aunt to take back the house. We have nowhere to go, so we can only come to you.\"\r\n     Before I get married, my parents live in hometown. They see me settle down in the city and move along with me. They rent a house of Andrew Malan\'s aunt. Now I divorced Andrew Malan, so the house is taken back. It must be Andrew Malan did.\r\n     My parents are homeless and I couldn\'t just ignore it.\r\n     I sigh and say, \"Where is your luggage?\"\r\n     \"She demands us moving out before tomorrow morning, we will take our luggage here right now.\"\r\n     My mother says and drags my father out.\r\n     My lips move, then they leave before I say something. If they are moving in, it means troubles are moving in together."
        model.prevChapterId = 26834
        model.nextChapterId = 26836
        
        model.charLengthAndPageTextArray = LNReaderDetailViewController.parseChapterText(with: model.content ?? "")
        model.everyPagePercentile = ceil(100.0 / Float(model.charLengthAndPageTextArray.count))
        
        chapterDetailList.append(model)
        
        collectionView?.reloadData()*/
    }
    
    // 解析内容文本
    private static func parseChapterText(with contentText: String) -> [[Int:String]] {
        let chapterContent = String.removePrefixString(by: "\n", originalString: contentText)
        
        // 解析并去除HTML标签
        let plaintext = chapterContent.getStringWithoutHTML
        print(plaintext)
        
        // 解析分页文本内容
        var chapterAttributedContent: NSAttributedString?
        let pageArray = FNReadParser.pagingContent(plaintext, bounds: LNPageTextContentView.labelFrame, attributedContent: &chapterAttributedContent)
        if let _pageArray = pageArray as? [Int] {
            
            // 分解分页内容和字符长度，缓存起来
            var _pageCharLengthArray: [[Int:String]] = []
            var lastLength: Int = 0
            for i in 0...pageArray.count {
                var currentText: Substring = ""
                var pageCharLength: Int = 0
                if i == pageArray.count {
                    pageCharLength = plaintext.count - lastLength
                    currentText = plaintext[lastLength..<plaintext.count]
                } else {
                    pageCharLength = _pageArray[i]
                    if pageCharLength == 0 { continue }
                    currentText = plaintext[lastLength..<pageCharLength]
                }
                _pageCharLengthArray.append([pageCharLength:String(currentText)])
                lastLength = pageCharLength
            }
            return _pageCharLengthArray
        }
        return []
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


extension LNReaderDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return chapterDetailList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if chapterDetailList.count <= 0 {
            return 0
        }
        let model: LNBookChapterDetailModel = chapterDetailList[section]
        return model.charLengthAndPageTextArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if chapterDetailList.count <= 0 {
            return UICollectionViewCell()
        }
        let model: LNBookChapterDetailModel = chapterDetailList[indexPath.section]
        let charLengthAndPageTextPair = model.charLengthAndPageTextArray[indexPath.row]
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.waterFallCollectionViewReuseCellIdentifier, for: indexPath) as? LNReaderDetailPageCollectionViewCell {
            cell.indexPath = indexPath
            cell.updateData(with: charLengthAndPageTextPair, model: model)
            cell.toggleNightMode(with: isNightMode)
            return cell
        }
        return UICollectionViewCell()
    }
    
}


extension LNReaderDetailViewController: UICollectionViewDelegate {
    
    func requestNextChapter(with chapterId: Int) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = "The next chapter is downloading now..."
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookChapterDetail, suffixParam: "?chapter_id=\(chapterId)")
        httpManager.getWithUrl(apiurl) { (respDict, error) in
            hud.hide(animated: true)
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
                        let model = LNBookChapterDetailModel.deserialize(from: dataDict)
                        if let _model = model {
                            if let _content = _model.content, _content.count > 0 {
                                // 不需要支付，直接显示小说文本
                                _model.charLengthAndPageTextArray = LNReaderDetailViewController.parseChapterText(with: _content)
                                _model.everyPagePercentile = ceil(100.0 / Float(_model.charLengthAndPageTextArray.count))
                                self.chapterDetailList = self.chapterDetailList.filter { $0.chapterId != _model.chapterId }
                                self.chapterDetailList.append(_model)
                                self.collectionView?.reloadData()
                                self.navTitleLabel.text = model?.chapterName
                                
                                // 设置滑竿的最大值
                                self.valueSlider.maximumValue = Float(_model.charLengthAndPageTextArray.count)
                                
                                self.view.makeToast("The next chapter is ready for you to read~")
                            }
                            
                            if _model.coins > 0 && !_model.isPaid {
                                // 弹出付费界面，或者自动支付
                                self.payTheLockedChapter(detailModel: _model)
                                return
                            }
                        }
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let model = chapterDetailList[indexPath.section]
        currentReadingChapterId = model.chapterId
        
        navTitleLabel.text = model.chapterName
        
        // 设置滑竿的显示进度
        setPercentValueinSlidingLabel(totalCount: model.charLengthAndPageTextArray.count, currentIndex: indexPath.row)
        
        // 缓存最后阅读的那一章
        LNFMDBManager.shared().addToLastReadingChapterTable(withBookId: bookId, chapterId: model.chapterId, pageIndex: indexPath.row)
        
        // 当滑动到倒数第一页时，就去请求下一章节
        if model.charLengthAndPageTextArray.count == (indexPath.row + 1) {
            // 加载下一章节
            let nextChapterId = chapterDetailList[indexPath.section].nextChapterId
            if nextChapterId > 0 {
                if model.charLengthAndPageTextArray.count == 1 && model.coins > 0 && !model.isPaid {
                    // 弹出付费界面，或者自动支付
                    payTheLockedChapter(detailModel: model)
                    return
                }
                // 请求下一章节，先判断数组里有没有已经下载好的此章节
                if chapterDetailList.filter({ $0.chapterId == nextChapterId }).count <= 0 {
                    requestNextChapter(with: nextChapterId)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
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
                self.loadChapterData(with: detailModel.chapterId, isRedownloaded: true)
            }
        }
    }
    
    
}
*/
