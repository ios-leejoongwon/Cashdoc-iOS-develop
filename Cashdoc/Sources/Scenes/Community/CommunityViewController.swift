//
//  CommunityViewController.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/07.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import UIKit
import WebKit

class CommunityViewController: CashdocViewController {
    
    var selectIndex = BehaviorRelay<Int>.init(value: 0)
    var useScroll: Bool = false
    var curWebView: WKWebView?
    private var config = WKWebViewConfiguration()
    
    private var footerNaviBtn01: UIButton!
    private var footerNaviBtn02: UIButton!
    private var footerNaviBtn03: UIButton!
    
    var categoryList = BehaviorRelay<[AvocatalkCategoryModel]>(value: []) 
    
    private let leftButton = UIBarButtonItem().then {
        $0.image = UIImage(named: "icMenuWhite")
    }
    
    private let arrowButton = UIButton().then {
        $0.setImage(UIImage(named: "icArrow01StyleDownBlack"), for: .normal)
        $0.backgroundColor = .white
        $0.isSelected = false
    }
    
    private let dimmedButton = UIButton().then {
        $0.setBackgroundColor(UIColor.fromRGBA(0, 0, 0, 0.5), forState: .normal)
        $0.isHidden = true
    }
    
    private let scrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let scrollHStack = UIStackView.simpleMakeSV(.horizontal, spacing: 0)
    
    private let slideMenuCollection = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.register(Cell.community)
    }

    private let showMenuCollection = UICollectionView(frame: .zero, collectionViewLayout: .init()).then {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        $0.collectionViewLayout = layout
        $0.backgroundColor = .white
        $0.showsHorizontalScrollIndicator = false
        $0.isHidden = true
        $0.register(Cell.communityMenu)
    }
    
    private struct Cell {
        static let community = CollectionViewCell<CommunityCollectionCell>()
        static let communityMenu = CollectionViewCell<CommunityMenuCollectionCell>()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        GlobalDefine.shared.mainCommunityVC = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        _ = UIView().then {
            $0.backgroundColor = .yellowCw
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.left.top.right.equalToSuperview()
                m.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
            }
        }
        
        requestCategoryList()
    }
    
    func setupView() {
        
        let menuView = UIView().then {
            $0.backgroundColor = .white
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                m.left.right.equalToSuperview()
                m.height.equalTo(48)
            }
        }
        
        arrowButton.do {
            menuView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                m.right.bottom.equalToSuperview()
                m.width.equalTo(48)
            }
        }
        
        slideMenuCollection.do {
            $0.dataSource = self
            $0.delegate = self
            menuView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                m.left.bottom.equalToSuperview()
                m.right.equalTo(arrowButton.snp.left)
            }
        }
        
        _ = UIView().then {
            $0.backgroundColor = .grayFourCw
            menuView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.bottom.right.equalToSuperview()
                m.height.equalTo(1)
            }
        }
        
        let footerNaviStack = UIStackView.simpleMakeSV(.horizontal, spacing: 0, alignment: .center).then {
            let background = UIView()
            background.backgroundColor = .white
            $0.distribution = .fillEqually
            $0.backgroundColor = .white
            background.addSubview($0)
            view.addSubview(background)
            
            background.snp.makeConstraints { m in
                m.left.right.equalToSuperview()
                m.height.equalTo(48)
                m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
            
            $0.snp.makeConstraints { m in
                m.edges.equalToSuperview()
            }
        }
        
        footerNaviBtn01 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleLeftWeb"), for: .normal)
            footerNaviStack.addArrangedSubview($0)
        }
        
        footerNaviBtn02 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleRightWeb"), for: .normal)
            footerNaviStack.addArrangedSubview($0)
        }
        
        footerNaviBtn03 = UIButton().then {
            $0.setImage(UIImage(named: "icUpdateGrayWeb"), for: .normal)
            footerNaviStack.addArrangedSubview($0)
        }
        
        scrollView.do {
            $0.delegate = self
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(menuView.snp.bottom)
                m.bottom.equalTo(footerNaviStack.snp.top)
                m.left.right.equalToSuperview()
            }
        }
        scrollHStack.do {
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.edges.equalToSuperview()
                m.height.equalToSuperview()
            }
        }
        
        categoryList.asObservable().bind { [weak self] list in
            guard let self = self else { return }
            print("list = \(list.count)")
            for categoryInfo in list {                
                let wkPreferences = WKPreferences()
                wkPreferences.javaScriptCanOpenWindowsAutomatically = true
                
                self.config = WKWebViewConfiguration()
                self.config.preferences = wkPreferences
                self.config.preferences.javaScriptEnabled = true
                self.config.websiteDataStore = WKWebsiteDataStore.default()
                
                let makeWebView = WKWebView(frame: .zero, configuration: self.config).then {
                    $0.tag = (categoryInfo.order - 1) + 10
                    $0.navigationDelegate = self
                    $0.uiDelegate = self
                    self.scrollHStack.addArrangedSubview($0)
                    $0.snp.makeConstraints { m in
                        m.width.equalTo(self.view.snp.width)
                    }
                    if categoryInfo.order == 1 {
                        self.curWebView = $0
                        
                        switch categoryInfo.type {
                        case AvocatalkCategoryModel.LinkType.chat.rawValue: // 오픈챗방
                            guard let makeURL = URL(string: "\(API.HOME_WEB_URL)community/openchat/\(categoryInfo.id)") else { return}
                            let request = self.requestAddPostBody(makeURL)
                            Log.al("request = \(request.url?.absoluteString ?? "")")
                            $0.load(request)
                        case AvocatalkCategoryModel.LinkType.link.rawValue: // 외부링크
                            guard let link = categoryInfo.link, let makeURL = URL(string: link) else {
                                return
                            }
                            UIApplication.shared.open(makeURL, options: [:], completionHandler: nil)
                        default:
                            if let link = categoryInfo.link, let makeURL = URL(string: link) {
                                $0.load(URLRequest(url: makeURL))
                            }
                        }
                        
                    }
                }
                
                _ = UIActivityIndicatorView(style: .gray).then {
                    $0.tag = (categoryInfo.order - 1) + 100
                    makeWebView.addSubview($0)
                    $0.snp.makeConstraints { m in
                        m.center.equalToSuperview()
                    }
                    $0.startAnimating()
                }
            }
            
        }.disposed(by: disposeBag)
        
        if self.useScroll, let webView = self.curWebView {
            let didFinished: Observable<CGPoint> = webView.rx.didFinishLoad.take(1).map { _ in CGPoint.zero }
            webView.rx.didFinishLoad.subscribe().disposed(by: self.disposeBag)
            webView.scrollView.bounces = true
            let makeRefresh = UIRefreshControl()
            webView.scrollView.refreshControl = makeRefresh
            webView.scrollView.rx.contentOffset
                .skip(until: didFinished)
                .bind(to: GlobalDefine.shared.mainSegTopOffset)
                .disposed(by: self.disposeBag)
            makeRefresh.rx.controlEvent(.valueChanged)
                .bind { (_) in
                    webView.reload()
                }.disposed(by: self.disposeBag)
        }
        
        showMenuCollection.do {
            $0.dataSource = self
            $0.delegate = self
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.equalToSuperview()
                m.top.equalTo(menuView.snp.bottom)
                m.height.equalTo(0)
            }
        }
        
        dimmedButton.do {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.left.bottom.equalToSuperview()
                m.top.equalTo(showMenuCollection.snp.bottom)
            }
        }
    }
    
    func setupProperty() {
        self.bindView()
    }
    
    private func bindView() {
        
        selectIndex.distinctUntilChanged()
            .debounce(.milliseconds(100), scheduler: MainScheduler.instance)
            .subscribe { [weak self] index in
                guard let self = self else { return }
                guard let getIndex = index.element else { return }
                if let getWebView = self.view.viewWithTag(getIndex + 10) as? WKWebView {
                    self.curWebView = getWebView
                    if getWebView.url == nil, let categoryInfo = self.categoryList.value[safe: getIndex] {

                        switch categoryInfo.type {
                        case AvocatalkCategoryModel.LinkType.chat.rawValue: // 오픈챗방
                            
                            guard let makeURL = URL(string: "\(API.HOME_WEB_URL)community/openchat/\(categoryInfo.id)") else { return }
                            let request = self.requestAddPostBody(makeURL)
                            Log.al("request = \(request.url?.absoluteString ?? "")")
                            getWebView.load(request)
                        case AvocatalkCategoryModel.LinkType.link.rawValue: // 외부링크
                            guard let link = categoryInfo.link, let makeURL = URL(string: link) else {
                                return
                            }
                            UIApplication.shared.open(makeURL, options: [:], completionHandler: nil)
                        default:
                            if let link = categoryInfo.link, let makeURL = URL(string: link) {
                                getWebView.load(URLRequest(url: makeURL))
                            }
                        }
                        
                    } else if let link = self.categoryList.value[safe: getIndex]?.link {
                        // 링크가 뷰티매니아 카페내 리스트인데 현재 웹페이지기 카페내가 아니라면 링크로 재로드한다.
                        if let webUrl = getWebView.url {
                            print("webUrl = \(webUrl)")
                            if !(webUrl.absoluteString.contains("25389985")) {
                                if let makeURL = URL(string: link) {
                                    getWebView.load(URLRequest(url: makeURL))
                                }
                            }
                        }
                    }
                    
                    self.slideMenuCollection.reloadData()
                    let makeIndex = IndexPath(row: getIndex, section: 0)
                    self.slideMenuCollection.scrollToItem(at: makeIndex, at: .centeredHorizontally, animated: true)
                    self.showMenuCollection.reloadData()
                }
            }.disposed(by: disposeBag)
        
        footerNaviBtn01.rx.tapGesture()
            .subscribe { [weak self] _ in
                self?.curWebView?.goBack()
            }.disposed(by: disposeBag)
        
        footerNaviBtn02.rx.tapGesture()
            .subscribe { [weak self] _ in
                self?.curWebView?.goForward()
            }.disposed(by: disposeBag)
        
        footerNaviBtn03.rx.tapGesture()
            .subscribe { [weak self] _ in
                self?.curWebView?.reload()
            }.disposed(by: disposeBag)
        
        arrowButton.rx.tapGesture()
            .subscribe { [weak self] _ in
                let makeBool = !(self?.arrowButton.isSelected ?? false)
                self?.showMenuColletion(makeBool)
            }.disposed(by: disposeBag)
        
        dimmedButton.rx.tapGesture()
            .subscribe { [weak self] _ in
                self?.showMenuColletion(true)
            }.disposed(by: disposeBag)
    }
    
    private func changeSegment(_ index: Int) {
        self.scrollView.setContentOffset(CGPoint(x: view.frame.width * CGFloat(index), y: 0), animated: true)
        
    }
    
    private func showMenuColletion(_ show: Bool) {
        arrowButton.isSelected = show
        arrowButton.transform = show ? .identity : CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        showMenuCollection.isHidden = show
        dimmedButton.isHidden = show
    }
    
    private func requestCategoryList() {
        let provider = CashdocProvider<AvocatalkService>()
        provider.CDRequest(.getCategory) { (json) in
            let result = json["categories"].arrayValue
            var list = [AvocatalkCategoryModel]()
            for i in result {
                list.append(AvocatalkCategoryModel(i))
            }
            let sortList = list.sorted(by: {$0.order < $1.order})
            self.categoryList.accept(sortList)
            self.reloadCollectionView()
        }
    }
    
    private func reloadCollectionView() {
        self.showMenuCollection.snp.updateConstraints { m in
            var height = (self.categoryList.value.count/3) * 44
            if (self.categoryList.value.count % 3) > 0 {
                height += 44
            }
            print("showMenuCollection.height = \(height)")
            m.height.equalTo(height)
            self.view.layoutIfNeeded()
        }
        self.slideMenuCollection.reloadData()
        self.showMenuCollection.reloadData()
    }
    
    // 쿠키에서 postbody값으료 변경함
    func requestAddPostBody(_ getURL: URL) -> URLRequest {
        var request = URLRequest(url: getURL)
        request.httpMethod = "POST"
        var makeURL = URL(string: API.HOME_WEB_URL)!
        makeURL.append("cashdocAccessToken", value: AccessTokenManager.accessToken)
        makeURL.append("cashdocDevice", value: "ios")
        makeURL.append("cashdocAdvId", value: GlobalFunction.getDeviceID())
        makeURL.append("cashdocAppReview", value: "\(UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue))")
        makeURL.append("cashdocUserAppVersion", value: getAppVersion())
        
        let body = makeURL.query?.data(using: .utf8)
        request.httpBody = body
        return request
    }
}

// MARK: UICollectionViewDataSource

extension CommunityViewController: UICollectionViewDataSource {
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return self.categoryList.value.count
        
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        if collectionView == showMenuCollection {
            let cell = collectionView.dequeue(Cell.communityMenu, for: indexPath)
            if let commType = self.categoryList.value[safe: indexPath.row] {
                cell.drawCell(commType, isSel: indexPath.row == selectIndex.value)
            }
            return cell
        } else {
            let cell = collectionView.dequeue(Cell.community, for: indexPath)
            if let commType = self.categoryList.value[safe: indexPath.row] {
                cell.drawCell(commType, isSel: indexPath.row == selectIndex.value)
            }
            return cell
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension CommunityViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        if collectionView == showMenuCollection {
            return .init(width: Int(collectionView.frame.width / 3), height: 44)
        }
        
        let dummyLabel = UILabel().then {
            $0.font = .systemFont(ofSize: 16)
            if let commType = self.categoryList.value[safe: indexPath.row] {
                $0.text = commType.name
            }
            $0.sizeToFit()
        }
        return .init(width: dummyLabel.frame.width, height: 20)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionView == showMenuCollection ? 0 : 16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionView == showMenuCollection ? 0 : 16
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        if collectionView == showMenuCollection {
            return .zero
        } else {
            return .init(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView == showMenuCollection {
                self.showMenuColletion(true)
        }
        self.changeSegment(indexPath.row)
    }
}

// MARK: WKUIDelegate, WKNavigationDelegate

extension CommunityViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.view.viewWithTag(webView.tag + 90)?.removeFromSuperview()
        
        print("webView didFinish")
    }
    
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void ) {
        print("decidePolicyFor = \(navigationAction.request.url?.absoluteString ?? "")")
        
        if navigationAction.navigationType == .linkActivated {
            wkNavigationTypeLinkActivated(navigationAction: navigationAction, decisionHandler: decisionHandler)
            return
        }
         
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
        
        if ["kakaoopen", "kakaolink", "daumcafe", "itms-apps", "naversearchthirdlogin"].contains(url.scheme) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                decisionHandler(.cancel)
                return
            }
        } else if ["navercafe"].contains(url.scheme) {
            
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                
            } else {
                guard let naverStore = URL(string: "https://itunes.apple.com/us/app/neibeo-kape-naver-cafe/id420615104?mt=8") else { return decisionHandler(.allow) }
                UIApplication.shared.open(naverStore, options: [:], completionHandler: nil)
            }
            
            decisionHandler(.cancel)
            return
            
        } else if url.absoluteString.hasPrefix("cdapp") {
            DeepLinks.openSchemeURL(urlstring: url.absoluteString, gotoMain: false)
            decisionHandler(.cancel)
            return
        }
        
        // 서비스 상황에 맞는 나머지 로직을 구현합니다.
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        Log.al("runJavaScriptAlertPanelWithMessage msg = \(message)")
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        Log.al("runJavaScriptConfirmPanelWithMessage msg = \(message)")
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func wkNavigationTypeLinkActivated(navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        Log.al("wkNavigationTypeLinkActivated")
        defer {
            decisionHandler(.cancel)
        }
        
        guard let url = navigationAction.request.url else {return}
        let request = requestAddPostBody(url)
        
        Log.al("loadWebView: \(url), \(request)")
        if let curWebView = self.curWebView {
            DispatchQueue.main.async {
                curWebView.load(request)
            }
        }
    }
}

// MARK: UIScrollViewDelegate

extension CommunityViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let curPage = Int(floor(scrollView.contentOffset.x / scrollView.bounds.width))
            selectIndex.accept(curPage)
        }
    }
}
