//
//  LNWebViewController.swift
//  NotOnlyNovel
//
//  Created by Johnny Cheung on 2021/2/1.
//

import UIKit
import WebKit
import MBProgressHUD


class LNSimpleWebViewController: LNBaseViewController {

    private let customNavigationBarView = UIView()
    private lazy var webview = WKWebView()
    
    var requestUrl: String
    
    init(with url: String) {
        self.requestUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupViews()
    }
    
    private func setupNavigationBar() {
        self.customNavigationBarView.backgroundColor = UIColor.clear
        self.view.addSubview(self.customNavigationBarView)
        self.customNavigationBarView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(self.navigationBarAndStatusHeight)
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
        //self.dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
    
    private func setupViews() {
        guard let url = URL(string: self.requestUrl) else { return }
        webview.navigationDelegate = self
        let request = URLRequest(url: url)
        webview.load(request)
        view.addSubview(webview)
        webview.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBarView.snp.bottom).offset(0)
            $0.left.bottom.right.equalToSuperview()
        }
    }

}


extension LNSimpleWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MBProgressHUD.showAdded(to: webview, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        MBProgressHUD.hide(for: webview, animated: true)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        MBProgressHUD.hide(for: webview, animated: true)
    }
    
}
