//
//  InitialViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

final class InitialViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private lazy var viewModel: InitialViewModel = .init(navigator: .init(parentViewController: self))
    
    private var autoScrollIndex: Int = 1
    private var initialViews: [UIView]? {
        didSet {
            guard viewCount > 1 else { return }
            setContentView()
        }
    }
    private var viewCount: Int {
        guard let views = initialViews else {return 0}
        return views.count
    }
    private var timer: Timer?
    
    // MARK: - UI Components
    
    private let pageControl: UIPageControl = {
        let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.currentPage = 0
        control.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        control.currentPageIndicatorTintColor = .yellowCw
        control.pageIndicatorTintColor = .grayCw
        return control
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: .zero)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.bounces = false
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        return scrollView
    }()
//    private let firstView = InitialView(title: "적립된 캐시로 쇼핑을\n즐겨보세요!",
//                                        subTitle: "적립된 캐시로 쇼핑",
//                                        imageName: "imgTutorial05")
    private let firstView = UIView()
    
    private let initial00View = Initial01View()
    private let initial01View = Initial02View()
    // mydata 관련 히든
//    private let initial01View = InitialView(title: "흩어진 자산을 정리하고\n캐시적립",
//                                            subTitle: "흩어진 자산을 정리",
//                                            imageName: "imgTutorial02")
    private let initial03View = InitialView(title: "의료, 건강 기록 확인하면\n캐시 추가 적립",
                                            subTitle: "의료, 건강 기록 확인하면",
                                            imageName: "imgTutorial04")
    private let initial04View = InitialView(title: "적립된 캐시로\n다양한 쇼핑을 즐겨보세요!",
                                            subTitle: "적립된 캐시",
                                            imageName: "imgTutorial05")
    private let lastView = UIView()
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setDelegate()
        setSelector()
        view.addSubview(pageControl)
        view.addSubview(scrollView)
        layout()
        setInitialViews()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        invalidateTimer()
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
    }
    
    private func setInitialViews() {
        var tempViews = [UIView]()
        defer {
            self.initialViews = tempViews
        }
//        setInitialUIView(initial00View)
//        setInitialUIView(lastView)
        tempViews.append(firstView)
        tempViews.append(initial00View)
        tempViews.append(initial01View)
        // mydata 관련 히든
        // tempViews.append(initial01View)
        tempViews.append(initial03View)
        tempViews.append(initial04View)
        tempViews.append(firstView)
//        tempViews.append(lastView)
    }
    
    private func setInitialUIView(_ view: UIView) {
        let _label = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.numberOfLines = 0
            let paragraph = NSMutableParagraphStyle()
            paragraph.minimumLineHeight = 40
            paragraph.alignment = .center
            let attributedString = NSMutableAttributedString(string: "매일 리워드가 쌓이는\n건강관리 리워드 앱 캐시닥", attributes: [
                .font: UIFont.systemFont(ofSize: 28 * widthRatio, weight: .regular),
                .foregroundColor: UIColor.blackCw,
                .kern: 0.0
            ])
            let range = (attributedString.string as NSString).range(of: "건강관리 리워드 앱 캐시닥")
            attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 28 * widthRatio, weight: .bold), range: range)
            
            attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
            $0.attributedText = attributedString
        }
        let _image = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "imgTutorial01")
        }
        
        view.addSubview(_label)
        view.addSubview(_image)
        initialUIViewLayout(with: view,
                            _label: _label,
                            _image: _image)
    }
    
    private func initialUIViewLayout(with _view: UIView,
                                     _label: UILabel,
                                     _image: UIImageView) {
        _image.leadingAnchor.constraint(equalTo: _view.leadingAnchor).isActive = true
        _image.trailingAnchor.constraint(equalTo: _view.trailingAnchor).isActive = true

        _label.centerXAnchor.constraint(equalTo: _view.centerXAnchor).isActive = true
        
        if ScreenSize.HEIGHT > 736 {
            _label.topAnchor.constraint(equalTo: _view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 110).isActive = true
            _image.bottomAnchor.constraint(equalTo: _view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -102).isActive = true
        } else if ScreenSize.HEIGHT == 568 {
            _label.topAnchor.constraint(equalTo: _view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 76).isActive = true
            _image.bottomAnchor.constraint(equalTo: _view.bottomAnchor, constant: 100).isActive = true
        } else {
            _label.topAnchor.constraint(equalTo: _view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 92).isActive = true
            _image.bottomAnchor.constraint(equalTo: _view.bottomAnchor, constant: -30).isActive = true
        }
    }
    
    private func setContentView() {
        view.layoutIfNeeded()
        
        let subViews = scrollView.subviews
        for subView in subViews {
            subView.removeFromSuperview()
        }
        
        scrollView.contentSize = CGSize(width: scrollView.frame.width * CGFloat(viewCount),
                                        height: scrollView.frame.height)
        
        for i in 0..<viewCount {
            if let view = initialViews?[i] {
                var frame = CGRect()
                frame.origin.x = scrollView.frame.width * CGFloat(i)
                frame.origin.y = 0
                frame.size = scrollView.frame.size
                
                view.frame = frame
                scrollView.addSubview(view)
            }
        }
        
        pageControl.isHidden = false
        pageControl.numberOfPages = self.viewCount-2
        
        scrollView.contentOffset = CGPoint(x: scrollView.frame.width, y: 0)
        
        refreshTimer()
    }
    
    private func setDelegate() {
        scrollView.delegate = self
    }
    
}

// MARK: - Layout

extension InitialViewController {
    
    private func layout() {
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 50).isActive = true
    }
    
}

// MARK: - UIScrollViewDelegate

extension InitialViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0.0
        
        guard viewCount > 0, scrollView.contentOffset.x < 10 ||
            scrollView.contentOffset.x > scrollViewOffsetX(lastIndex: 1)-10 else { return }

        let maxOffsetX = scrollViewOffsetX(lastIndex: 1)
        let currentOffsetX = scrollView.contentOffset.x

        if currentOffsetX >= maxOffsetX {
            scrollView.contentOffset = CGPoint(x: scrollView.frame.size.width, y: 0)
            pageControl.currentPage = 0
        } else if currentOffsetX == 0 {
            scrollView.contentOffset = CGPoint(x: scrollViewOffsetX(lastIndex: 1), y: 0)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        invalidateTimer()
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard viewCount > 0 else { return }

        let maxOffsetX = scrollViewOffsetX(lastIndex: 1)
        let currentOffsetX = targetContentOffset.pointee.x

        if currentOffsetX >= maxOffsetX {
            pageControl.currentPage = 0
        } else if currentOffsetX < 10 {
            pageControl.currentPage = viewCount - 1
        } else {
            if abs(velocity.x) > abs(velocity.y) {
                var value: Int = 1
                if velocity.x < 0 {
                    value = -1
                }
                pageControl.currentPage += value
            }
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshTimer()
        autoScrollIndex = getAutoScrollIndex(item: pageControl.currentPage)
    }
    
}

// MARK: - AutoScroll

extension InitialViewController {
    
    private func setSelector() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    // MARK: - Timer
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func refreshTimer() {
        guard timer == nil else { return }
        let scrollingTime: NSNumber = 5
        timer = Timer.scheduledTimer(timeInterval: TimeInterval(truncating: scrollingTime),
                                     target: self,
                                     selector: #selector(startAutoScrolling),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    // MARK: - Private selector
    
    @objc
    private func didEnterBackground() {
        invalidateTimer()
    }
    
    @objc
    private func willEnterForeground() {
        refreshTimer()
    }
    
    @objc
    private func startAutoScrolling() {
        let lastOffsetX = scrollViewOffsetX(lastIndex: 1)
        let currentOffsetX = scrollView.contentOffset.x
        autoScrollIndex = getAutoScrollIndex(item: autoScrollIndex) 
        
        if currentOffsetX == lastOffsetX, autoScrollIndex == pageControl.numberOfPages {
            scrollView.setContentOffset(CGPoint(x: lastOffsetX + scrollView.frame.size.width, y: 0), animated: true)
            scrollViewDidScroll(scrollView)
            autoScrollIndex = 1
        } else {
            scrollView.setContentOffset(CGPoint(x: (scrollView.frame.width * CGFloat(autoScrollIndex)), y: 0), animated: true)
        }
        pageControl.currentPage = autoScrollIndex-1
    }
    
    private func scrollViewOffsetX(lastIndex: Int) -> CGFloat {
        return scrollView.frame.size.width * CGFloat(viewCount - lastIndex)
    }
    
    private func getAutoScrollIndex(item: Int) -> Int {
        switch item {
        case let count where count == viewCount-1:
            return 0
        default:
            return item+1
        }
    }
    
}
