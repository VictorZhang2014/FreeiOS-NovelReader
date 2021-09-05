//
//  YBSignInViewController.swift
//  Yobo
//
//  Created by VictorZhang on 2020/7/11.
//  Copyright © 2020 TelaBytes. All rights reserved.
//
//  注册页面

import UIKit
import MBProgressHUD


class LNSignUpViewController: LNBaseViewController {
    
    private let customNavigationBarView = UIView()
    private let nicknameTextField = UITextField()
    private let accountTextField = UITextField()
    private let passwordTextField = UITextField()
    private let btnCheckBox = UIButton()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()

        self.createViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("注册页面")
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("注册页面")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupNavigationBar() {
        let statusFrame = UIApplication.shared.statusBarFrame
        let navHeight = statusFrame.size.height + 44
        let statusBarHeight = statusFrame.size.height
        
        self.customNavigationBarView.backgroundColor = UIColor.white
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(navHeight + 5)
        }
        
//        let btmLine = UIView()
//        btmLine.backgroundColor = UIColor(rgb: 0xe6e6e6)
//        self.customNavigationBarView.addSubview(btmLine)
//        btmLine.snp.makeConstraints {
//            $0.left.right.equalToSuperview()
//            $0.height.equalTo(1)
//            $0.bottom.equalToSuperview()
//        }
        
        let backArrowImg = UIButton(frame: CGRect())
        backArrowImg.setImage(UIImage(named: "arrow-down-black"), for: .normal)
        backArrowImg.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backArrowImg.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.customNavigationBarView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight)
            $0.left.equalTo(5)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
        
        let signInBtn = UIButton(frame: CGRect())
        signInBtn.setTitle(languageToggle.localizedString("Sign In"), for: .normal)
        signInBtn.setTitleColor(PublicColors.titleColor, for: .normal)
        signInBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signInBtn.titleLabel?.textAlignment = .right
        signInBtn.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.customNavigationBarView.addSubview(signInBtn)
        signInBtn.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight)
            $0.right.equalTo(0)
            $0.width.equalTo(100)
            $0.height.equalTo(44)
        }
    }
    
    @objc func goBack() {
        self.didCloseKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    private func createViews() {
        let tipLabel = UILabel()
        tipLabel.text = languageToggle.localizedString("Join LuckyNovel community after registering")
        tipLabel.textColor = PublicColors.titleColor
        tipLabel.font = UIFont.boldSystemFont(ofSize: 17)
        tipLabel.textAlignment = .center
        self.view.addSubview(tipLabel)
        tipLabel.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(35)
        }
        
        // 昵称
        nicknameTextField.placeholder = self.languageToggle.localizedString("Your nickname")
        nicknameTextField.borderStyle = .none
        nicknameTextField.clearButtonMode = .whileEditing
        nicknameTextField.backgroundColor = PublicColors.mainGrayColor
        nicknameTextField.layer.cornerRadius = 5
        nicknameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 45))
        nicknameTextField.leftViewMode = .always
        self.view.addSubview(nicknameTextField)
        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(tipLabel.snp.bottom).offset(30)
            $0.left.equalTo(40)
            $0.right.equalTo(-40)
            $0.height.equalTo(45)
        }
        
        // 账号
        accountTextField.placeholder = self.languageToggle.localizedString("Please input your email")
        accountTextField.borderStyle = .none
        accountTextField.clearButtonMode = .whileEditing
        accountTextField.keyboardType = .emailAddress
        accountTextField.textContentType = .emailAddress
        accountTextField.backgroundColor = PublicColors.mainGrayColor
        accountTextField.layer.cornerRadius = 5
        accountTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 45))
        accountTextField.leftViewMode = .always
        self.view.addSubview(accountTextField)
        accountTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(10)
            $0.left.equalTo(40)
            $0.right.equalTo(-40)
            $0.height.equalTo(45)
        }
        
        // 密码
        passwordTextField.placeholder = self.languageToggle.localizedString("Please input your password")
        passwordTextField.borderStyle = .none
        //passwordTextField.clearButtonMode = .whileEditing
        if #available(iOS 11.0, *) {
            //passwordTextField.textContentType = .password
        } else {
            // Fallback on earlier versions
        }
        passwordTextField.backgroundColor = PublicColors.mainGrayColor
        passwordTextField.layer.cornerRadius = 5
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 7, height: 45))
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 45))
        passwordTextField.leftViewMode = .always
        passwordTextField.isSecureTextEntry = true
        self.view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints {
            $0.top.equalTo(accountTextField.snp.bottom).offset(10)
            $0.left.equalTo(40)
            $0.right.equalTo(-40)
            $0.height.equalTo(45)
        }
        
        btnCheckBox.setImage(UIImage(named: "gray-check-box"), for: .normal)
        btnCheckBox.setImage(UIImage(named: "red-check-box"), for: .selected)
        btnCheckBox.addTarget(self, action: #selector(didCheckAgreements(_:)), for: .touchUpInside)
        self.view.addSubview(btnCheckBox)
        btnCheckBox.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.left.equalTo(passwordTextField.snp.left).offset(8)
            $0.width.equalTo(27)
            $0.height.equalTo(27)
        }
        
        let agreementLabel = UILabel()
        agreementLabel.isUserInteractionEnabled = true
        agreementLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didOpenAgreementsVC)))
        agreementLabel.text = self.languageToggle.localizedString("If being marked, indicates that you have agreed on our Terms of Services.")
        agreementLabel.textColor = UIColor.lightGray
        agreementLabel.font = UIFont.systemFont(ofSize: 14)
        agreementLabel.textAlignment = .left
        agreementLabel.numberOfLines = 0
        let agreementLabelNewHeight = agreementLabel.sizeThatFits(CGSize(width: self.view.bounds.size.width-40*2-10, height: 60)).height
        self.view.addSubview(agreementLabel)
        agreementLabel.snp.makeConstraints {
            $0.top.equalTo(passwordTextField.snp.bottom).offset(20)
            $0.left.equalTo(btnCheckBox.snp.right).offset(10)
            $0.right.equalTo(-40)
            $0.height.equalTo(agreementLabelNewHeight + 5)
        }
        
        let signUpBtn = UIButton()
        signUpBtn.setTitle(self.languageToggle.localizedString("Sign up Now"), for: .normal)
        signUpBtn.setTitleColor(UIColor.white, for: .normal)
        signUpBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        signUpBtn.titleLabel?.textAlignment = .center
        signUpBtn.backgroundColor = PublicColors.mainPinkColor
        signUpBtn.layer.cornerRadius = 22
        signUpBtn.addTarget(self, action: #selector(didSignUpNow), for: .touchUpInside)
        self.view.addSubview(signUpBtn)
        signUpBtn.snp.makeConstraints {
            $0.top.equalTo(btnCheckBox.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(44)
        }
        
        nicknameTextField.becomeFirstResponder()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didCloseKeyboard)))
    }
    
    @objc func didOpenAgreementsVC() {
        self.didCloseKeyboard()
        
//        let signUpAgreementsVC = YBSignUpAgreementsViewController()
//        navigationController?.pushViewController(signUpAgreementsVC, animated: true)
    }
    
    @objc func didCheckAgreements(_ button: UIButton) {
        button.isSelected = !button.isSelected
    }
    
    @objc func didSignUpNow() {
        let nicknameText = self.nicknameTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let _nicknameText = nicknameText else {
            return
        }
        if _nicknameText.count < 1 || _nicknameText.count > 20 {
            self.view.makeToast(self.languageToggle.localizedString("The length of your nickname should be in 1-20."), position: .center)
            return
        }
        let accountText = self.accountTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let _accountText = accountText else {
            return
        }
//        if !YBCommonUtil.isValidEmail(_accountText) {
//            self.view.makeToast(self.languageToggle.localizedString("Invalid email address, please try again or change another email."), position: .center)
//            return
//        }
        let passwordText = self.passwordTextField.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard let _passwordText = passwordText else {
            return
        }
        if _passwordText.count < 6 || _passwordText.count > 30 {
            self.view.makeToast(self.languageToggle.localizedString("The length of password should be in 6-30."), position: .center)
            return
        }
        if !self.btnCheckBox.isSelected {
            self.view.makeToast(self.languageToggle.localizedString("Oops~ Dear user, you have to agree and read on our Terms of Services first before signing up."), position: .center)
            return
        }
        
        self.didCloseKeyboard()
        
        if LNDeviceUtil.isSetHTTPProxy() {
            alertWarningNoProxy()
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        var currentCountryCode: String = self.languageToggle.language
        if let firstLanuage = NSLocale.preferredLanguages.first {
            currentCountryCode = String(firstLanuage.split(separator: Character("-")).last ?? "US")
            if currentCountryCode.lowercased() == "hans" {
                currentCountryCode = "HK"
            }
        }
//
//        let params: [String: String] = ["nickname":_nicknameText,
//                                       "email":_accountText,
//                                       "password":_passwordText,
//                                       "device_type":"iOS",
//                                       "country_code":currentCountryCode,
//                                       "device_token": LNDeviceUtil.shared().deviceToken,
//                                       "registrationID": LNDeviceUtil.registrationID()]
//        let manager = LNHttpManager()
//        manager.post(.signUp, formData: params, isAuthorized: false) { (respDict, error) in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            if let _error = error {
//                self.view.makeToast("\(_error.localizedDescription)", position: .center)
//                BuryPointUtil.event("10009", label: "注册失败", attributes: ["err":"\(_error.localizedDescription) -- CountryCode=\(currentCountryCode)"])
//                return
//            }
//            guard let _respDict = respDict else { return }
//            if let status = _respDict["status"] as? Bool {
//                if !status {
//                    if let status_code = _respDict["status_code"] as? Int {
//                        if status_code == -1 {
//                            var errMsg = self.languageToggle.localizedString("The account already exists, please input a different email.")
//                            if let platform = _respDict["platform"] as? String {
//                                if platform == "apple" {
//                                    errMsg = self.languageToggle.localizedString("Please Sign In with Apple.")
//                                }
//                            }
//                            self.view.makeToast(errMsg, position: .center)
//                        }
//                        BuryPointUtil.event("10022", label: "注册时邮箱已存在")
//                        return
//                    }
//                    if let err_msg = _respDict["err_msg"] as? String {
//                        self.view.makeToast("\(err_msg)", position: .center)
//                        BuryPointUtil.event("10023", label: "注册时Server返回错误", attributes: ["err":err_msg])
//                        return
//                    }
//                }
//                if let dataDict = _respDict["data"] as? [String: Any] {
//                    // 保存数据到磁盘
//                    YBUserModelUtil.shared().saveData(toDisk: dataDict)
//
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kYBNotificationTabBarVCCreation), object: nil)
//
//                    MobClick.event("10001", label: "注册成功")
//                }
//            }
//        }
        
//        let deadlineTime = DispatchTime.now() + .seconds(2)
//        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//        }
    }
    
    
    @objc func didCloseKeyboard() {
        if self.nicknameTextField.canResignFirstResponder {
            self.nicknameTextField.resignFirstResponder()
        }
        if self.accountTextField.canResignFirstResponder {
            self.accountTextField.resignFirstResponder()
        }
        if self.passwordTextField.canResignFirstResponder {
            self.passwordTextField.resignFirstResponder()
        }
    }
    
    
}

