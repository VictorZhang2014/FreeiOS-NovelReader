//
//  LNStoreViewController.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/1/31.
//  商店

import UIKit
import SnapKit
import StoreKit
import Lottie
import MBProgressHUD


class LNStoreViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    private lazy var tableView = UITableView()
    
    private var bannerModelList: [LNBookStoreBannerModel] = []
    private var topModelList: [LNBookStoreItemIntroModel] = []
    private var bestModelList: [LNBookStoreItemIntroModel] = []
    private var categoryModelList: [LNBookStoreCategoryItemIntroModel] = []
    
    private var noNetworkView: UIView?
    private var lottieAnimationView: AnimationView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.mainGrayColor

        setupNavigationBar()
        setupViews()
        loadData()
        
        self.perform(#selector(showReviewAppAlert), with: nil, afterDelay: 200.0)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("小说商城")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("小说商城")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
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
        
        /*let textImageView = UIImageView()
        textImageView.image = UIImage(named: "applogo-text")
        textImageView.contentMode = .scaleAspectFit
        customNavigationBarView.addSubview(textImageView)
        textImageView.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight + 5)
            $0.left.equalTo(15)
            $0.width.equalTo(120)
            $0.height.equalTo(40)
        }*/
        
        let topLeftLabel = UILabel()
        topLeftLabel.text = "Store"
        topLeftLabel.font = UIFont.ArialRoundedMTBold(size: 28)
        topLeftLabel.textColor = UIColor(rgb: 0x292929)
        topLeftLabel.textAlignment = .left
        customNavigationBarView.addSubview(topLeftLabel)
        topLeftLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-6)
            $0.height.equalTo(32)
            $0.left.equalTo(20)
            $0.width.equalTo(200)
        }
        
        /*
        let btmLine = UIView()
        btmLine.backgroundColor = PublicColors.mainGrayColor
        self.customNavigationBarView.addSubview(btmLine)
        btmLine.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.height.equalTo(3)
            $0.bottom.equalToSuperview()
        }*/
    }
    
    @objc func showReviewAppAlert() {
        // 弹框让用户评价
        let key = "\(kAppReviewAndRateKey)_\(LNDeviceUtil.shared().appVersion)_\(LNDeviceUtil.shared().appShortVersion)"
        if !LNCacheUtil().getBooleanForKey(key) {
            LNCacheUtil().saveBoolValue(true, forKey: key)
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func setupViews() {
        // 无网络时显示
        noNetworkView = UIView()
        noNetworkView?.backgroundColor = PublicColors.whiteColor
        if let _noNetworkView = noNetworkView {
        view.addSubview(_noNetworkView)
            _noNetworkView.snp.makeConstraints {
                $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(3)
                $0.left.bottom.right.equalToSuperview()
            }
        }
        
        let lottieAnimationViewHeight: CGFloat = 320
        lottieAnimationView = AnimationView(name: "39620-404-network")
        lottieAnimationView?.loopMode = .loop
        lottieAnimationView?.frame = CGRect(x: 0, y: 0, width: screenWidth, height: lottieAnimationViewHeight)
        if let _lottieAnimationView = lottieAnimationView {
            noNetworkView?.addSubview(_lottieAnimationView)
            _lottieAnimationView.play()
        }
        
        let refreshBtn = UIButton()
        refreshBtn.applyGradientFromLeftToRight(colours: [PublicColors.mainLightPinkColor, PublicColors.mainPinkColor])
        refreshBtn.setTitle("Refresh", for: .normal)
        refreshBtn.setTitleColor(PublicColors.whiteColor, for: .normal)
        refreshBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        refreshBtn.layer.cornerRadius = 20
        refreshBtn.layer.masksToBounds = true
        refreshBtn.addTarget(self, action: #selector(didRefreshData), for: .touchUpInside)
        noNetworkView?.addSubview(refreshBtn)
        refreshBtn.snp.makeConstraints {
            $0.top.equalTo(lottieAnimationViewHeight)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(200)
            $0.height.equalTo(40)
        }
        
        let checkNetworkBtn = UIButton()
        checkNetworkBtn.setTitle("Please check network", for: .normal)
        checkNetworkBtn.setTitleColor(PublicColors.mainRedColor, for: .normal)
        checkNetworkBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        checkNetworkBtn.addTarget(self, action: #selector(didCheckNetwork), for: .touchUpInside)
        noNetworkView?.addSubview(checkNetworkBtn)
        checkNetworkBtn.snp.makeConstraints {
            $0.top.equalTo(refreshBtn.snp.bottom).offset(15)
            $0.left.equalTo(10)
            $0.right.equalTo(-10)
            $0.height.equalTo(40)
        }
        
        // 有网络时显示
        tableView.backgroundColor = PublicColors.mainGrayColor
        //tableView.contentInset = UIEdgeInsets(top: 0, left: self.margin, bottom: 0, right: -self.margin)
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(3)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    @objc func didRefreshData() {
        loadData()
    }
    
    @objc func didCheckNetwork() {
        if let _url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(_url, options: [:], completionHandler: nil)
        }
    }
    
    private func loadData() {
        /*
        // 1.先从缓存取数据
        var isNotCached: Bool = true
        if let cachedDataDict = LNCacheUtil().getDictValue(forKey: kBookStoreFirstPageDataKey) as? [String:Any] {
            self.parseStoreJsonData(with: cachedDataDict)
            self.tableView.reloadData()
            isNotCached = false
        }
        if isNotCached {
            MBProgressHUD.showAdded(to: self.view, animated: true)
        }
        // 2.再去server取数据
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1BookStoreList)
        httpManager.getWithUrl(apiurl) { (respDict, error) in
            if isNotCached {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
            if let _err = error {
                self.view.makeToast(_err.localizedDescription, position: .center)
                self.tableView.isHidden = true
                return
            }
            if let status = respDict?["status"] as? Bool {
                self.lottieAnimationView?.stop()
                self.lottieAnimationView?.removeFromSuperview()
                self.noNetworkView?.removeFromSuperview()
                self.noNetworkView = nil
                self.tableView.isHidden = false
                
                if !status {
                    if let message = respDict?["message"] as? String {
                        self.view.makeToast(message)
                    }
                } else {
                    if let dataDict = respDict?["data"] as? [String:Any] {
                        self.parseStoreJsonData(with: dataDict)
                        self.tableView.reloadData()
                        
                        LNCacheUtil().saveDictValue(dataDict, forKey: kBookStoreFirstPageDataKey)
                    }
                }
            }
        }*/
        
        if let path = Bundle.main.path(forResource: "home_store_data", ofType: "json") {
            do {
              let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
              let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
              if let dataDict = jsonResult {
                self.parseStoreJsonData(with: dataDict)
                self.tableView.reloadData()
              }
          } catch {
               // handle error
          }
        }
    }
    
    private func parseStoreJsonData(with dataDict: [String:Any]) {
        // 解析banner
        if let _bannerDict = dataDict["banner"] as? [[String:Any]] {
            var bannerList: [LNBookStoreBannerModel] = [] 
            for d in _bannerDict {
                if let model = LNBookStoreBannerModel.deserialize(from: d) {
                    bannerList.append(model)
                }
            }
            self.bannerModelList = bannerList
        }
        // 解析top novel
        if let _topDict = dataDict["top"] as? [[String:Any]] {
            var topList: [LNBookStoreItemIntroModel] = []
            for d in _topDict {
                if let model = LNBookStoreItemIntroModel.deserialize(from: d) {
                    topList.append(model)
                }
            }
            self.topModelList = topList
        }
        // 解析best novel
        if let _bestDict = dataDict["best"] as? [[String:Any]] {
            var bestList: [LNBookStoreItemIntroModel] = []
            for d in _bestDict {
                if let model = LNBookStoreItemIntroModel.deserialize(from: d) {
                    bestList.append(model)
                }
            }
            self.bestModelList = bestList
        }
        // 解析category
        if let _categoryDict = dataDict["category"] as? [[String:Any]] {
            var categoryList: [LNBookStoreCategoryItemIntroModel] = []
            for d in _categoryDict {
                if let model = LNBookStoreCategoryItemIntroModel.deserialize(from: d) {
                    categoryList.append(model)
                }
            }
            self.categoryModelList = categoryList
        }
    }

}


extension LNStoreViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 + 1 + 1 + categoryModelList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let slideHeaderReuseId = "kLNBookStoreSlideShowHeaderReuseID"
            var cell = tableView.dequeueReusableCell(withIdentifier: slideHeaderReuseId)
            if cell == nil {
                cell = UITableViewCell(style: .default, reuseIdentifier: slideHeaderReuseId)

                let headerView = LNBookStoreSlideShowHeader()
                headerView.headerDelegate = self
                cell?.contentView.addSubview(headerView)
                headerView.snp.makeConstraints {
                    $0.edges.equalToSuperview()
                }
            }
            if let _cellSubviews = cell?.contentView.subviews {
                for v in _cellSubviews {
                    if let _v = v as? LNBookStoreSlideShowHeader {
                        _v.updateData(with: bannerModelList)
                        break
                    }
                }
            }
            if let _cell = cell {
                return _cell
            }
        } else if indexPath.section == 1 {
            let cell = LNBookStoreTableViewCell()
            cell.tag = 100
            cell.cellDelegate = self
            cell.updateData(with: topModelList, categoryName: topModelList.first?.categoryName ?? "", indexPath: indexPath)
            return cell
        } else if indexPath.section == 2 {
            let cell = LNBookStoreBestTableViewCell()
            cell.cellDelegate = self
            cell.updateData(with: self.bestModelList, indexPath: indexPath)
            return cell
        } else {
            let model = categoryModelList[indexPath.section - 3]
            let categoryModelCell = LNBookStoreTableViewCell()
            categoryModelCell.tag = 1000
            categoryModelCell.cellDelegate = self
            categoryModelCell.indexPath = indexPath
            categoryModelCell.updateData(with: model.books, categoryName: model.categoryName ?? "", indexPath: indexPath)
            return categoryModelCell
        }
    
        return UITableViewCell()
    }
    
}


extension LNStoreViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return LNBookStoreSlideShowHeader.getViewHeight
        } else if indexPath.section == 1 {
            return LNBookStoreTableViewCell.cellHeight
        } else if indexPath.section == 2 {
            return LNBookStoreBestTableViewCell.cellHeight
        } else {
            return LNBookStoreTableViewCell.cellHeight
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}



extension LNStoreViewController : LNBookStoreSlideShowHeaderDelegate {
    
    func didOpenBook(with header: LNBookStoreSlideShowHeader, index: Int) {
        let model = header.bannerModels[index]
        guard let _bookId = model.bookId else {
            return
        }
        let vc = LNBookIntroViewController()
        vc.bookId = _bookId
        vc.bookCover = model.bannerImageUrl
        navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension LNStoreViewController: LNBookStoreTableViewCellDelegate {
    
    func bookTableViewCellEvent(in tableViewCell: LNBookStoreTableViewCell, section: NSInteger, index: NSInteger) {
        let vc = LNBookIntroViewController()
        
        if tableViewCell.tag == 100  { // Top Romance
            let model = topModelList[index]
            vc.bookId = model.bookId
            vc.bookName = model.bookName
            vc.bookCover = model.bookCover
            vc.tmpBookCoverImage = model.tmpBookCoverImage
        } else if tableViewCell.tag == 1000  { // category
            let model = categoryModelList[section - 3].books[index]
            vc.bookId = model.bookId
            vc.bookName = model.bookName
            vc.bookCover = model.bookCover
            vc.tmpBookCoverImage = model.tmpBookCoverImage
        }
        
        if section == 0 {
            
        } else if section == 1 {
        } else if section == 2 {
            
        } else {
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }

}


extension LNStoreViewController: LNBookStoreBestTableViewCellDelegate {
    
    func bookStoreBestTableViewCellEvent(with cell: LNBookStoreBestTableViewCell, didOpenTheBook indexPath: IndexPath?) {
        guard let _indexPath = indexPath else { return }
        let model = bestModelList[_indexPath.row]
        let vc = LNBookIntroViewController()
        vc.bookId = model.bookId
        vc.bookCover = model.bookCover
        vc.tmpBookCoverImage = model.tmpBookCoverImage
        navigationController?.pushViewController(vc, animated: true)
    }

}
