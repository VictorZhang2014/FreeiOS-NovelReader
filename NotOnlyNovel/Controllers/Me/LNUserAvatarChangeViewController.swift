//
//  LNUserAvatarChangeViewController.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/2.
//
//  用户头像更改

import UIKit
import MBProgressHUD


class LNUserAvatarChangeViewController: LNBaseViewController {
    
    public var userAvatarUpdatedCompletion: ((_ userAvatarUrl: String, _ userAvatarImage: UIImage?) -> Void)? = nil
    
    private let customNavigationBarView = UIView()
    private let userAvatarImg = UIImageView()
    
    private var isFromCamera: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.whiteColor

        self.setupNavigationBar()
        self.setupSubviews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("修改头像")
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("修改头像")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = PublicColors.whiteColor
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(navigationBarAndStatusHeight)
        }
        
        let backArrowImg = UIButton(frame: CGRect())
        backArrowImg.setImage(UIImage(named: "black-left-arrow-icon"), for: .normal)
        backArrowImg.imageEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        backArrowImg.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        self.customNavigationBarView.addSubview(backArrowImg)
        backArrowImg.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight)
            $0.left.equalTo(0)
            $0.width.equalTo(44)
            $0.height.equalTo(44)
        }
    }

    @objc func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupSubviews() {
        let uploadTipLabel = UILabel()
        uploadTipLabel.text = self.languageToggle.localizedString("Set your profile picture")
        uploadTipLabel.textColor = PublicColors.mainBlackColor
        uploadTipLabel.font = UIFont.boldSystemFont(ofSize: 25)
        uploadTipLabel.textAlignment = .center
        self.view.addSubview(uploadTipLabel)
        uploadTipLabel.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.equalTo(20)
            $0.right.equalTo(-20)
            $0.height.equalTo(30)
        }
        
        let imgHeight: CGFloat = 230
        
        userAvatarImg.backgroundColor = PublicColors.mainGrayColor
        if let _currentLoggedInUserModel = currentLoggedInUserModel {
            if _currentLoggedInUserModel.userAvatar.count > 0 {
                userAvatarImg.sd_setImage(with: URL(string: _currentLoggedInUserModel.userAvatar), completed: nil)
            }
        }
        userAvatarImg.layer.cornerRadius = imgHeight / 2
        userAvatarImg.layer.masksToBounds = true
        userAvatarImg.isUserInteractionEnabled = true
        userAvatarImg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(willUploadPhoto)))
        self.view.addSubview(userAvatarImg)
        userAvatarImg.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50)
            $0.width.height.equalTo(imgHeight)
        }
        
        let uploadBtn = UIButton()
        uploadBtn.setTitle(self.languageToggle.localizedString("Select a photo"), for: .normal)
        uploadBtn.setTitleColor(PublicColors.whiteColor, for: .normal)
        uploadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        uploadBtn.backgroundColor = PublicColors.mainRedColor
        uploadBtn.layer.cornerRadius = 6
        uploadBtn.addTarget(self, action: #selector(willUploadPhoto), for: .touchUpInside)
        self.view.addSubview(uploadBtn)
        uploadBtn.snp.makeConstraints {
            $0.top.equalTo(userAvatarImg.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(40)
        }

        
        // 本地缓存的头像图片
        let cacheUtil = LNCacheUtil()
        if let userAvatarImageData = cacheUtil.getAnyValue(forKey: kUserAvatarLocalKey) as? Data {
            userAvatarImg.image = UIImage(data: userAvatarImageData)
        }
    }
    
    @objc func willUploadPhoto() {
         var alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
         if (UIDevice.current.userInterfaceIdiom == .pad) {
             alertVC = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
         }
         alertVC.addAction(UIAlertAction(title: self.languageToggle.localizedString("Take a photo"), style: .default, handler: { (action) in
             self.openCamera(allowsEditing: true)
         }))
         alertVC.addAction(UIAlertAction(title: self.languageToggle.localizedString("Photo album"), style: .default, handler: { (action) in
             self.openChoosePicture(allowsEditing: true)
         }))
         alertVC.addAction(UIAlertAction(title: self.languageToggle.localizedString("Cancel"), style: .cancel, handler: { (action) in
         }))
         self.present(alertVC, animated: true, completion: nil)
    }
    
    private func openCamera(allowsEditing: Bool) {
        self.isFromCamera = true
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .camera
        imgPicker.allowsEditing = allowsEditing
        imgPicker.modalPresentationStyle = .fullScreen
        self.present(imgPicker, animated: true, completion: nil)
    }
    
    private func openChoosePicture(allowsEditing: Bool) {
        self.isFromCamera = false
        let imgPicker = UIImagePickerController()
        imgPicker.delegate = self
        imgPicker.sourceType = .photoLibrary
        imgPicker.allowsEditing = allowsEditing
        imgPicker.modalPresentationStyle = .fullScreen
        self.present(imgPicker, animated: true, completion: nil)
    }
}


extension LNUserAvatarChangeViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //var imgFileExt: String = ""
        //if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerOriginalImage")] as? UIImage {
        //}
        guard let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage else {
            picker.dismiss(animated: true, completion: nil)
            return
        }
        self.userAvatarImg.image = image
        picker.dismiss(animated: true, completion: nil)
        
        // 暂时先写成假的
        MBProgressHUD.showAdded(to: self.view, animated: true)
        if let _userAvatarUpdatedCompletion = self.userAvatarUpdatedCompletion {
            _userAvatarUpdatedCompletion("", image)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            MBProgressHUD.hide(for: self.view, animated: true)
            self.view.makeToast("Uploaded Success!", position: .center)
        }
        
    
//        let s3Manager = AWSBucketS3Manager(imageBucketWith: AWSBucketS3UploadType.userAvatar)
//        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return } // 0.7 is JPG quality
//        s3Manager.upload(withFileData: imageData, uploadKeyName: nil, progress: { (progress) in
//        }) { (imageFilepath, error) in
//            DispatchQueue.main.async {
//                MBProgressHUD.hide(for: self.view, animated: true)
//                if let _errMsg = error {
//                    self.view.makeToast("\(_errMsg)", position: .center)
//                    return
//                }
//                // 更新到服务器
//                let httpManager = YBHttpManager()
//                httpManager.post(.updateUserInfo, formData: ["user_avatar":imageFilepath], isAuthorized: true) { (respDict, error) in
//                    if let _error = error {
//                        self.view.makeToast("\(_error.localizedDescription)", position: .center)
//                        return
//                    }
//                    self.view.makeToast(self.languageToggle.localizedString("Update success"), position: .center)
//
//                    if let userModel = YBUserModelUtil.shared().getData() {
//                        userModel.user_avatar = "\(s3Manager.domainPrefix)\(imageFilepath)"
//                        YBUserModelUtil.shared().saveModel(toDisk: userModel)
//
//                        if let _userAvatarUpdatedCompletion = self.userAvatarUpdatedCompletion {
//                            _userAvatarUpdatedCompletion(userModel.user_avatar)
//                        }
//                    }
//
//                    let userAvatarUrl = "https://static.cdn.aws.saysth.top/\(imageFilepath)"
//
//                    let userSelfInfo = V2TIMUserFullInfo()
//                    userSelfInfo.nickName = self.userModel.nickname
//                    userSelfInfo.faceURL = userAvatarUrl
//                    var customInfo: [String:Data] = [:]
//                    if let countryCodeData = self.userModel.country_code.data(using: .utf8) {
//                        customInfo["Tag_Profile_Custom_Country"] = countryCodeData
//                    }
//                    if let deviceData = "iOS".data(using: .utf8) {
//                        customInfo["Tag_Profile_Custom_Device"] = deviceData
//                    }
//                    let levelData = Swift.withUnsafeBytes(of: self.userModel.level, { Data($0) })
//                    customInfo["Tag_Profile_Custom_Level"] = levelData
//                    userSelfInfo.customInfo = customInfo
//                    V2TIMManager.sharedInstance()?.setSelfInfo(userSelfInfo, succ: {
//                        print("腾讯IM 设置当前登录者信息成功！")
//                    }, fail: { (code, error) in
//                        print("腾讯IM 设置当前登录者信息失败！")
//                    })
//
//                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kYBNotificationNameUserUpdateAvatar), object: nil, userInfo: ["image":userAvatarUrl])
//                }
//            }
//        }
    }

}

