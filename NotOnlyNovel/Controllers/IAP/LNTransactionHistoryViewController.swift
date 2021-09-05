//
//  LNTransactionHistoryViewController.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/2.
//
//  交易历史记录

import UIKit
import MBProgressHUD


class LNTransactionHistoryViewController: LNBaseViewController {
    
    private lazy var customNavigationBarView = UIView()
    private lazy var tableView = UITableView()
    
    private lazy var transactionModels: [LNCoinTransactionModel] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = PublicColors.mainGrayColor

        setupNavigationBar()
        createSubviews()
        requestData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        BuryPointUtil.beginLogPageView("交易历史页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("交易历史页")
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
        
        let titleLabel = UILabel()
        titleLabel.text = languageToggle.localizedString("Transactions")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = PublicColors.blackColor
        titleLabel.textAlignment = .center
        customNavigationBarView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(statusBarHeight)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(150)
            $0.height.equalTo(40)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        lineView.alpha = 0.3
        customNavigationBarView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    @objc func goBack() {
        navigationController?.popViewController(animated: true)
    }
    
    private func createSubviews() {
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    private func requestData() {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        let httpManager = LNHttpManager()
        let apiurl = httpManager.getAPIUrlPath(.v1TransactionHistory)
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
                        self.transactionModels = []
                        for d in dataArr {
                            if let model = LNCoinTransactionModel.deserialize(from: d) {
                                self.transactionModels.append(model)
                            }
                        }
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
}



extension LNTransactionHistoryViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.transactionModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewReuseCellId = "kLNTransactionHistoryTableViewCellReuseCellId"
        var cell = tableView.dequeueReusableCell(withIdentifier: tableViewReuseCellId) as? LNTransactionHistoryViewCell
        if cell == nil {
            cell = LNTransactionHistoryViewCell(style: .default, reuseIdentifier: tableViewReuseCellId)
        }
        cell?.updateData(model: transactionModels[indexPath.row], indexPath: indexPath)
        if let _cell = cell {
            return _cell
        }
        
        return UITableViewCell()
    }
    
}


extension LNTransactionHistoryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let transactionType = transactionModels[indexPath.row].transactionType
        if transactionType == .topUp || transactionType == .earnCoinsByPlayingVideo {
            return 80
        }
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
}


fileprivate class LNTransactionHistoryViewCell: UITableViewCell {
    
    private lazy var iconImageView = UIImageView()
    private lazy var titleLabel = UILabel()
    private lazy var subtitleLabel = UILabel()
    private lazy var timeLabel = UILabel()
    private lazy var coinsLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = PublicColors.whiteColor
        selectionStyle = .none
        
        contentView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(30)
            $0.top.equalTo(10)
            $0.left.equalTo(15)
        }
        
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        titleLabel.textColor = PublicColors.titleColor
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.left.equalTo(iconImageView.snp.right).offset(10)
            $0.right.equalTo(-30)
            $0.height.equalTo(25)
        }
        
        subtitleLabel.font = UIFont.systemFont(ofSize: 13)
        subtitleLabel.textColor = UIColor.lightGray
        subtitleLabel.textAlignment = .left
        contentView.addSubview(subtitleLabel)
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.left.equalTo(iconImageView.snp.right).offset(10)
            $0.right.equalTo(-30)
            $0.height.equalTo(20)
        }
        
        timeLabel.font = UIFont.systemFont(ofSize: 13)
        timeLabel.textColor = UIColor.lightGray
        timeLabel.textAlignment = .left
        contentView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(5)
            $0.left.equalTo(iconImageView.snp.right).offset(10)
            $0.right.equalTo(-30)
            $0.height.equalTo(20)
        }
        
        coinsLabel.font = UIFont.boldSystemFont(ofSize: 18)
        coinsLabel.textColor = PublicColors.blackColor
        coinsLabel.textAlignment = .right
        contentView.addSubview(coinsLabel)
        coinsLabel.snp.makeConstraints {
            $0.top.equalTo(15)
            $0.right.equalTo(-15)
            $0.width.equalTo(100)
            $0.height.equalTo(25)
        }
        
        let lineView = UIView()
        lineView.backgroundColor = UIColor.lightGray
        lineView.alpha = 0.3
        contentView.addSubview(lineView)
        lineView.snp.makeConstraints {
            $0.left.equalTo(15 + 30 + 10)
            $0.bottom.right.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateData(model: LNCoinTransactionModel, indexPath: IndexPath) {
        var timeStr: String? = ""
        if let _createtime = model.createTime?.replacingOccurrences(of: "T", with: " ") {
            timeStr = _createtime
        }
        if model.transactionType == .topUp {
            iconImageView.image = UIImage(named: "transaction-income-icon")
            titleLabel.text = "Top up"
            subtitleLabel.text = timeStr
            timeLabel.isHidden = true
            coinsLabel.text = "+\(model.coins)"
            coinsLabel.textColor = PublicColors.blackColor
        } else if model.transactionType == .purchaseChapters {
            iconImageView.image = UIImage(named: "transaction-deduct-icon")
            titleLabel.text = model.bookName
            subtitleLabel.text = model.chapterName
            timeLabel.text = timeStr
            timeLabel.isHidden = false
            coinsLabel.text = "-\(model.coins)"
            coinsLabel.textColor = PublicColors.mainRedColor
        } else if model.transactionType == .earnCoinsByPlayingVideo {
            iconImageView.image = UIImage(named: "transaction-income-google-video-ads-icon")
            titleLabel.text = "Google Ads - video"
            subtitleLabel.text = timeStr
            timeLabel.isHidden = true
            coinsLabel.text = "+\(model.coins)"
            coinsLabel.textColor = PublicColors.blackColor
        }
    }
    
}
