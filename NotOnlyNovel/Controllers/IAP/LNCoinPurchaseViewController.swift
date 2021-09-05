//
//  LNCoinPurchaseViewController.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/1.
//

import UIKit
import MBProgressHUD
import SwiftyStoreKit


class LNCoinPurchaseViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    
    private lazy var tableView = UITableView()
    private lazy var productList: [LNCoinPurchaseProductModel] = []
    
    private var isRetried3TimesToUpdateCoins: Int = 0 // 是否尝试了3次去更新金币接口
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        createSubviews()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        BuryPointUtil.beginLogPageView("购买金币页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("购买金币页")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    func setupNavigationBar() {
        customNavigationBarView.backgroundColor = PublicColors.whiteColor
        view.addSubview(customNavigationBarView)
        customNavigationBarView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(navigationBarAndStatusHeight + 5)
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
        if presentingViewController != nil {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func createSubviews() {
        tableView.backgroundColor = UIColor.clear
        //tableView.contentInset = UIEdgeInsets(top: 0, left: self.margin, bottom: 0, right: -self.margin)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.equalTo(16)
            $0.right.equalTo(-16)
            $0.bottom.equalToSuperview()
        }
    }
    
    private func requestData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1CoinsStoreList)
        httpManager.getWithUrl(apiurl) { (respDict, error) in
           MBProgressHUD.hide(for: self.view, animated: true)
           if let _err = error {
                self.view.makeToast(_err.localizedDescription, position: .center)
                return
           }
           if let status = respDict?["status"] as? Bool {
               if !status {
                   if let message = respDict?["err_msg"] as? String {
                       self.view.makeToast(message, position: .center)
                   }
               } else {
                   if let dataArr = respDict?["data"] as? [[String:Any]] {
                        var arr: [LNCoinPurchaseProductModel] = []
                        for _dict in dataArr {
                            if let productModel = LNCoinPurchaseProductModel.deserialize(from: _dict) {
                                arr.append(productModel)
                            }
                        }
                        self.productList = arr
                        self.tableView.reloadData()
                    
                        /*
                        // 检查上一次支付时，流程如果没有走完，那么在重新进入此界面时，接着把流程走完
                        if let productId = LNCacheUtil().getStringForKey(kUserLastSelectedInAppPurchases) {
                            if productId.count > 0 {
                                self.verifyIAPPaymentResult(productIdentifier: productId, isShowingLoading: true)
                            }
                        }*/
                   }
               }
           }
        }
        
        
//        let m0 = LNCoinPurchaseProductModel()
//        m0.productId = "0"
//        m0.productName = "100 Coins"
//        m0.save = ""
//        m0.bonus = ""
//        m0.price = "$ 0.99"
//
//        let m1 = LNCoinPurchaseProductModel()
//        m1.productId = "1"
//        m1.productName = "500 Coins"
//        m1.save = "+10% Flash Sale"
//        m1.bonus = "+50 Bonus"
//        m1.price = "$ 4.99"
//
//        let m2 = LNCoinPurchaseProductModel()
//        m2.productId = "2"
//        m2.productName = "1000 Coins"
//        m2.save = "+30% Flash Sale"
//        m2.bonus = "+300 Bonus"
//        m2.price = "$ 9.99"
//
//        let m3 = LNCoinPurchaseProductModel()
//        m3.productId = "3"
//        m3.productName = "2000 Coins"
//        m3.save = "+45% Flash Sale"
//        m3.bonus = "+900 Bonus"
//        m3.price = "$ 19.99"
//
//        let m4 = LNCoinPurchaseProductModel()
//        m4.productId = "4"
//        m4.productName = "5000 Coins"
//        m4.save = "+60% Flash Sale"
//        m4.bonus = "+3000 Bonus"
//        m4.price = "$ 49.99"
//
//        let m5 = LNCoinPurchaseProductModel()
//        m5.productId = "5"
//        m5.productName = "10000 Coins"
//        m5.save = "+100% Flash Sale"
//        m5.bonus = "+10000 Bonus"
//        m5.price = "$ 99.99"
//
//        productList = [ m0, m1, m2, m3, m4, m5 ]
//        self.tableView.reloadData()
    }
    
}


extension LNCoinPurchaseViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return productList.count
        } else if section == 1 {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let tableViewReuseCellId = "kLNCoinPurchaseTableViewReuseCellId"
            var cell = tableView.dequeueReusableCell(withIdentifier: tableViewReuseCellId) as? LNCoinPurchaseTableViewCell
            if cell == nil {
                cell = LNCoinPurchaseTableViewCell(style: .default, reuseIdentifier: tableViewReuseCellId)
            }
            cell?.updateData(with: productList[indexPath.row], indexPath: indexPath)
            if let _cell = cell {
                return _cell
            }
        } else if indexPath.section == 1 {
            let bottomCell = UITableViewCell()
            bottomCell.selectionStyle = .none
            let btmDescV = createBottomDescView()
            bottomCell.contentView.addSubview(btmDescV)
            btmDescV.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            return bottomCell
        }
        return UITableViewCell()
    }
    
    private func createBottomDescView() -> UIView {
        let btmDescView = UIView()
        
        let leftMargin: CGFloat = 16
        
        let QALabel = UILabel()
        QALabel.text = languageToggle.localizedString("Q&A")
        QALabel.textColor = PublicColors.blackColor
        QALabel.font = UIFont.AvenirHeavy(size: 20) // .boldSystemFont(ofSize: 20)
        QALabel.textAlignment = .left
        btmDescView.addSubview(QALabel)
        QALabel.snp.makeConstraints {
            $0.top.equalTo(leftMargin)
            $0.left.equalTo(0)
            $0.height.equalTo(25)
            $0.width.equalTo(60)
        }
        
        let descLabel = UILabel()
        descLabel.text = languageToggle.localizedString("1.The bonus will be deducted first, and remains effective for many days.\r\n2.Recharge does not support refund.\r\n3.Top-up coins and Bonus are limited to LuckyNovel app.")
        descLabel.textColor = UIColor.lightGray
        descLabel.font = UIFont.AvenirHeavy(size: 13) //systemFont(ofSize: 13)
        descLabel.textAlignment = .left
        descLabel.numberOfLines = 0
        btmDescView.addSubview(descLabel)
        descLabel.snp.makeConstraints {
            $0.top.equalTo(QALabel.snp.bottom).offset(5)
            $0.height.equalTo(90)
            $0.left.equalTo(0)
            $0.right.equalTo(-leftMargin)
        }
        
        return btmDescView
    }
    
}


extension LNCoinPurchaseViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 90
        } else if indexPath.section == 1 {
            return 140
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UIView()
            headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 60)
            headerView.backgroundColor = PublicColors.whiteColor
            
            let label = UILabel()
            label.text = languageToggle.localizedString("Top Up")
            label.textColor = PublicColors.blackColor
            label.font = UIFont.AvenirHeavy(size: 23) //boldSystemFont(ofSize: 23)
            label.backgroundColor = UIColor.clear
            label.textAlignment = .left
            
            headerView.addSubview(label)
            label.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
            
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            let model = productList[indexPath.row]
            if let _productId = model.productId {
                makePayment(with: _productId)
            }
        } else if indexPath.section == 1 {
            
        }
    }
    
    /*
    // 获取In-App Purchase的服务产品
    private func fetchProducts() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        var skProductIdentifiers: [String] = []
        for p in productList {
            if let _productId = p.productId {
                skProductIdentifiers.append(_productId)
            }
        }
        let identifiers = Set(skProductIdentifiers)
        SwiftyStoreKit.retrieveProductsInfo(identifiers) { result in
            MBProgressHUD.hide(for: self.view, animated: true)
            
        }
    }*/
    
    // 立刻开始发起支付
    private func makePayment(with productIdentifier: String) {
        if productIdentifier.count <= 0 {
            return
        }
        LNCacheUtil().saveStringValue(productIdentifier, forKey: kUserLastSelectedInAppPurchases)
        BuryPointUtil.event("001", label: "发起金币购买", attributes: [ "product_id" : productIdentifier ])
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = languageToggle.localizedString("Paying is in progress...")
        SwiftyStoreKit.purchaseProduct(productIdentifier, atomically: true) { result in
            hud.hide(animated: true)
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                // 更新支付信息到server
                let transactionIdentifier = purchase.transaction.transactionIdentifier
                let transactedDate = purchase.transaction.transactionDate?.toDateTimeString() ?? Date().toDateTimeString()
                self.addCoinsRequest(productId: productIdentifier, transactionIdentifier: transactionIdentifier ?? "", transactedDate: transactedDate)
            } else if case .error(let error) = result {
                LNCacheUtil().removeValue(forKey: kUserLastSelectedInAppPurchases)
                BuryPointUtil.event("004", label: "金币购买未成功", attributes: [ "product_id" : productIdentifier ])
                switch error.code {
                    case .unknown: self._toast(with: "Unknown error. Please contact and email to johnnycheungq@gmail.com!")
                    case .clientInvalid: self._toast(with: "Not allowed to make the payment")
                    case .paymentCancelled: self._toast(with: "You cancelled the reuqest of the payment")
                    case .paymentInvalid: self._toast(with: "The purchase identifier was invalid")
                    case .paymentNotAllowed: self._toast(with: "The device is not allowed to make the payment")
                    case .storeProductNotAvailable: self._toast(with: "The product is not available in the current storefront")
                    case .cloudServicePermissionDenied: self._toast(with: "Access to cloud service information is not allowed")
                    case .cloudServiceNetworkConnectionFailed: self._toast(with: "Could not connect to the network")
                    case .cloudServiceRevoked: self._toast(with: "User has revoked permission to use this cloud service")
                    default: self._toast(with: (error as NSError).localizedDescription)
                }
            } else {
                self._toast(with: "Unknown purchase error. Please contact and email to johnnycheungq@gmail.com!")
            }
        }
    }
    
    // 添加金币的请求
    private func addCoinsRequest(productId: String, transactionIdentifier: String, transactedDate: String) {
        let receiptString = getPurchasedReceiptData()
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.label.text = languageToggle.localizedString("Verifying the result of your purchase...")
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1CoinsPurchase)
        let param: [String: Any] = ["product_id": productId,
                                    "transaction_identifier": transactionIdentifier,
                                    "transacted_date": transactedDate,
                                    "receipt_data": receiptString ?? ""]
        httpManager.post(apiurl, formData: param) { (respDict, error) in
            hud.hide(animated: true)
            if let _error = error {
                BuryPointUtil.event("003", label: "金币购买失败重试", attributes: [ "product_id" : productId, "retry_time": self.isRetried3TimesToUpdateCoins ])
                if self.isRetried3TimesToUpdateCoins >= 3 {
                    // 如果重试了三次都没有成功，就提示用户吧
                    self._toast(with: _error.localizedDescription)
                    return
                }
                self.isRetried3TimesToUpdateCoins += 1
                self.addCoinsRequest(productId: productId, transactionIdentifier: transactionIdentifier, transactedDate: transactedDate) // 如果没有请求成功，重试
                return
            }
            if let status = respDict?["status"] as? Bool {
                if !status {
                    if let _err_msg = respDict?["err_msg"] as? String {
                        self.view.makeToast(_err_msg, position: .center)
                    }
                    return
                }
                if let total_coins = respDict?["total_coins"] as? Int {
                    let userModel = LNUserModelUtil.shared().model
                    userModel?.coins = total_coins
                    if let _userModel = userModel {
                        LNUserModelUtil.shared().saveModel(toDisk: _userModel)
                        
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNameUserPurchasedCoinsSuccess), object: nil, userInfo: ["model": _userModel])
                    }
                    BuryPointUtil.event("002", label: "金币购买成功", attributes: [ "product_id" : productId ])
                    self.view.makeToast(self.languageToggle.localizedString("Purchased Successfully!"), position: .center)
                    // 关闭界面
                    self.goBack()
                }
            }
        }
    }
    
    // 从本地获取已支付的Receipt data
    private func getPurchasedReceiptData() -> String? {
        // doc: https://developer.apple.com/documentation/storekit/in-app_purchase/validating_receipts_with_the_app_store
        // Get the receipt if it's available
        // 1.正常情况下，用户购买完，就会在本地生成一份记录
        // 2.App删掉后，本地订阅购买记录将不会被保存，那么这里就是空的了，不可能执行，但是可以主动去获取一份SwiftyStoreKit.fetchReceipt(forceRefresh: true)
        // 3.如果用户退出登录，换个账号登录的话，这里也会查询到上一个账号的购买记录，所以server要判别是否是同一个用户，再决定去更新
        guard let appStoreReceiptURL = Bundle.main.appStoreReceiptURL else {
            // 本地没有记录
            return nil
        }
        if !FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            return nil
        }
        guard let receiptData = try? Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped) else {
            self._toast(with: "AppStoreReceiptData conversion error. Please email to johnnycheungq@gmail.com!")
            // 如果一直转换失败，则视为本地缓存有问题，那就去apple server重新拉取一遍
            SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
                switch result {
                case .success(let receiptData):
                    let _ = receiptData.base64EncodedString(options: [])
                    let _ = self.getPurchasedReceiptData()
                case .error(let error):
                    print("Fetch receipt failed: \(error)")
                }
            }
            return nil
        }
        let receiptString = receiptData.base64EncodedString(options: [])
        return receiptString
    }
    
    private func _toast(with msg: String) {
        alert(with: msg)
        //self.view.makeToast(msg, position: .center)
    }
    
}


fileprivate class LNCoinPurchaseTableViewCell: UITableViewCell {
    
    private var productModel: LNCoinPurchaseProductModel?
    
    private let productName0Label = UILabel()
    private let productNameLabel = UILabel()
    private let coinPercentileLabel = UILabel()
    private let bonusLabel = UILabel()
    private let priceLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        let leftMargin: CGFloat = 16
        
        let grayBGView = UIView()
        grayBGView.backgroundColor = PublicColors.mainGrayColor
        grayBGView.layer.cornerRadius = 9
        grayBGView.layer.masksToBounds = true
        contentView.addSubview(grayBGView)
        grayBGView.snp.makeConstraints {
            $0.left.top.right.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        productName0Label.isHidden = true
        productName0Label.text = "100 Coins"
        productName0Label.textColor = PublicColors.mainBlackColor
        productName0Label.font = UIFont.AvenirMedium(size: 17) //.systemFont(ofSize: 17)
        productName0Label.textAlignment = .left
        contentView.addSubview(productName0Label)
        productName0Label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(leftMargin)
            $0.right.equalTo(-leftMargin)
            $0.height.equalTo(24)
        }
        
        productNameLabel.text = "500 Coins"
        productNameLabel.textColor = PublicColors.mainBlackColor
        productNameLabel.font = UIFont.AvenirMedium(size: 17)
        productNameLabel.textAlignment = .left
        contentView.addSubview(productNameLabel)
        productNameLabel.snp.makeConstraints {
            $0.top.equalTo(10)
            $0.left.equalTo(leftMargin)
            $0.right.equalTo(-leftMargin)
            $0.height.equalTo(24)
        }
        
        coinPercentileLabel.backgroundColor = PublicColors.mainLightPinkColor
        coinPercentileLabel.text = "+10% Flash Sale"
        coinPercentileLabel.textColor = PublicColors.whiteColor
        coinPercentileLabel.font = UIFont.AvenirMedium(size: 12)
        coinPercentileLabel.textAlignment = .center
        coinPercentileLabel.layer.cornerRadius = 10
        coinPercentileLabel.layer.masksToBounds = true
        contentView.addSubview(coinPercentileLabel)
        coinPercentileLabel.snp.makeConstraints {
            $0.top.equalTo(productNameLabel.snp.bottom).offset(8)
            $0.left.equalTo(leftMargin)
            $0.width.equalTo(110)
            $0.height.equalTo(20)
        }
        
        bonusLabel.text = "+50 Bonus"
        bonusLabel.textColor = PublicColors.mainPinkColor
        bonusLabel.font = UIFont.AvenirMedium(size: 14)
        bonusLabel.textAlignment = .left
        contentView.addSubview(bonusLabel)
        bonusLabel.snp.makeConstraints {
            $0.top.equalTo(self.productNameLabel.snp.bottom).offset(8)
            $0.left.equalTo(self.coinPercentileLabel.snp.right).offset(8)
            $0.width.equalTo(100)
            $0.height.equalTo(20)
        }
        
        priceLabel.text = "$ 4.99"
        priceLabel.textColor = PublicColors.mainBlackColor
        priceLabel.font = UIFont.AvenirMedium(size: 18)
        priceLabel.textAlignment = .right
        contentView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(-leftMargin)
            $0.width.equalTo(80)
            $0.height.equalTo(25)
        }
         
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(with model: LNCoinPurchaseProductModel, indexPath: IndexPath)  {
        productModel = model
        
        bonusLabel.text = model.bonus
        priceLabel.text = model.price
        
        if model.save == nil || (model.save?.count ?? 0) <= 0 {
            productName0Label.isHidden = false
            productName0Label.text = model.productName
            
            productNameLabel.isHidden = true
            coinPercentileLabel.isHidden = true
        } else {
            productName0Label.isHidden = true
            
            productNameLabel.text = model.productName
            productNameLabel.isHidden = false
            coinPercentileLabel.text = model.save
            coinPercentileLabel.isHidden = false
        }
    }

}
