//
//  SSBaseViewController.swift
//  Yobo
//
//  Created by Johnny Cheung on 2020/10/17.
//  Copyright © 2020 TelaBytes, Inc. All rights reserved.
//

import UIKit


class LNBaseViewController: UIViewController {

    var statusBarHeight: CGFloat {
        get {
            return UIApplication.shared.statusBarFrame.size.height // iPhone X系列的是50的高度；非刘海屏的是20
        }
    }
    
    var navigationBarHeight: CGFloat {
        get {
            return self.navigationController?.navigationBar.frame.height ?? 44
        }
    }
    
    var navigationBarAndStatusHeight: CGFloat {
        get {
            return statusBarHeight + navigationBarHeight
        }
    }
    
    var screenWidth: CGFloat {
        get {
            return UIScreen.main.bounds.size.width
        }
    }
    
    var screenHeight: CGFloat {
        get {
            return UIScreen.main.bounds.size.height
        }
    }
    
    var viewWidth: CGFloat {
        get {
            return view.bounds.size.width
        }
    }
    
    var viewHeight: CGFloat {
        get {
            return view.bounds.size.height
        }
    }
    
    var languageToggle = LNLanguageToggle.shared()
    
    // 当前已登录的用户
    var currentLoggedInUserModel: LNUserModel? = LNUserModelUtil.shared().model
    
    // 是否已登录
    var isLogin: Bool {
        get {
            if currentLoggedInUserModel == nil || currentLoggedInUserModel?.userId == nil || currentLoggedInUserModel?.userToken == nil {
                return false
            }
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.whiteColor
    }
    
    func getSafeBottomHeight() -> CGFloat {
        if #available(iOS 11.0, *) {
            if let safeBottomHeight = UIApplication.shared.delegate?.window??.safeAreaInsets.bottom {
                return safeBottomHeight
            }
        }
        return 0.0
    }
//    
//    // 根据userId获取用户信息
//    func getUserModel(byUserId userId: String, completion: @escaping ((_ aUserModel: YBUserModel?, _ error: String?) -> (Void))) {
//        // 1.先从本地磁盘查找用户信息
//        let userCachedKey = "\(kUserInfoKey)_\(userId)"
//        if let userDict = YBCacheUtil().getDictValue(forKey: userCachedKey) {
//            if let model = YBUserModelUtil.convertDict(toModel: userDict) {
//                completion(model, nil)
//                return
//            }
//        }
//        // 2.从网络请求用户的个人信息
//        let httpManager = LNHttpManager()
//        let apiurl = httpManager.getAPIUrlPath(.getUserInfoList, suffixParam: "\(userId)")
//        httpManager.getWithUrl(apiurl) { (respDict, error) in
//            if let _error = error {
//                completion(nil, "\(_error.localizedDescription)")
//                return
//            }
//            if let status = respDict?["status"] as? Bool {
//                if status {
//                    if let dataArray = respDict?["data"] as? [[String:Any]] {
//                        if let _dataDict = dataArray.first {
//                            YBCacheUtil().saveValue(_dataDict, forKey: userCachedKey) // 缓存到本地
//                            if let model = YBUserModelUtil.convertDict(toModel: _dataDict) {
//                                completion(model, nil)
//                            }
//                        }
//                    } else {
//                        completion(nil, nil)
//                    }
//                } else {
//                    completion(nil, nil)
//                }
//            }
//        }
//    }
//
//    // 根据userIds批量获取用户信息
//    func getUserModels(byUserId userIds: [String], completion: @escaping ((_ aUserModel: [YBUserModel]?, _ error: String?) -> (Void))) {
//        // 1.先从本地磁盘查找用户信息
//        var userIdsNoData: [String] = []
//        var allUserModels: [YBUserModel] = []
//        for userId in userIds {
//            let userCachedKey = "\(kUserInfoKey)_\(userId)"
//            if let userDict = YBCacheUtil().getDictValue(forKey: userCachedKey) {
//                if let model = YBUserModelUtil.convertDict(toModel: userDict) {
//                    allUserModels.append(model)
//                } else {
//                    userIdsNoData.append(userId)
//                }
//            } else {
//                userIdsNoData.append(userId)
//            }
//        }
//        if userIdsNoData.count <= 0 {
//            completion(allUserModels, nil)
//            return
//        }
//        // 2.从网络请求用户的个人信息
//        let userIdStr = userIdsNoData.joined(separator: ",")
//        let httpManager = LNHttpManager()
//        let apiurl = httpManager.getAPIUrlPath(.getUserInfoList, suffixParam: "\(userIdStr)")
//        httpManager.getWithUrl(apiurl) { (respDict, error) in
//            if let _error = error {
//                completion(nil, "\(_error.localizedDescription)")
//                return
//            }
//            if let status = respDict?["status"] as? Bool {
//                if status {
//                    if let dataArray = respDict?["data"] as? [[String:Any]] {
//                        for d in dataArray {
//                            if let model = YBUserModelUtil.convertDict(toModel: d) {
//                                YBCacheUtil().saveValue(d, forKey: "\(kUserInfoKey)_\(model.user_id)") // 缓存到本地
//                                allUserModels.append(model)
//                            }
//                        }
//                        completion(allUserModels, nil)
//                    }
//                } else {
//                    completion(nil, "Unknown Error!")
//                }
//            }
//        }
//    }
    
    func alert(withMessage message: String, okHandler: (() -> Void)? = nil, cancelHandler: (() -> Void)? = nil) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: languageToggle.localizedString("OK"), style: .default, handler: { (alertAction) in
            if let _okHandler = okHandler {
                _okHandler()
            }
        }))
        alertVC.addAction(UIAlertAction(title: languageToggle.localizedString("Cancel"), style: .default, handler: { (alertAction) in
            if let _cancelHandler = cancelHandler {
                _cancelHandler()
            }
        }))
        present(alertVC, animated: true, completion: nil)
    }
    
    func alert(with message: String) {
        let alertVC = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func alertWarningNoProxy() {
        alert(with: languageToggle.localizedString("DO NOT USE PROXY SOFTWARES OR ANY PROXY SOFTWARES! These proxy softwares, including Charles, Fiddler, Wireshark or any other http intercepter softwares are not allowed while using LuckyNovel app."))
    }

}
