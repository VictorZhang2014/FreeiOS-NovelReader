//
//  YBSignUpAgreementsViewController.swift
//  Yobo
//
//  Created by VictorZhang on 2020/9/16.
//  Copyright © 2020 TelaBytes. All rights reserved.
//
//  用户协议

import UIKit
import WebKit
import MBProgressHUD



class LNSignUpAgreementsViewController: LNBaseViewController, WKUIDelegate, WKNavigationDelegate {
    
    private let customNavigationBarView = UIView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupNavigationBar()
        self.setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BuryPointUtil.beginLogPageView("用户服务条款页面")
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BuryPointUtil.endLogPageView("用户服务条款页面")
    }
    
    func setupNavigationBar() { 
        self.customNavigationBarView.backgroundColor = UIColor.white
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(navigationBarAndStatusHeight)
        }

        let backArrowImg = UIButton(frame: CGRect())
        backArrowImg.setImage(UIImage(named: "BlackBackArrow"), for: .normal)
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
        //self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        let config = WKWebViewConfiguration()
        config.applicationNameForUserAgent = "LuckyNoveliOS"
         
        let url = URL(string: "http://saysth.top/lucknovel/terms_of_use")
        guard let _url = url else { return }
        let request = URLRequest(url: _url)
        let webView = WKWebView(frame: CGRect(), configuration: config)
        //webView.allowsBackForwardNavigationGestures = true // 允许左滑动返回上一级页面
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.load(request)
        self.view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.bottom.right.equalToSuperview()
        }
        
        // 防止StatusBar把WebView顶下来了
        if #available(iOS 11.0, *) {
            webView.scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    /// WKNavigationDelegate
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("webView 加载失败 error=\(error.localizedDescription)")
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView didFinish 加载完成")
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    
}
