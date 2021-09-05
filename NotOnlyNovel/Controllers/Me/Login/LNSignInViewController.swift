//
//  LNSignInViewController.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/1.
//

import UIKit
import Lottie
import AuthenticationServices
import MBProgressHUD


class LNSignInViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    private var lottieAnimationView: AnimationView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.whiteColor
        
        setupNavigationBar()
        createSubviews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackgroundNotificationEvent(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForegroundNotificationEvent(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func didEnterBackgroundNotificationEvent(_ notification: NSNotification) {
        lottieAnimationView?.stop()
    }
    
    @objc func willEnterForegroundNotificationEvent(_ notification: NSNotification) {
        lottieAnimationView?.play()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("登录界面")
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("登录界面")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = UIColor.clear
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight)
        }
        
        let backArrowImg = UIButton(frame: CGRect())
        backArrowImg.setImage(UIImage(named: "black-X-close-icon"), for: .normal)
        backArrowImg.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backArrowImg.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.customNavigationBarView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            if LNDeviceUtil.shared().isiPhoneXFamily {
                $0.top.equalTo(10)
            } else {
                $0.top.equalTo(statusBarHeight)
            }
            $0.right.equalTo(-5)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
    }
    
    @objc func goBack() {
        lottieAnimationView?.stop()
        lottieAnimationView?.removeFromSuperview()
        dismiss(animated: true, completion: nil)
    }

    private func createSubviews() {
        lottieAnimationView = AnimationView(name: "35787-robot-says-hello")
        lottieAnimationView?.loopMode = .loop
        if (UIDevice.current.userInterfaceIdiom == .pad) {
            lottieAnimationView?.frame = CGRect(x: -110, y: navigationBarAndStatusHeight, width: self.view.bounds.size.width, height: 250)
        } else {
            lottieAnimationView?.frame = CGRect(x: 20, y: navigationBarAndStatusHeight, width: self.view.bounds.size.width, height: 250)
        }
        if let _lottieAnimationView = lottieAnimationView {
            view.insertSubview(_lottieAnimationView, at: 0)
            _lottieAnimationView.play()
        }
        
        let titleLabel = UILabel()
        titleLabel.text = "LuckyNovel"
        titleLabel.textColor = PublicColors.blackColor
        titleLabel.font = UIFont.ArialRoundedMTBold(size: 28) //.boldSystemFont(ofSize: 28)
        titleLabel.textAlignment = .center
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            if let _lottieAnimationView = self.lottieAnimationView {
                $0.top.equalTo(_lottieAnimationView.snp.bottom).offset(-5)
            }
            $0.left.right.equalToSuperview()
            $0.height.equalTo(33)
        }
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = "Indulge in reading, get lucky in life"
        subtitleLabel.textColor = UIColor.lightGray
        subtitleLabel.font = UIFont.AvenirMedium(size: 17) //.systemFont(ofSize: 17)
        subtitleLabel.textAlignment = .center
        view.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(20)
        }
        
        if #available(iOS 13.0, *) {
            let authorizationButton = ASAuthorizationAppleIDButton()
            authorizationButton.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchUpInside)
            self.view.addSubview(authorizationButton)
            authorizationButton.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.width.equalTo(200)
                $0.bottom.equalTo(-150)
                $0.height.equalTo(44)
            }
        } else {
            // Fallback on earlier versions
            let signUpBtn = UIButton()
            signUpBtn.setTitle(self.languageToggle.localizedString("Sign Up"), for: .normal)
            signUpBtn.setTitleColor(UIColor.white, for: .normal)
            signUpBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            signUpBtn.backgroundColor = PublicColors.mainPinkColor
            signUpBtn.layer.cornerRadius = 22
            signUpBtn.addTarget(self, action: #selector(didGoToSignUpVC), for: .touchUpInside)
            self.view.addSubview(signUpBtn)
            signUpBtn.snp.makeConstraints {
                $0.centerX.equalToSuperview()
                $0.width.equalTo(200)
                $0.height.equalTo(44)
                $0.bottom.equalTo(-150)
            }
        }
        
        let descLabel = UILabel()
        descLabel.text = "You agree to our Terms of Use and Privacy Policy if you continue."
        descLabel.textColor = PublicColors.subTitleColor
        descLabel.font = UIFont.systemFont(ofSize: 12)
        descLabel.textAlignment = .center
        descLabel.numberOfLines = 0
        descLabel.isUserInteractionEnabled = true
        let highlightedStrings = ["Terms of Use", "Privacy Policy"]
        descLabel.attributedText = LNStringUtility.attributedText(withString: descLabel.text ?? "", highlightedString: highlightedStrings, font: descLabel.font, color: PublicColors.mainPinkColor, isBold: true, isUnderline: true)
        descLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapLabel(_:))))
        view.addSubview(descLabel)
        descLabel.snp.makeConstraints {
            $0.left.equalTo(40)
            $0.right.equalTo(-40)
            $0.height.equalTo(30)
            $0.bottom.equalTo(-50)
        }
    }
    
    @objc func handleAuthorizationAppleIDButtonPress() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func didGoToSignUpVC() {
        let vc = LNSignUpViewController()
        let navVC = LNBaseNavigationController(rootViewController: vc)
        present(navVC, animated: true, completion: nil)
    }
    
    @objc func didTapLabel(_ gesture: UITapGestureRecognizer) {
        if let label = gesture.view as? UILabel {
            if let text = label.text {
                let termsOfUseRange = (text as NSString).range(of: "Terms of Use")
                let privacyRange = (text as NSString).range(of: "Privacy Policy")
                let labelPoint = gesture.location(in: label)
                
                if LNStringUtility.respondEventWithinPartOfLabel(label: label, inRange: termsOfUseRange, inPoint: labelPoint) {
                     // 点击的是《Terms of Use》
                    if let url = URL(string: "http://saysth.top/lucknovel/terms_of_use") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } else if LNStringUtility.respondEventWithinPartOfLabel(label: label, inRange: privacyRange, inPoint: labelPoint) {
                    // 点击的是《Privacy Policy》
                    if let url = URL(string: "http://saysth.top/lucknovel/privacy_policy") {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
    
    deinit {
        print("LNSignInViewController has deallocated!")
    }

}


extension LNSignInViewController: ASAuthorizationControllerDelegate {
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
            case let appleIDCredential as ASAuthorizationAppleIDCredential:
                guard let identityToken = appleIDCredential.identityToken else { return }
                //guard let authorizationCode = appleIDCredential.authorizationCode else { return }
                let userIdentifier = appleIDCredential.user
                let fullName = "\(appleIDCredential.fullName?.givenName ?? "") \(appleIDCredential.fullName?.familyName ?? "")"
                let email = appleIDCredential.email ?? ""
                
                let strIdentityToken = String(decoding: identityToken, as: UTF8.self)
                //let strAuthorizationCode = String(decoding: authorizationCode, as: UTF8.self)
                self.signIn(with: ["uniqueId" : userIdentifier,
                                   "token" : strIdentityToken,
                                   "name" : fullName,
                                   "email" : email,
                                   "platform" : "apple"])

                //["country_code": "CN", "platform": "apple", "password": "001406.bf95b0e9e4ff4733aa50d4c86ea98e81.0312", "token": "eyJraWQiOiJlWGF1bm1MIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLnRlbGFieXRlcy5ub3Rvbmx5bm92ZWwiLCJleHAiOjE2MTIzMjIxMTYsImlhdCI6MTYxMjIzNTcxNiwic3ViIjoiMDAxNDA2LmJmOTViMGU5ZTRmZjQ3MzNhYTUwZDRjODZlYTk4ZTgxLjAzMTIiLCJjX2hhc2giOiJYTVRtd3Fhb2Q2OU1yU3ROQk5Mb1JRIiwiZW1haWwiOiJxMmE5a3Qya0BpY2xvdWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOiJ0cnVlIiwiYXV0aF90aW1lIjoxNjEyMjM1NzE2LCJub25jZV9zdXBwb3J0ZWQiOnRydWV9.ACxQ54rpz-A_YNLSICzmkgi8vVf0GKrocvKsIDhhJuhIgsQn3G5sti6lHDOKLxwtjXKPuJm7vUtY85pNJxLkX3WNS1yteOxQbVwTTETideMDvfVKhT6ILpmKUhs7Av5SmdebMP3k4YmOoskt9jF2dJ-cOC6ggUPFFvlYDae6emqnOTqmfCc5AFr-cDgEY78SmEb-rhSz7Bjb-9pFZxoO9t9JmY8RiznzxQHN7OMan-2yJ76nyyzL9TvEjunwetSn26AsdRDUTVI1J4aPMVktfDcqaaEihJuxHLrKbSS_k-lkkuZK1BKdx-_gNJJJlZTM8BeWMbMLgvqngk9hj_z2iw", "uniqueId": "001406.bf95b0e9e4ff4733aa50d4c86ea98e81.0312", "device_type": "iOS", "nickname": " ", "email": "", "device_token": "963dcb656acf2bc34a7e52f93915ca474eafb861eaf669c54e7d0ffb3041ac10"]
                
            // case let passwordCredential as ASPasswordCredential:
            //     alert(with: "")
            default:
                break
        }
    }

    private func signIn(with partyParams: [String:String]) {
        var hud: MBProgressHUD?
        DispatchQueue.main.async {
            hud = MBProgressHUD.showAdded(to: self.view, animated: true)
            hud?.label.text = "Please wait for signing in..."
        }
        
        var currentCountryCode: String = self.languageToggle.language
        if let firstLanuage = NSLocale.preferredLanguages.first {
            currentCountryCode = String(firstLanuage.split(separator: Character("-")).last ?? "US")
            if currentCountryCode.lowercased() == "hans" {
                currentCountryCode = "HK"
            }
        }
        
        let params: [String: String] = ["nickname": partyParams["name"] ?? "",
                                       "email": partyParams["email"] ?? "",
                                       "password": partyParams["uniqueId"] ?? "",
                                       "token": partyParams["token"] ?? "",
                                       "uniqueId" : partyParams["uniqueId"] ?? "",
                                       "device_type": "iOS",
                                       "country_code": currentCountryCode,
                                       "device_token": LNDeviceUtil.shared().deviceToken,
                                       //"registrationID": LNDeviceUtil.registrationID()
        ]
        //print("params=\(params)")
        BuryPointUtil.event("022", label: "点击Apple登录")
        
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1SignIn, suffixParam: "?platform=apple")
        httpManager.post(apiurl, formData: params) { (respDict, error) in
            hud?.hide(animated: true)
            if let _err = error {
                self.view.makeToast(_err.localizedDescription)
                return
            }
            if let status = respDict?["status"] as? Bool {
                if !status {
                    if let err_msg = respDict?["err_msg"] as? String {
                        self.view.makeToast(err_msg)
                    }
                    return
                }
            }
            if let dataDict = respDict?["data"] as? [String: Any] {
                // ["nickname": "LuckyOne_123", "email": , "gender": 0, "phone": , "country_code": CN, "user_avatar": , "user_id": 4093, "user_intro": , "token": "xxx"]
                LNUserModelUtil.shared().saveData(toDisk: dataDict)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNameUserSignedInSuccess), object: nil, userInfo: nil)
                self.goBack()
                
                BuryPointUtil.event("023", label: "AppleID登录成功")
            }
        }
    }
    
}



extension LNSignInViewController: ASAuthorizationControllerPresentationContextProviding {
    
    @available(iOS 13.0, *)
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}
