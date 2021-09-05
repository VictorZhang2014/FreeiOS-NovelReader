//
//  LNUnlockChapterView.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/2/19.
//
//  解锁章节

import UIKit
import MBProgressHUD

class LNUnlockChapterViewController: LNBaseViewController {
    
    private lazy var backgroundAlphaView = UIView()
    private var autoSubscribeCheckbox: UIButton?

    private var model: LNBookChapterDetailModel?
    
    private var isAutoSubscribed: Bool = true // 是否自动订阅付费章节
    
    static func show(in vc: UIViewController, model: LNBookChapterDetailModel) {
        let unlocChapterVC = LNUnlockChapterViewController()
        unlocChapterVC.model = model
        unlocChapterVC.modalPresentationStyle = .overFullScreen
        vc.present(unlocChapterVC, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        
        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserSignedIn(_:)), name: NSNotification.Name(rawValue: NotificationNameUserSignedInSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserPurchasedCoins(_:)), name: NSNotification.Name(rawValue: NotificationNameUserPurchasedCoinsSuccess), object: nil)
    }
    
    // 用户登录成功
    @objc func onSuccessOfUserSignedIn(_ notification: Notification) {
        currentLoggedInUserModel = LNUserModelUtil.shared().model
        self.view.makeToast(languageToggle.localizedString("Login Successful! You can now top up coins for reading 😂."), position: .center)
        
        // 登录完后，直接跳转到购买金币页面
        let vc = LNCoinPurchaseViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // 用户购买金币成功
    @objc func onSuccessOfUserPurchasedCoins(_ notification: Notification) {
        currentLoggedInUserModel = LNUserModelUtil.shared().model
        
        // 继续解锁
        didClickedUnlock()
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
        
        let unlockViewHeight = view.bounds.size.height - 205 - statusBarHeight
        
        let unlcokView = UIView()
        unlcokView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 15)
        unlcokView.backgroundColor = PublicColors.mainGrayColor
        view.addSubview(unlcokView)
        unlcokView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(unlockViewHeight)
        }
        
        // 关闭按钮
        let backArrowImg = UIButton(frame: CGRect())
        backArrowImg.setImage(UIImage(named: "black-X-close-icon")?.sd_resizedImage(with: CGSize(width: 22, height: 22), scaleMode: .aspectFit), for: .normal)
        backArrowImg.addTarget(self, action: #selector(didGoBack), for: .touchUpInside)
        unlcokView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            $0.top.equalTo(10)
            $0.right.equalTo(-10)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
        
        let leftMargin: CGFloat = 20
        
        let titleLabel = UILabel()
        titleLabel.text = "Locked Chapter"
        titleLabel.textColor = PublicColors.chapterListTitleColor
        titleLabel.textAlignment = .left
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        unlcokView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.left.equalTo(leftMargin)
            $0.right.equalTo(-leftMargin)
            $0.height.equalTo(35)
        }
        
        let descLabel = UILabel()
        descLabel.text = model?.chapterName
        descLabel.textColor = PublicColors.subTitleColor
        descLabel.textAlignment = .left
        descLabel.font = UIFont.systemFont(ofSize: 15)
        descLabel.numberOfLines = 0
        descLabel.lineBreakMode = .byWordWrapping
        unlcokView.addSubview(descLabel)
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(0)
            $0.left.equalTo(leftMargin)
            $0.right.equalTo(-leftMargin)
            $0.height.equalTo(35)
        }
  
        // 解锁白色背景视图
        let unlockCoinsView = UIView()
        unlockCoinsView.backgroundColor = PublicColors.whiteColor
        unlockCoinsView.layer.cornerRadius = 35
        unlockCoinsView.layer.masksToBounds = true
        unlcokView.addSubview(unlockCoinsView)
        unlockCoinsView.snp.makeConstraints {
            $0.top.equalTo(descLabel.snp.bottom).offset(20)
            $0.left.equalTo(leftMargin)
            $0.right.equalTo(-leftMargin)
            $0.height.equalTo(280)
        }
        
        let btmTipLabel = UILabel()
        btmTipLabel.text = "Unlock to read and sponsor the author of this book"
        btmTipLabel.textColor = PublicColors.subTitleColor
        btmTipLabel.textAlignment = .center
        btmTipLabel.font = UIFont.systemFont(ofSize: 14)
        btmTipLabel.numberOfLines = 0
        btmTipLabel.lineBreakMode = .byWordWrapping
        unlcokView.addSubview(btmTipLabel)
        btmTipLabel.snp.makeConstraints {
            $0.top.equalTo(unlockCoinsView.snp.bottom).offset(20)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(35)
        }
        
        let coinLabel = UILabel()
        coinLabel.text = "\(model?.coins ?? 10)"
        coinLabel.textColor = PublicColors.goldCoinColor
        coinLabel.textAlignment = .center
        coinLabel.font = UIFont.boldSystemFont(ofSize: 85)
        unlockCoinsView.addSubview(coinLabel)
        coinLabel.snp.makeConstraints {
            $0.top.equalTo(leftMargin)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(115)
            $0.height.equalTo(100)
        }
        
        let coinTipLabel = UILabel()
        coinTipLabel.text = "coins"
        coinTipLabel.textColor = PublicColors.goldTint2Color
        coinTipLabel.textAlignment = .left
        coinTipLabel.font = UIFont.boldSystemFont(ofSize: 17)
        unlockCoinsView.addSubview(coinTipLabel)
        coinTipLabel.snp.makeConstraints {
            $0.top.equalTo(leftMargin + 40)
            $0.left.equalTo(coinLabel.snp.right).offset(5)
            $0.width.equalTo(50)
            $0.height.equalTo(20)
        }
        
        let unlockBtn = UIButton()
        unlockBtn.setImage(UIImage(named: "white-lock-smaller"), for: .normal)
        unlockBtn.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        unlockBtn.setTitle("Unlock", for: .normal)
        unlockBtn.setTitleColor(PublicColors.whiteColor, for: .normal)
        unlockBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        unlockBtn.layer.cornerRadius = 23
        unlockBtn.layer.masksToBounds = true
        unlockBtn.applyGradientFromLeftToRight(colours: [PublicColors.goldTint1Color, PublicColors.goldTint2Color])
        unlockBtn.addTarget(self, action: #selector(didClickedUnlock), for: .touchUpInside)
        unlockCoinsView.addSubview(unlockBtn)
        unlockBtn.snp.makeConstraints {
            $0.top.equalTo(coinLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(260)
            $0.height.equalTo(46)
        }
        
        let autoSubscribeLabel = UILabel()
        autoSubscribeLabel.text = "Auto-Unlock Next Chapter"
        autoSubscribeLabel.textColor = PublicColors.titleColor
        autoSubscribeLabel.font = UIFont.systemFont(ofSize: 13)
        autoSubscribeLabel.textAlignment = .center
        autoSubscribeLabel.isUserInteractionEnabled = true
        autoSubscribeLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClickAutoSubscribes(_:))))
        unlockCoinsView.addSubview(autoSubscribeLabel)
        autoSubscribeLabel.snp.makeConstraints {
            $0.top.equalTo(unlockBtn.snp.bottom).offset(27)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(185)
            $0.height.equalTo(19)
        }
        
        let autoSubscribeCheckbox = UIButton()
        autoSubscribeCheckbox.backgroundColor = PublicColors.goldCoinColor
        autoSubscribeCheckbox.setImage(UIImage(named: "white-check-mark-smaller"), for: .normal)
        autoSubscribeCheckbox.addTarget(self, action: #selector(didCheckboxTheAgreements(_:)), for: .touchUpInside)
        autoSubscribeCheckbox.isSelected = isAutoSubscribed
        self.autoSubscribeCheckbox = autoSubscribeCheckbox
        unlockCoinsView.addSubview(autoSubscribeCheckbox)
        autoSubscribeCheckbox.snp.makeConstraints {
            $0.top.equalTo(unlockBtn.snp.bottom).offset(27)
            $0.right.equalTo(autoSubscribeLabel.snp.left).offset(-5)
            $0.width.height.equalTo(18)
        }
    }
    
    @objc func didGoBack() {
        UIView.animate(withDuration: 0.25) {
            self.backgroundAlphaView.alpha = 0
        } completion: { (isFinished) in
            if isFinished {
                self.backgroundAlphaView.removeFromSuperview()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @objc func didClickAutoSubscribes(_ gesture: UITapGestureRecognizer) {
        if let btn = self.autoSubscribeCheckbox {
            didCheckboxTheAgreements(btn)
        }
    }

    @objc func didCheckboxTheAgreements(_ button: UIButton) {
        button.isSelected = !button.isSelected
        if button.isSelected {
            button.backgroundColor = PublicColors.goldCoinColor
            button.setImage(UIImage(named: "white-check-mark-smaller"), for: .normal)
            isAutoSubscribed = true
        } else {
            button.backgroundColor = PublicColors.mainGrayColor
            button.setImage(UIImage(), for: .normal)
            isAutoSubscribed = false
        }
    }
    
    @objc func didClickedUnlock() {
        if LNUserModelUtil.shared().model == nil {
            let vc = LNSignInViewController()
            present(vc, animated: true, completion: nil)
            return
        }
        if let _coins = currentLoggedInUserModel?.coins {
            if _coins <= 0 || _coins < (model?.coins ?? 0) { // 如果当前登录用户还没有金币，则弹框去购买金币
                //alert(withMessage: languageToggle.localizedString("Purchase coins first and then continue to unlock chapters to read.")) {
                    let vc = LNCoinPurchaseViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                //} cancelHandler: { }
                BuryPointUtil.event("005", label: "跳转到金币购买页面", attributes: ["page":"unlock_chapter"])
            } else {
                // 发送请求，解锁一章节
                if let _detailModel = self.model {
                    MBProgressHUD.showAdded(to: self.view, animated: true)
                    let httpManager = LNHttpManager()
                    let apiurl = httpManager.getAPIUrlPath(.v1BookChapterDetail, suffixParam: nil)
                    httpManager.post(apiurl, formData: ["chapter_id": _detailModel.chapterId, "coins": _detailModel.coins]) { (respDict, error) in
                        MBProgressHUD.hide(for: self.view, animated: true)
                        if error != nil {
                            self.view.makeToast(error?.localizedDescription, position: .center)
                            return
                        }
                        if let status = respDict?["status"] as? Bool {
                            if !status {
                                if let err_msg = respDict?["err_msg"] as? String {
                                    self.view.makeToast(err_msg, position: .center)
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
                            
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNameUserUnlockChaptersSuccess), object: nil, userInfo: ["chapter_id":_detailModel.chapterId])
                            }
                            self.view.makeToast(self.languageToggle.localizedString("Unlock success, please continue to read."), position: .center, title: self.languageToggle.localizedString("SUCCESS"), image: UIImage(named: "paid-success-green-icon"))
                            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(2000)) {
                                self.didGoBack()
                            }
                            
                            // 开启/关闭了自动订阅服务
                            if let model = LNUserModelUtil.shared().model {
                                model.isSubscribed = self.isAutoSubscribed
                                LNUserModelUtil.shared().saveModel(toDisk: model)
                            }
                        }
                    }
                }
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
