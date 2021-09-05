//
//  LNMeSettingViewController.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/2/1.
//

import UIKit
import MessageUI
import MBProgressHUD


class LNMeSettingViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    
    private lazy var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.mainGrayColor
        
        self.setupNavigationBar()
        self.createSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("我的设置界面")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("我的设置界面")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = PublicColors.whiteColor
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight + 5)
        }
        
        let titleLabel = UILabel()
        titleLabel.text = self.languageToggle.localizedString("About")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.textColor = PublicColors.blackColor
        titleLabel.textAlignment = .center
        self.customNavigationBarView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
           $0.top.equalTo(statusBarHeight + 5)
           $0.centerX.equalToSuperview()
           $0.width.equalTo(200)
           $0.height.equalTo(40)
        }
        
        let btmLine = UIView()
        btmLine.backgroundColor = PublicColors.mainGrayColor
        self.customNavigationBarView.addSubview(btmLine)
        btmLine.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
        
        let backArrowImg = UIButton(frame: CGRect())
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
        self.navigationController?.popViewController(animated: true)
    }

    func createSubviews() {
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom)
            $0.left.bottom.right.equalToSuperview()
        }
    }

}



extension LNMeSettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if isLogin {
            return 4
        }
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 3
        } else if section == 2 {
            return 1
        } else if section == 3 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.contentView.backgroundColor = PublicColors.whiteColor
        cell.textLabel?.font = UIFont.AvenirMedium(size: 15)
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.textLabel?.text = "App version: "
                let infoDict = Bundle.main.infoDictionary
                if let CFBundleVersion = infoDict?["CFBundleVersion"] as? String {
                    if let CFBundleShortVersionString = infoDict?["CFBundleShortVersionString"] as? String {
                        cell.textLabel?.text = "App version: \(CFBundleVersion) / \(CFBundleShortVersionString)"
                    }
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                cell.textLabel?.text = self.languageToggle.localizedString("Terms of Use")
                createDisclosureIndicator(in: cell)
            } else if indexPath.row == 1 {
                cell.textLabel?.text = self.languageToggle.localizedString("Privacy Policy")
                createDisclosureIndicator(in: cell)
            } else if indexPath.row == 2 {
                cell.textLabel?.text = self.languageToggle.localizedString("Feedback to us")
                createDisclosureIndicator(in: cell)
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                cell.textLabel?.text = self.languageToggle.localizedString("Clear Cache")
                createDisclosureIndicator(in: cell)
                
                let cleanCacheBtn = UIButton()
                cleanCacheBtn.backgroundColor = UIColor(rgb: 0xF0F0F0)
                cleanCacheBtn.setTitle("Clean", for: .normal)
                cleanCacheBtn.setTitleColor(PublicColors.mainBlackColor, for: .normal)
                cleanCacheBtn.titleLabel?.font = UIFont.systemFont(ofSize: 12)
                cleanCacheBtn.layer.cornerRadius = 10.5
                cleanCacheBtn.layer.masksToBounds = true
                cleanCacheBtn.addTarget(self, action: #selector(prepareToCleanCache), for: .touchUpInside)
                cell.contentView.addSubview(cleanCacheBtn)
                cleanCacheBtn.snp.makeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.right.equalTo(-16)
                    $0.width.equalTo(47)
                    $0.height.equalTo(21)
                }
                
                let cacheBytesLabel = UILabel()
                cacheBytesLabel.text = "0.0 Byte(s)"
                cacheBytesLabel.textColor = UIColor(rgb: 0x969898)
                cacheBytesLabel.font = UIFont.systemFont(ofSize: 12)
                cacheBytesLabel.textAlignment = .right
                cell.contentView.addSubview(cacheBytesLabel)
                cacheBytesLabel.snp.makeConstraints {
                    $0.centerY.equalToSuperview()
                    $0.right.equalTo(cleanCacheBtn.snp.left).offset(-8)
                    $0.width.equalTo(65)
                    $0.height.equalTo(15)
                }
            }
        } else if indexPath.section == 3 {
            let logoutBtn = UIButton()
            logoutBtn.setTitle("Sign out", for: .normal)
            logoutBtn.setTitleColor(PublicColors.titleColor, for: .normal)
            logoutBtn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            logoutBtn.layer.cornerRadius = 17
            logoutBtn.layer.masksToBounds = true
            logoutBtn.layer.borderWidth = 1.0
            logoutBtn.layer.borderColor = PublicColors.subTitleColor.cgColor
            logoutBtn.addTarget(self, action: #selector(didLogout), for: .touchUpInside)
            cell.contentView.addSubview(logoutBtn)
            logoutBtn.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview()
                $0.width.equalTo(135)
                $0.height.equalTo(34)
            }
        }
            
        cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
        cell.textLabel?.textColor = PublicColors.mainBlackColor
        
        let btmBorderView = UIView()
        btmBorderView.backgroundColor = PublicColors.mainGrayColor
        cell.contentView.addSubview(btmBorderView)
        btmBorderView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.left.equalTo(15)
            $0.right.equalTo(0)
            $0.height.equalTo(1)
        }
        
        return cell
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
    
    // 准备清除本地缓存
    @objc func prepareToCleanCache() {
        let alertVC = UIAlertController(title: nil, message: "Are you sure cleaning all caches?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I'm sure", style: .default, handler: { (alertAction) in
            MBProgressHUD.showAdded(to: self.view, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.view.makeToast("All cleaned up!")
            }
            BuryPointUtil.event("024", label: "清除缓存")
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) in
            
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    // 退出登录
    @objc func didLogout() {
        let alertVC = UIAlertController(title: nil, message: "Are you sure you want to signing out?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "I'm sure", style: .default, handler: { (alertAction) in
            LNUserModelUtil.shared().removeUserSignedInData()
            self.currentLoggedInUserModel = nil
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNameUserHasLogout), object: self, userInfo: nil)
            self.tableView.reloadData()
            self.view.makeToast(self.languageToggle.localizedString("Logout Successfully!"), position: .center)
            BuryPointUtil.event("025", label: "退出登录成功")
        }))
        alertVC.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (alertAction) in
            
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
}


extension LNMeSettingViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = UIColor.clear
        return v
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
        
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                // 点击的是《Terms of Service》
                let vc = LNSimpleWebViewController(with: "http://saysth.top/lucknovel/terms_of_use")
                navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 1 {
                // 点击的是《Privacy Policy》
                let vc = LNSimpleWebViewController(with: "http://saysth.top/lucknovel/privacy_policy")
                navigationController?.pushViewController(vc, animated: true)
            } else if indexPath.row == 2 {
                sendFeebackEmail()
            }
        } else if indexPath.section == 2 {
            
        } else if indexPath.section == 3 {
            
        }
    }
    
    private func sendFeebackEmail() {
        if MFMailComposeViewController.canSendMail() {
            // 用户已设置邮件账户
            // 邮件服务器
            let mailCompose = MFMailComposeViewController()
            // 设置邮件代理
            mailCompose.mailComposeDelegate = self
            // 设置邮件主题
            mailCompose.setSubject("Feedback(\(LNDeviceUtil.shared().displayName))")
            // 设置收件人
            mailCompose.setToRecipients(["support1@saysth.top"])
            // 设置抄送人
            mailCompose.setCcRecipients(["johnnycheungq@gmail.com"])
            // 设置密抄送
            // mailCompose.setBccRecipients(["victorzhangq@qq.com"])
            // 设置邮件的正文内容
            mailCompose.setMessageBody("Attach the screenshot of Apple payment list below. \n(Settings > profile > view my Apple ID > purchase records)\n\nWe will compensate you for the gold coins you have purchased according to your payment records\n\n My NickName:\(LNUserModelUtil.shared().model?.nickname ?? ""),\nUserid:\(LNUserModelUtil.shared().model?.userId ?? "")\nEmail:\(LNUserModelUtil.shared().model?.email ?? "")", isHTML: false)
            // 弹出邮件发送视图
            present(mailCompose, animated: true, completion: nil)
        } else {
            let alertVC = UIAlertController(title: nil, message: "Please set the login email first", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: { (alertAction) in
            }))
            present(alertVC, animated: true, completion: nil)
        }
    }
    
}


extension LNMeSettingViewController : MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
