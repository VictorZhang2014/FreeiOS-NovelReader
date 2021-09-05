//
//  LNBookrackViewController.swift
//  NotOnlyNovel
//
//  Created by JohnnyCheung on 2021/3/2.
//
//  书架

import UIKit
import MJRefresh


class LNBookrackViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    private var noNetworkView: UIView?
    private lazy var tableView = UITableView()
    
    private lazy var itemModels: [LNBookrackItemModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.mainGrayColor

        setupNavigationBar()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("Tab书架")
        
        requestData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("Tab书架")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    private func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = PublicColors.mainGrayColor
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight + 5)
        }
        
//        let titleLabel = UILabel()
//        titleLabel.text = self.languageToggle.localizedString("Library")
//        titleLabel.font = UIFont.AvenirBlack(size: 26) // .boldSystemFont(ofSize: 26)
//        titleLabel.textColor = PublicColors.blackColor
//        customNavigationBarView.addSubview(titleLabel)
//        titleLabel.snp.makeConstraints {
//            $0.top.equalTo(statusBarHeight + 20)
//            $0.left.equalTo(15)
//            $0.width.equalTo(200)
//            $0.height.equalTo(40)
//        }
        
        let topLeftLabel = UILabel()
        topLeftLabel.text = "Library"
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
    
    private func setupViews() {
        tableView.mj_header = MJRefreshNormalHeader(refreshingTarget: self, refreshingAction: #selector(didRefreshDataByHeader))
        tableView.backgroundColor = PublicColors.whiteColor
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.roundCorners([.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 20)
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(10)
            $0.left.equalTo(15)
            $0.right.equalTo(-15)
            $0.bottom.equalTo(-15)
            //$0.left.bottom.right.equalToSuperview()
        }
        tableView.register(LNBookrackTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(LNBookrackTableViewCell.self))
        
        // 无网络时显示
        noNetworkView = UIView()
        noNetworkView?.backgroundColor = PublicColors.whiteColor
        if let _noNetworkView = noNetworkView {
        view.addSubview(_noNetworkView)
            _noNetworkView.snp.makeConstraints {
                $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(10)
                $0.left.equalTo(15)
                $0.right.equalTo(-15)
                $0.bottom.equalToSuperview().offset(-15)
            }
        }
        
        let addBtn = UIButton()
        addBtn.backgroundColor = PublicColors.mainGrayColor
        addBtn.setImage(UIImage(named: "gray-add-icon"), for: .normal)
        addBtn.addTarget(self, action: #selector(goToStore), for: .touchUpInside)
        noNetworkView?.addSubview(addBtn)
        addBtn.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.centerX.equalToSuperview().offset(0)
            $0.width.height.equalTo(120)
        }
    }
    
    @objc func didRefreshDataByHeader() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
            self.tableView.mj_header?.endRefreshing()
        }
    }
    
    private func requestData() {
        itemModels = []
        let dicts = LNFMDBManager.shared().getAllBooksOfHaveRead()
        for d in dicts {
            if let _d = d as? [String:Any], let m = LNBookrackItemModel.deserialize(from: _d) {
                itemModels.append(m)
            }
        }
        tableView.reloadData()
            
        if itemModels.count > 0 {
            noNetworkView?.removeFromSuperview()
            noNetworkView = nil
        }
    }
    
    @objc func goToStore() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: NotificationNameChangeTabBar), object: nil, userInfo: ["index":1])
    }
    
}


extension LNBookrackViewController : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = itemModels[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(LNBookrackTableViewCell.self)) as? LNBookrackTableViewCell
        cell?.updateData(model: model)
        if let _cell = cell {
            return _cell
        }
        
        return UITableViewCell()
    }
    
}


extension LNBookrackViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let v = UIView()
        v.backgroundColor = PublicColors.whiteColor
        v.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 10)
        return v
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return languageToggle.localizedString("DELETE")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let model = itemModels[indexPath.row]
        alert(withMessage: languageToggle.localizedString("Are you sure you want to delete this book from your favorite list?")) {
            LNFMDBManager.shared().deleteBookFromBookrackList(withBookId: model.bookId)
            self.requestData()
        } cancelHandler: {
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = itemModels[indexPath.row]
        
        let detailVC = LNReadingDetailViewController()
        detailVC.bookId = model.bookId
        detailVC.specifiedChapterId = model.lastChapterId
        self.navigationController?.pushViewController(detailVC, animated: true)
        
        //let vc = LNReaderDetailViewController()
        //vc.bookId = model.bookId
        //vc.lastChapterId = model.lastChapterId
        //self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
