//
//  CashwalkBannerVC.swift
//  Cashwalk
//
//  Created by cashwalk on 05/12/2018.
//  Copyright © 2018 Cashwalk, Inc. All rights reserved.
//

import UIKit

protocol CashwalkBannerVCDelegate: NSObjectProtocol { // BannerModel
    func cashwalkBannerVCDidClicked(_ viewController: CashwalkBannerVC, banner: BannerModel)
    func cashwalkBannerVCRequestGetBannerEmptyOrError(_ viewController: CashwalkBannerVC)
}

final class CashwalkBannerVC: UIViewController {
    
    // MARK: - Properties
    
    private var autoScrollIndex: Int = 1
    private var banners: [BannerModel]? {
        didSet {
            if  bannerCount == 1 {
                setContentViewCountOne()
                return
            }
            guard bannerCount > 1 else {return}
            setContentView()
        }
    }
    private var bannerCount: Int {
        guard let banners = banners else {return 0}
        return banners.count
    }
    private var timer: Timer?
    
    weak var delegate: CashwalkBannerVCDelegate?
    
    // MARK: - UI Components
    
    private var pageControl = UIPageControl().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.currentPageIndicatorTintColor = .white
        $0.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.3)
        $0.currentPage = 0
        $0.contentVerticalAlignment = .bottom
        $0.isHidden = true
    }
    private lazy var scrollView = UIScrollView(frame: .zero).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.isPagingEnabled = true
        $0.backgroundColor = .whiteThreeCw
    }
    
    // MARK: - Con(De)structor
    
    deinit {
        invalidateTimer()
        if #available(iOS 9.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        }
    }
    
    convenience init(position: InnerBannerPositionType) {
        self.init()
        
        setDelegate()
        setProperties()
        setSelector()
        view.addSubview(scrollView)
        view.addSubview(pageControl)
        layout()
        
        requestGetBanner(position: position)
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshTimer()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        invalidateTimer()
    }
    
    // MARK: - Internal methods
    
    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func refreshTimer() {
        guard timer == nil, bannerCount > 1 else {return}
        let scrollingTime = RemoteConfigManager.shared.getNumber(from: .ios_banner_time) == nil ? 5:RemoteConfigManager.shared.getNumber(from: .ios_banner_time)!
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(truncating: scrollingTime), target: self, selector: #selector(self.startAutoScrolling), userInfo: nil, repeats: true)
    }
    
    func requestGetBanner(position: InnerBannerPositionType) {
        BannerService().getBanner(position: position.rawValue) { (error, result) in
            guard error == nil, let banners = result?.banners, banners.count > 0 else {
                self.delegate?.cashwalkBannerVCRequestGetBannerEmptyOrError(self)
                return
            }
            var tempBanners = banners
            defer {
                self.banners = tempBanners
            }
            guard tempBanners.count > 1 else {return}
            tempBanners = tempBanners.shuffled().sorted(by: { (banner0, banner1) -> Bool in
                guard let order1 = banner0.order, let order2 = banner1.order else {return false}
                return order1 < order2
            })
            
            guard let firstBanner = tempBanners.first, let lastBanner = tempBanners.last else {return}
            tempBanners.append(firstBanner)
            tempBanners.insert(lastBanner, at: 0)
        }
    }
    
    // MARK: - Private methods
    
    private func getAutoScrollIndex(item: Int) -> Int {
        switch item {
        case let count where count == bannerCount-1:
            return 1
        default:
            return item+1
        }
    }
    
    private func setDelegate() {
        scrollView.delegate = self
    }
    
    private func setProperties() {
        view.backgroundColor = .clear
        view.clipsToBounds = true
    }
    
    private func setContentViewCountOne() {
        let subViews = scrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(bannerCount), height: scrollView.frame.height)
        
            if let image = banners?[0].image {
                var frame = CGRect()
                frame.origin.x = scrollView.frame.size.width * CGFloat(0)
                frame.origin.y = 0
                frame.size = scrollView.frame.size
                
                let imageView = UIImageView(frame: frame)
                let tap = UITapGestureRecognizer(target: self, action: #selector(clickedScrollViewBannerCountOne))
                scrollView.addGestureRecognizer(tap)
                scrollView.addSubview(imageView)
                imageView.kf.setImage(with: URL(string: image))
            }
        
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        
    }
    
    private func setContentView() {
        let subViews = scrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(bannerCount), height: scrollView.frame.height)
        
        for i in 0..<bannerCount {
            
            if let image = banners?[i].image {
                var frame = CGRect()
                frame.origin.x = scrollView.frame.size.width * CGFloat(i)
                frame.origin.y = 0
                frame.size = scrollView.frame.size
                
                let imageView = UIImageView(frame: frame)
                let tap = UITapGestureRecognizer(target: self, action: #selector(clickedScrollViewBanner))
                scrollView.addGestureRecognizer(tap)
                scrollView.addSubview(imageView)
                imageView.kf.setImage(with: URL(string: image))
            }
        }
        
        pageControl.isHidden = false
        pageControl.numberOfPages = self.bannerCount-2
        
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
        
        guard timer == nil else {return}
        let scrollingTime = RemoteConfigManager.shared.getNumber(from: .ios_banner_time) == nil ? 5:RemoteConfigManager.shared.getNumber(from: .ios_banner_time)!
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(truncating: scrollingTime), target: self, selector: #selector(startAutoScrolling), userInfo: nil, repeats: true)
        
    }
    
    private func scrollViewOffsetX(lastIndex: Int) -> CGFloat {
        return scrollView.frame.size.width * CGFloat(bannerCount-lastIndex)
    }
    
    private func setSelector() {
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    // MARK: - Private selector
    
    @objc private func didEnterBackground() {
        invalidateTimer()
    }
    
    @objc private func willEnterForeground() {
        refreshTimer()
    }
    
    @objc private func startAutoScrolling() {
        let lastOffsetX = scrollViewOffsetX(lastIndex: 2)
        let currentOffsetX = scrollView.contentOffset.x
        autoScrollIndex = getAutoScrollIndex(item: autoScrollIndex)
        
        if currentOffsetX == lastOffsetX, autoScrollIndex == 4 {
            scrollView.setContentOffset(CGPoint(x: lastOffsetX + scrollView.frame.size.width, y: 0), animated: true)
            scrollViewDidScroll(scrollView)
            autoScrollIndex = 1
        } else {
            scrollView.setContentOffset(CGPoint(x: (scrollView.frame.width * CGFloat(autoScrollIndex)), y: 0), animated: true)
        }
        pageControl.currentPage = autoScrollIndex-1
    }
    
    @objc private func clickedScrollViewBanner() {
        guard let banner = banners?[pageControl.currentPage+1], let id = banner.id else {return}
        BannerService().postBanner(type: "click", id: id)
        delegate?.cashwalkBannerVCDidClicked(self, banner: banner)
    }
    
    @objc private func clickedScrollViewBannerCountOne() {
        guard let banner = banners?[pageControl.currentPage], let id = banner.id else {return}
        BannerService().postBanner(type: "click", id: id)
        delegate?.cashwalkBannerVCDidClicked(self, banner: banner)
    }
    
}

// MARK: - Layout

extension CashwalkBannerVC {
    
    private func layout() {
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        pageControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
}

// MARK: - UIScrollViewDelegate

extension CashwalkBannerVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard banners != nil, scrollView.contentOffset.x < 10 ||
            scrollView.contentOffset.x > scrollViewOffsetX(lastIndex: 1)-10 else {return}
        
        let maxOffsetX = scrollViewOffsetX(lastIndex: 1)
        let currentOffsetX = scrollView.contentOffset.x
        
        if currentOffsetX >= maxOffsetX {
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
        } else if currentOffsetX == 0 {
            scrollView.contentOffset = CGPoint(x: scrollViewOffsetX(lastIndex: 2), y: 0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimer()
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard banners != nil else { return }
        
        let maxOffsetX = scrollViewOffsetX(lastIndex: 1)
        let currentOffsetX = targetContentOffset.pointee.x
        
        if currentOffsetX >= maxOffsetX {
            pageControl.currentPage = 0
        } else if currentOffsetX < 10 {
            pageControl.currentPage = bannerCount - 2
        } else {
            if abs(velocity.x) > abs(velocity.y) {
                var value: Int = 1
                if velocity.x < 0 {
                    value = -1
                }
                pageControl.currentPage += value
            }
        }
        guard let banner = banners?[pageControl.currentPage], let id = banner.id else {return}
        BannerService().postBanner(type: "view", id: id)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshTimer()
        autoScrollIndex = getAutoScrollIndex(item: pageControl.currentPage)
    }
    
}
