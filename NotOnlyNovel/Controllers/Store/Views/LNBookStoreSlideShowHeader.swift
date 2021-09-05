//
//  LNBookStoreSlideShowHeader.swift
//  NotOnlyNovel
//
//  Created by admin on 2021/2/2.
//

import UIKit
import SnapKit


protocol LNBookStoreSlideShowHeaderDelegate {

    func didOpenBook(with header: LNBookStoreSlideShowHeader, index: Int)

}


class LNBookStoreSlideShowHeader: UIView {
    
    var headerDelegate: LNBookStoreSlideShowHeaderDelegate?
    
    public lazy var bannerModels: [LNBookStoreBannerModel] = []
    
    private lazy var scrollView = UIScrollView()
    private lazy var pageControl = UIPageControl()
    
    private lazy var coverImageViews: [UIView] = []
    private lazy var bookName = UILabel()
    private lazy var tagsView = UIView()
    
    private var carouselAdsTimer: Timer? // 轮播图计时器
    private var currentImageIndex: Int = 0 // 轮播图当前的索引
    
    private var bookNameWidthConstraint: Constraint?
    
    public class var getViewHeight: CGFloat {
        get {
            if (UIDevice.current.userInterfaceIdiom == .pad) {
                return (7 + 200 + 7) * 2
            }
            return 7 + 200 + 7
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        scrollView.isPagingEnabled = true
        scrollView.backgroundColor = PublicColors.whiteColor
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        self.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 先删除
        coverImageViews.removeAll()
        for v in  scrollView.subviews {
            v.removeFromSuperview()
        }
        carouselAdsTimer?.invalidate()
        carouselAdsTimer = nil
        currentImageIndex = 0
        
        let totalCount: Int = bannerModels.count
        
        let screenSize = UIScreen.main.bounds.size
        
        scrollView.contentSize = CGSize(width: screenSize.width * CGFloat(totalCount), height: LNBookStoreSlideShowHeader.getViewHeight)
        
        let topMargin: CGFloat = 10
        //let leftMargin: CGFloat = 20
        //let cardWidth: CGFloat = screenSize.width - leftMargin * 2
        let cardHeight: CGFloat = LNBookStoreSlideShowHeader.getViewHeight - topMargin * 2
        
        // 再添加上图
        var x: CGFloat = 0
        for i in 0..<totalCount {
            x = screenSize.width * CGFloat(i)
            let card = self.createCardView()
            card.frame = CGRect(x: x, y: 5, width: screenSize.width, height: cardHeight)
            card.tag = i+100
            scrollView.addSubview(card)
            coverImageViews.append(card)
            
            updateImageView(with: i, imageParentView: card)
        }
        
        // 添加图上点
        pageControl.numberOfPages = totalCount
        pageControl.pageIndicatorTintColor = PublicColors.whiteColor
        pageControl.currentPageIndicatorTintColor = PublicColors.mainRedColor
        addSubview(pageControl)
        pageControl.snp.makeConstraints {
            $0.height.equalTo(30)
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(-(topMargin + 5))
        }
        
        // 三秒钟轮播一次，如果轮播图的增加或者减少，不需要修改任何值，轮播图的功能依然可用
        // 只有一张图时，不启用timer，因为没有效果
        if totalCount > 1 {
            carouselAdsTimer = Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { (timer) in
                self.scrollView.scrollRectToVisible(CGRect(x: CGFloat(self.currentImageIndex) * screenSize.width, y: 0, width: screenSize.width, height: cardHeight), animated: true)
                self.pageControl.currentPage = self.currentImageIndex
                self.currentImageIndex += 1
                if self.currentImageIndex >= totalCount {
                    self.currentImageIndex = 0
                }
                //print("商城页当前轮播图 index=\(self.currentImageIndex)")
            }
            
//            #warning("测试数据，记得删除")
//            carouselAdsTimer?.invalidate()
        }
    }

    
    private func createCardView() -> UIView {
        let _margin: CGFloat = 10
        
        let card = UIView()
        card.backgroundColor = UIColor.clear
        //card.layer.cornerRadius = 16
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didOpenSpecificBook(_:))))
        
        // 封面
        let coverImageView = UIImageView()
        coverImageView.contentMode = .scaleAspectFill
        coverImageView.backgroundColor = PublicColors.mainGrayColor
        coverImageView.layer.cornerRadius = 10
        coverImageView.layer.masksToBounds = true
        card.addSubview(coverImageView)
        coverImageView.snp.makeConstraints {
            $0.top.left.equalTo(_margin)
            $0.right.equalTo(-_margin)
            $0.bottom.equalTo(-5)
        }
        
        return card
    }
    
    private func updateImageView(with index: Int, imageParentView: UIView) {
        if let _bannerUrl = bannerModels[index].bannerImageUrl {
            if coverImageViews.count > 0 {
                if let imageURL = URL(string: _bannerUrl) {
                    if let imageView = imageParentView.subviews.first as? UIImageView {
                        imageView.sd_setImage(with: imageURL, completed: nil)
                    }
                }
            }
        }
    }
    
    func updateData(with models: [LNBookStoreBannerModel]) {
        bannerModels = models
        setupViews()
    }

    @objc func didOpenSpecificBook(_ gesture: UITapGestureRecognizer) {
        guard let _tag = gesture.view?.tag else { return }
        let index: Int = _tag - 100
        headerDelegate?.didOpenBook(with: self, index: index)
    }
    
    deinit {
        print("FNBookStoreSlideShowHeader has deallocated!")
    }
}
 
