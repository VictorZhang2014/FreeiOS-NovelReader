//
//  LNMeViewController.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/1/31.
//

import UIKit
import StoreKit
import Lottie


class LNMeViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    
    private lazy var tableView = UITableView()
    private lazy var avatarImageView = UIImageView()
    private var placeholderImageView: UIImageView?
    private lazy var goldCoinLabel = UILabel()
    private lazy var switcherBtn = UISwitch()
    private lazy var margin: CGFloat = 16
    
    private var lottieAnimationView: AnimationView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.mainGrayColor

        setupNavigationBar()
        setupViews()
        requestMyCoins()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserSignedIn(_:)), name: NSNotification.Name(rawValue: NotificationNameUserSignedInSuccess), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserSignedOut(_:)), name: NSNotification.Name(rawValue: NotificationNameUserHasLogout), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onSuccessOfUserPurchasedCoins(_:)), name: NSNotification.Name(rawValue: NotificationNameUserPurchasedCoinsSuccess), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        BuryPointUtil.beginLogPageView("Tab我的页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("Tab我的页")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 每次进入此界面时，都重新读取金币数
        currentLoggedInUserModel = LNUserModelUtil.shared().model
        goldCoinLabel.text = "\(currentLoggedInUserModel?.coins ?? 0)"
        switcherBtn.isOn = currentLoggedInUserModel?.isSubscribed ?? false
        
        if let _lottieAnimationView = lottieAnimationView {
            _lottieAnimationView.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    // 用户登录成功
    @objc func onSuccessOfUserSignedIn(_ notification: Notification) {
        currentLoggedInUserModel = LNUserModelUtil.shared().model
        tableView.reloadData()
        requestMyCoins()
    }
    
    // 用户退出登录成功
    @objc func onSuccessOfUserSignedOut(_ notification: Notification) {
        currentLoggedInUserModel = nil
        
        // 删除本地缓存的头像图片
        avatarImageView.image = nil
        LNCacheUtil().removeValue(forKey: kUserAvatarLocalKey)
        
        tableView.reloadData()
    }
    
    // 用户购买金币成功
    @objc func onSuccessOfUserPurchasedCoins(_ notification: Notification) {
        currentLoggedInUserModel = LNUserModelUtil.shared().model
        tableView.reloadData()
    }
    
    private func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = UIColor.clear
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.statusBarHeight)
        }
    }
    
    private func setupViews() {
        lottieAnimationView = AnimationView(name: "35799-3-animation")
        lottieAnimationView?.loopMode = .loop
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            lottieAnimationView?.frame = CGRect(x: 0, y: -50, width: self.view.bounds.size.width, height: 600)
        } else {
            lottieAnimationView?.frame = CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 300)
        }
        if let _lottieAnimationView = lottieAnimationView {
            view.addSubview(_lottieAnimationView)
            _lottieAnimationView.play()
        }
        
        tableView.backgroundColor = UIColor.clear
        //tableView.contentInset = UIEdgeInsets(top: 0, left: self.margin, bottom: 0, right: -self.margin)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(90)
            } else {
                $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            }
            $0.left.equalTo(16)
            $0.right.equalTo(-16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func requestMyCoins() {
        let httpManager = LNHttpManager()
        httpManager.get(.v1CoinsPurchase) { (responseDict, error) in
            if error != nil {
                
            } else if responseDict != nil {
                if let totalcoins = responseDict?["total_coins"] as? Int {
                    let m = LNUserModelUtil.shared().model
                    m?.coins = totalcoins
                    if let _m = m {
                        LNUserModelUtil.shared().saveModel(toDisk: _m)
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}


extension LNMeViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 2
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell()
            cell.selectionStyle = .none
            let headerView = self.createHeaderView()
            //cell.contentView.backgroundColor = PublicColors.whiteColor
            cell.backgroundView = UIView() // 1.设置cell背景透明
            cell.backgroundColor = UIColor.clear // 2.设置cell背景透明
            cell.contentView.addSubview(headerView)
            headerView.snp.makeConstraints {
                $0.top.equalTo(90)
                $0.left.right.equalToSuperview()
                $0.height.equalTo(185)
                //$0.bottom.equalTo(-self.margin)
            }
            return cell
        } else if indexPath.section == 1 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.contentView.backgroundColor = PublicColors.mainGrayColor
            if indexPath.row == 0 {
                 cell.imageView?.image = UIImage(named: "profile-get-free-reading-icon")?.sd_resizedImage(with: CGSize(width: 28, height: 28), scaleMode: .fill)
                 cell.textLabel?.text = languageToggle.localizedString("Earn Coins, Free to Read")
                 createDisclosureIndicator(in: cell)
            } else if indexPath.row == 1 {
                // 自动续费
                cell.imageView?.image = UIImage(named: "profile-auto-subscribed-icon")?.sd_resizedImage(with: CGSize(width: 28, height: 28), scaleMode: .fill)
                cell.textLabel?.text = languageToggle.localizedString("Auto-Unlock Chapters")
                switcherBtn.isOn = currentLoggedInUserModel?.isSubscribed ?? false
                switcherBtn.addTarget(self, action: #selector(didSwitchAutoSubscription(_:)), for: .valueChanged)
                cell.contentView.addSubview(switcherBtn)
                switcherBtn.snp.makeConstraints {
                    $0.right.equalTo(-10)
                    $0.centerY.equalToSuperview()
                    $0.width.equalTo(50)
                    $0.height.equalTo(30)
                }
            } else if indexPath.row == 2 {
                cell.imageView?.image = UIImage(named: "profile-transaction-history-icon")?.sd_resizedImage(with: CGSize(width: 28, height: 28), scaleMode: .fill)
                cell.textLabel?.text = languageToggle.localizedString("Transaction History")
                createDisclosureIndicator(in: cell)
            }
            cell.accessoryType = .none
            cell.textLabel?.textColor = PublicColors.mainBlackColor // titleColor
            cell.textLabel?.font = UIFont.AvenirMedium(size: 16)
            return cell
        } else if indexPath.section == 2 {
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.contentView.backgroundColor = PublicColors.mainGrayColor
            if indexPath.row == 0 {
                cell.imageView?.image = UIImage(named: "profile-rate-us-icon")?.sd_resizedImage(with: CGSize(width: 28, height: 28), scaleMode: .fill)
                cell.textLabel?.text = languageToggle.localizedString("Rate Us")
            } else if indexPath.row == 1 {
                cell.imageView?.image = UIImage(named: "profile-settings-icon")?.sd_resizedImage(with: CGSize(width: 28, height: 28), scaleMode: .fill)
                cell.textLabel?.text = languageToggle.localizedString("Settings")
            }
            cell.accessoryType = .none
            createDisclosureIndicator(in: cell)
            cell.textLabel?.textColor = PublicColors.mainBlackColor //.titleColor
            cell.textLabel?.font = UIFont.AvenirMedium(size: 16)
            return cell
        }
        return UITableViewCell()
    }
    
    private func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = PublicColors.whiteColor
        headerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didGoLogin)))
        headerView.layer.cornerRadius = 12
        headerView.layer.masksToBounds = true
        
        avatarImageView.backgroundColor = PublicColors.mainGrayColor
        avatarImageView.layer.cornerRadius = 48
        avatarImageView.layer.masksToBounds = true
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didChangeUserAvatar)))
        headerView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints {
            $0.top.left.equalTo(12)
            $0.width.height.equalTo(96)
        }
        
        let placeholderImageView = UIImageView()
        placeholderImageView.image = UIImage(named: "profile-person-gray-icon")
        self.placeholderImageView = placeholderImageView
        headerView.addSubview(placeholderImageView)
        placeholderImageView.snp.makeConstraints {
            $0.top.left.equalTo(12 + 25)
            $0.width.height.equalTo(45)
        }
        
        // 如果有图片，就设置上
        if let avatar = currentLoggedInUserModel?.userAvatar, avatar.count > 0 {
            avatarImageView.sd_setImage(with: URL(string: avatar)) { (downloadedImage, error, imageCacheType, imageUrl) in
                if downloadedImage != nil {
                    self.placeholderImageView?.removeFromSuperview()
                }
            }
        }
        
        // 本地缓存的头像图片
        let cacheUtil = LNCacheUtil()
        if let userAvatarImageData = cacheUtil.getAnyValue(forKey: kUserAvatarLocalKey) as? Data {
            avatarImageView.image = UIImage(data: userAvatarImageData)
            self.placeholderImageView?.removeFromSuperview()
        }

        let userNameLabel = UILabel()
        userNameLabel.text = languageToggle.localizedString("Sign In")
        if let _name = currentLoggedInUserModel?.nickname, _name.count > 0 {
            userNameLabel.text = _name
        }
        userNameLabel.textColor = PublicColors.blackColor
        userNameLabel.font = UIFont.ArialRoundedMTBold(size: 22) // .systemFont(ofSize: 22)
        headerView.addSubview(userNameLabel)
        userNameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarImageView.snp.right).offset(26)
            $0.top.equalTo(avatarImageView.snp.top).offset(23)
            $0.right.equalTo(-10)
            $0.height.equalTo(26)
        }
        
        let indicatorRightArrowImageView = UIImageView(image: UIImage(named: "tableviewcell-gray-disclosure-indicator"))
        indicatorRightArrowImageView.isHidden = isLogin
        headerView.addSubview(indicatorRightArrowImageView)
        indicatorRightArrowImageView.snp.makeConstraints {
            $0.top.equalTo(self.avatarImageView.snp.top).offset(28)
            $0.right.equalTo(-15)
            $0.width.height.equalTo(16)
        }
        
        let userIdLabel = UILabel()
        userIdLabel.text = ""
        if let email = currentLoggedInUserModel?.email {
            if email.count > 0 {
                userIdLabel.text = "ID: \(currentLoggedInUserModel?.email ?? "")"
            }
        }
        if let _intro = currentLoggedInUserModel?.intro, _intro.count > 0 {
            userIdLabel.text = _intro
        }
        userIdLabel.textColor = PublicColors.subTitleColor
        userIdLabel.font = UIFont.systemFont(ofSize: 15)
        headerView.addSubview(userIdLabel)
        userIdLabel.snp.makeConstraints {
            $0.left.equalTo(avatarImageView.snp.right).offset(26)
            $0.top.equalTo(userNameLabel.snp.bottom).offset(7)
            $0.right.equalTo(-10)
            $0.height.equalTo(16)
        }
        
        let goldCoinImageView = UIImageView()
        goldCoinImageView.image = UIImage(named: "profile-gold-coin-icon")
        headerView.addSubview(goldCoinImageView)
        goldCoinImageView.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(20)
            $0.left.equalTo(28)
            $0.width.height.equalTo(40)
        }
        
        let goldCoinTitleLabel = UILabel()
        goldCoinTitleLabel.text = "Coins"
        goldCoinTitleLabel.textColor = PublicColors.titleColor
        goldCoinTitleLabel.font = UIFont.ArialRoundedMTBold(size: 16) //.systemFont(ofSize: 16)
        headerView.addSubview(goldCoinTitleLabel)
        goldCoinTitleLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(31)
            $0.left.equalTo(goldCoinImageView.snp.right).offset(6)
            $0.width.equalTo(55)
            $0.height.equalTo(19)
        }
        
        self.goldCoinLabel = UILabel()
        self.goldCoinLabel.text = "\(currentLoggedInUserModel?.coins ?? 0)"
        self.goldCoinLabel.textColor = PublicColors.goldCoinColor
        self.goldCoinLabel.font = UIFont.systemFont(ofSize: 20)
        self.goldCoinLabel.adjustsFontSizeToFitWidth = true
        headerView.addSubview(self.goldCoinLabel)
        
        
        let buyCoinBtn = UIButton()
        buyCoinBtn.backgroundColor = PublicColors.mainLightPinkColor //.applyGradientFromLeftToRight(colours: [PublicColors.goldTint1Color, PublicColors.goldTint2Color])
        buyCoinBtn.setTitle("Top Up", for: .normal)
        buyCoinBtn.setTitleColor(PublicColors.whiteColor, for: .normal)
        buyCoinBtn.titleLabel?.font = UIFont.ArialRoundedMTBold(size: 18) //.systemFont(ofSize: 18)
        buyCoinBtn.layer.cornerRadius = 20
        buyCoinBtn.layer.masksToBounds = true
        buyCoinBtn.addTarget(self, action: #selector(prepareToBuyCoins), for: .touchUpInside)
        headerView.addSubview(buyCoinBtn)
        buyCoinBtn.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(20)
            $0.right.equalTo(-16)
            $0.width.equalTo(150)
            $0.height.equalTo(40)
        }
        
        self.goldCoinLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(28)
            $0.left.equalTo(goldCoinTitleLabel.snp.right).offset(6)
            $0.right.equalTo(buyCoinBtn.snp.left).offset(-10)
            $0.height.equalTo(25)
        }
        
        return headerView
    }
    
    private func createDisclosureIndicator(in cell: UITableViewCell) {
        let imageView = UIImageView(image: UIImage(named: "tableviewcell-gray-disclosure-indicator"))
        cell.contentView.addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.right.equalTo(-15)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }
    }
    
    private func createIntermediateWhiteView() -> UIView {
        let v = UIView()
        v.backgroundColor = PublicColors.whiteColor
        return v
    }
    
    @objc func didChangeUserAvatar() {
        if currentLoggedInUserModel == nil {
            didGoLogin()
            return
        }
        let vc = LNUserAvatarChangeViewController()
        vc.userAvatarUpdatedCompletion = { (userAvatarUrl, userAvatarImage) in
            //self.avatarImageView.sd_setImage(with: URL(string: userAvatarUrl)) { (downloadedImage, error, imageCacheType, imageUrl) in
            //    self.tableView.reloadData()
            //}
            
            // 暂时先存储在本地
            self.avatarImageView.image = userAvatarImage
            self.placeholderImageView?.removeFromSuperview()
            self.placeholderImageView = nil
            if let _userAvatarImage = userAvatarImage {
                let imageData = _userAvatarImage.jpegData(compressionQuality: 1)
                LNCacheUtil().saveAnyValue(imageData, forKey: kUserAvatarLocalKey)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        BuryPointUtil.event("006", label: "修改头像")
    }
    
    // 自动续费开关
    @objc private func didSwitchAutoSubscription(_ switcher: UISwitch) {
        if currentLoggedInUserModel == nil {
            switcher.isOn = false
            didGoLogin()
            return
        }
        if let model = LNUserModelUtil.shared().model {
            model.isSubscribed = switcher.isOn
            LNUserModelUtil.shared().saveModel(toDisk: model)
            currentLoggedInUserModel?.isSubscribed = switcher.isOn
        }
        BuryPointUtil.event("007", label: "在个人页切换自动解锁开关")
    }
    
    @objc func didGoLogin() {
        if let _ = currentLoggedInUserModel {
            return
        }
        let vc = LNSignInViewController()
        present(vc, animated: true, completion: nil)
        BuryPointUtil.event("008", label: "在个人页点击登录")
    }
    
    // 准备购买金币
    @objc func prepareToBuyCoins() {
        if currentLoggedInUserModel == nil {
            didGoLogin()
            return
        }
        let vc = LNCoinPurchaseViewController()
        navigationController?.pushViewController(vc, animated: true)
        BuryPointUtil.event("005", label: "跳转到金币购买页面", attributes: ["page":"profile"])
    }
    
}



extension LNMeViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 100 + 200 //+ self.margin
        } else if indexPath.section == 1 {
            return 65
        } else if indexPath.section == 2 {
            return 65
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // 赚金币
                if currentLoggedInUserModel == nil {
                    didGoLogin()
                    return
                }
                GoogleAdMobManager.shared().displayVideoAds(inVC: self)
                BuryPointUtil.event("009", label: "在个人页点击谷歌广告")
            } else if indexPath.row == 1 {
                
            } else if indexPath.row == 2 {
                // 交易历史
                if currentLoggedInUserModel == nil {
                    didGoLogin()
                    return
                }
                let vc = LNTransactionHistoryViewController()
                navigationController?.pushViewController(vc, animated: true)
                BuryPointUtil.event("010", label: "在个人页查看交易历史")
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                // Rate Us
                showReviewAppAlert()
                BuryPointUtil.event("011", label: "在个人页给App评分")
            } else if indexPath.row == 1 {
                let vc = LNMeSettingViewController()
                navigationController?.pushViewController(vc, animated: true)
                
            }
        }
    }
    
    private func showReviewAppAlert() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        } else {
            // Fallback on earlier versions
        }
    }
    
    
}

