//
//  CashdocWebViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import WebKit
import RxSwift
import SnapKit
import Then 

class CashdocWebViewController: CashdocViewController, ExceptionableCompatible {
    
    enum LoadType {
        case load, ready
    }
     
    // MARK: - Properties
    var urlString: String = ""
    var addfooter: Bool = false
    var hiddenbar: Bool = false
    var getPropertyNavigator: PropertyNavigator?
    var getLoadType: LoadType = .load
    private(set) var isLoaded: Bool = false // 웹뷰가 실제 로드가 완료 됐는지 여부. isLoading과는 다름.
    var communityPostsURL: String?  // 딥링크로 들어온 후 커뮤니티 게시판 open url
    var useScroll: Bool = false
    private var webView: WKWebView?
    private var config = WKWebViewConfiguration()
    private let contentController = WKUserContentController()
    var webType: WebType = .normal

    private var footerButton01: UIButton?
    private var footerButton02: UIButton?
    
    var backButtonType: BackButtonType {
        return .back
    } 
    // MARK: - Overridden: UIViewController
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
    init(title: String, url: String, webType: WebType? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        self.webType = webType ?? .normal
        self.urlString = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        Log.al("self.urlString = \(self.urlString)")
        
// 굿닥 지금은 사용안하지만 나중엔 사용할 수 있어서 남겨둠.
//        if let makeEncode = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), !url.hasPrefix("https://www.goodoc.co.kr") {
//            self.urlString = makeEncode
//        } else {
//            self.urlString = url
//        }
    }
    
    init(tempIndex: Int, type: TermType) {
        super.init(nibName: nil, bundle: nil)
        switch tempIndex {
        case 1:
            self.title = "이용약관 동의"
            switch type {
            case .insurance:
                urlString = API.INSURANCE_TERMS_URL
            case .cashDoc:
                urlString = API.CASHDOC_TERMS_URL
            }
            self.webType = .terms
        case 2:
            self.title = "개인정보 수집 및 이용 동의"
            switch type {
            case .insurance:
                urlString = API.INSURANCE_PRIVACY_URL
            case .cashDoc:
                urlString = API.CASHDOC_PRIVACY_URL
            }
            self.webType = .terms
        case 3:
            switch type {
            case .insurance, .cashDoc:
                break
            }
            self.webType = .terms
        default:
            self.webType = .normal
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.setUserController()
        if getLoadType == .load {
            setupWebConfiguration()
        }
        
        if title == "캐시로또" {
            GlobalDefine.shared.mainHome?.appearWithLotto = true
            self.navigationItem.rightBarButtonItem =  UIBarButtonItem(image: UIImage(named: "lottoShopBtn"), style: .plain, target: self, action: #selector(gotoShop))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if hiddenbar {
            self.navigationController?.setNavigationBarHidden(true, animated: false)
            _ = UIView().then {
                $0.backgroundColor = .yellowCw
                view.addSubview($0)
                $0.snp.makeConstraints { (m) in
                    m.left.top.right.equalToSuperview()
                    m.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
                }
            }
        } else {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
            let button = UIBarButtonItem(title: "",
                                         style: .plain,
                                         target: self,
                                         action: #selector(popToVC))
            button.image = UIImage(named: "icArrow02StyleLeftBlack")
            navigationItem.leftBarButtonItem = button
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        GlobalDefine.shared.isPossibleShowPopup = true
        if hiddenbar {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
    
    @objc func gotoShop() {
        GlobalFunction.pushToWebViewController(title: "캐시로또샵", url: API.CASH_SHOP_URL)
    }
    
    func loadWebView(with url: String) {
        
        guard let url = URL(string: url) else { return }
        var request: URLRequest?
        
        if self.webType == .terms {
            request = URLRequest(url: url)
        } else {
            request = requestAddPostBody(url)
        }
         
        if self.webView != nil, let request = request {
            DispatchQueue.main.async {
                 self.webView?.load(request)
            }
        }
        exceptionable.configure()
        
        if url.absoluteString == API.YEOGIYA_DOMAIN && webType == .yeogiya {
            let helpButtonItem = UIBarButtonItem().then {
                let button = UIButton()
                button.setImage(UIImage(named: "icQuestionCircleBlack"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                button.addTarget(self, action: #selector(clickHelpButton), for: .touchUpInside)
                $0.customView = button
            }

            let myPageButtonItem = UIBarButtonItem().then {
                let button = UIButton()
                button.setImage(UIImage(named: "icMyBlack"), for: .normal)
                button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                button.addTarget(self, action: #selector(clickMyPageButton), for: .touchUpInside)
                $0.customView = button
            }

            self.navigationItem.rightBarButtonItems = [myPageButtonItem, helpButtonItem]
        }
    }
    
    // 쿠키에서 postbody값으료 변경함
    func requestAddPostBody(_ getURL: URL) -> URLRequest {
        var request = URLRequest(url: getURL)
          
        if webType.makeBody(url: getURL) != [:] {
            request.httpMethod = "POST"
            let bodyString = webType.makeBody(url: getURL)
                .compactMap { "\($0.key)=\($0.value)" }
                .joined(separator: "&")
            let httpBody = bodyString.data(using: .utf8)
            request.httpBody = httpBody
        }
        return request
    }
    
    func load() {
        setupWebConfiguration()
        isLoaded = true
    }
    
    // MARK: - Private methods
    
    private func setupWebConfiguration() {
//        let cookie01 = HTTPCookie(properties: [
//            .domain: API.HOME_WEB_DOMAIN,
//            .path: "/",
//            .name: "cashdocCookie",
//            .value: AccessTokenManager.accessToken
//        ])!
//
//        let cookie02 = HTTPCookie(properties: [
//            .domain: API.HOME_WEB_DOMAIN,
//            .path: "/",
//            .name: "cashdocCookieDevice",
//            .value: "ios"
//        ])!
        
//        let cookie03 = HTTPCookie(properties: [
//            .domain: API.HOME_WEB_DOMAIN,
//            .path: "/",
//            .name: "cashdocCookieAdvId",
//            .value: GlobalFunction.getDeviceID()
//        ])!
        let cookie04 = HTTPCookie(properties: [
            .domain: self.makeDomain(API.COMMUNITY_WEB_URL),
            .path: "/",
            .name: "xat",
            .value: UserManager.shared.communityToken ?? ""
        ])!
        let cookie05 = HTTPCookie(properties: [
            .domain: self.makeDomain(API.COMMUNITY_API_URL),
            .path: "/",
            .name: "xat",
            .value: UserManager.shared.communityToken ?? ""
        ])!
//        let cookie06 = HTTPCookie(properties: [
//            .domain: "https://www.goodoc.co.kr",
//            .path: "/",
//            .name: "cashdocCookieUserAppVersion",
//            .value: getAppVersion()
//        ])!
        
        let makeCookies = [cookie04, cookie05]
         
        config.includeCustomCookies(urlString: urlString, cookies: makeCookies) { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.config.preferences.javaScriptEnabled = true
                self.webView?.removeFromSuperview()
                self.webView = WKWebView(frame: .zero, configuration: self.config).then {
                    $0.navigationDelegate = self
                    $0.uiDelegate = self
                    $0.scrollView.delegate = self
                    $0.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
                    self.view.addSubview($0)
                    $0.snp.makeConstraints { make in
                        make.leading.trailing.equalToSuperview()
                        make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                        make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(self.addfooter ? -48 : 0) // <-- 우선순위.
                    }
                    self.disableBounces($0)
                }
                
                if self.addfooter {
                    self.makeFooterView()
                }
                
                if self.useScroll, let webView = self.webView {
                    let didFinished: Observable<CGPoint> = webView.rx.didFinishLoad.take(1).map { _ in CGPoint.zero }
                    webView.rx.didFinishLoad.subscribe().disposed(by: self.disposeBag)
                    webView.scrollView.bounces = false
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
                self.loadWebView(with: self.urlString)
            }
        }
    }
    
    private func setUserController() {
        Log.al("setUserController")
//        self.contentController.addUserScript(self.getZoomDisableScript())
//        self.contentController.add(self, name: "cashdocHandler")
//      self.config.userContentController = self.contentController
        self.config.userContentController = webType.userContents(self)
    }
    
    func setupScript(_ source: String,
                     injectionTime: WKUserScriptInjectionTime = .atDocumentStart,
                     forMainFrameOnly: Bool = true) {
        let script = WKUserScript(source: source, injectionTime: injectionTime, forMainFrameOnly: forMainFrameOnly)
        self.contentController.addUserScript(script)
    }
    
    private func removeUserController() {
        DispatchQueue.main.async {
            self.contentController.removeAllUserScripts()
            self.webType.removeScriptMessageHandler(self.webView)
        }
    }
    
    private func disableBounces(_ getWebview: WKWebView) {
        getWebview.scrollView.bounces = false
        
        for subview in getWebview.subviews {
            if let subview = subview as? UIScrollView {
                subview.bounces = false
            }
        }
    }
    
    private func getZoomDisableScript() -> WKUserScript {
        let source: String = "var meta = document.createElement('meta');" +
            "meta.name = 'viewport';" +
            "meta.content = 'width=device-width, initial-scale=1.0, maximum- scale=1.0, user-scalable=no';" +
            "var head = document.getElementsByTagName('head')[0];" + "head.appendChild(meta);"
        return WKUserScript(source: source,
                            injectionTime: .atDocumentEnd,
                            forMainFrameOnly: true)
    }
    
    private func makeDomain(_ urlString: String) -> String {
        guard let url = URL(string: urlString) else { return "" }
        let commDomain = url.components?.host ?? ""
        return commDomain
    }
    
    // MARK: - Action
    private func setTapMenu() {
        let tapMenuStackView = UIStackView().then {
            $0.distribution = .fillEqually
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.height.equalTo(50)
            }
        }
        
        _ = UIView().then {
            $0.backgroundColor = UIColor.fromRGB(233, 233, 233)
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(tapMenuStackView.snp_bottomMargin)
                make.height.equalTo(1)
            }
        }
            
    }
    
    private func makeFooterView() {
        let footerStackView = UIStackView().then {
            $0.distribution = .fillEqually
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
                make.height.equalTo(48)
            }
        }
        
        _ = UIView().then {
            $0.backgroundColor = UIColor.fromRGB(233, 233, 233)
            self.view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.left.right.equalToSuperview()
                make.top.equalTo(footerStackView.snp_topMargin)
                make.height.equalTo(1)
            }
        }
        
        footerButton01 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleLeftWeb"), for: .normal)
            $0.setImage(UIImage(named: "icArrow01StyleLeftWeb02"), for: .disabled)
            $0.setBackgroundColor(.grayTwoCw, forState: .normal)
            $0.setBackgroundColor(.grayTwoCw, forState: .disabled)
            $0.adjustsImageWhenHighlighted = false
            $0.isEnabled = false
            footerStackView.addArrangedSubview($0)
            $0.rx.tap.bind { [weak self] _ in
                self?.webView?.goBack()
            }.disposed(by: disposeBag)
        }
        
        footerButton02 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleRightWeb"), for: .normal)
            $0.setImage(UIImage(named: "icArrow01StyleRightWeb02"), for: .disabled)
            $0.setBackgroundColor(.grayTwoCw, forState: .normal)
            $0.setBackgroundColor(.grayTwoCw, forState: .disabled)
            $0.adjustsImageWhenHighlighted = false
            $0.isEnabled = false
            footerStackView.addArrangedSubview($0)
            $0.rx.tap.bind { [weak self] _ in
                self?.webView?.goForward()
            }.disposed(by: disposeBag)
        }
        
        _ = UIButton().then {
            $0.setImage(UIImage(named: "icUpdateGrayWeb"), for: .normal)
            $0.setBackgroundColor(.grayTwoCw, forState: .normal)
            $0.adjustsImageWhenHighlighted = false
            footerStackView.addArrangedSubview($0)
            $0.rx.tap.bind { [weak self] _ in
                self?.webView?.reload()
            }.disposed(by: disposeBag)
        }
        
        if webType != .yeogiya {
            _ = UIButton().then {
                $0.setImage(UIImage(named: "icShareGrayWeb"), for: .normal)
                $0.setBackgroundColor(.grayTwoCw, forState: .normal)
                $0.adjustsImageWhenHighlighted = false
                footerStackView.addArrangedSubview($0)
                $0.rx.tap.bind { [weak self] _ in
                    guard let self = self else { return }
                    let text = "\(self.webView?.url?.absoluteString ?? "공유하기")"
                    let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
                    activityVC.excludedActivityTypes = [.airDrop]
                    self.present(activityVC, animated: true, completion: nil)
                }.disposed(by: disposeBag)
            }
        }
        
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(popToVC))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
    } 
    
    @objc func popToVC() { 
        self.removeUserController()
        exceptionable.unconfigure()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func clickHelpButton() {
        let url = "\(API.YEOGIYA_DOMAIN)info/cash"
        Log.al(url)
        GlobalFunction.pushToWebViewController(title: "어디서했니", url: url, addfooter: false, hiddenbar: false, webType: .yeogiya)
    }
    
    @objc func clickMyPageButton() {
        let url = "\(API.YEOGIYA_DOMAIN)mypage"
        Log.al(url)
        GlobalFunction.pushToWebViewController(title: "어디서했니", url: url, addfooter: true, hiddenbar: false, webType: .yeogiya)
    }
}

// MARK: - WKUIDelegate, WKNavigationDelegate

extension CashdocWebViewController: WKUIDelegate, WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.isLoaded = true
        ProgressBarManager.shared.hideProgressBar(vc: self)
        if let getRefresh = webView.scrollView.refreshControl {
            getRefresh.endRefreshing()
        }
        if let url = URLComponents(string: self.urlString)?.host {
            if url.contains("yeogiya") {
                footerButton01?.isEnabled = true
                footerButton02?.isEnabled = true
            } else {
                footerButton01?.isEnabled = webView.canGoBack
                footerButton02?.isEnabled = webView.canGoForward
            }
        }
        
        if let url = self.communityPostsURL {
            GlobalFunction.pushToWebViewController(title: "커뮤니티", url: url, addfooter: true)
            self.communityPostsURL = nil
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.isLoaded {
            ProgressBarManager.shared.hideProgressBar(vc: self)
        } else {
            ProgressBarManager.shared.showProgressBar(vc: self)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
          
        if navigationAction.navigationType == .linkActivated {
            if let host = url.host, !host.contains("acs.hanacard.co.kr") {
                wkNavigationTypeLinkActivated(navigationAction: navigationAction, decisionHandler: decisionHandler)
                return
            }
        }
        
        let urlString = url.absoluteString
        Log.i("cahdocwebview open url : \(urlString)")
         
        if !url.absoluteString.hasPrefix("http"), !url.absoluteString.hasPrefix("https") {

            if urlString.hasPrefix("cdapp") {
                DeepLinks.openSchemeURL(urlstring: urlString, gotoMain: false)
                decisionHandler(.cancel)
                return
            } else if url.scheme == "yeogiya" {
                guard let isNoti = url.valueOf("newHospitalSubscription") else { return decisionHandler(.allow) }
                Log.al("isNoti = \(isNoti)")
                if isNoti == "on" {
                        GlobalFunction.setYeogiyaPush(isOn: true)
                } else {
                        GlobalFunction.setYeogiyaPush(isOn: false)
                }
                decisionHandler(.cancel)
                return
            } else if urlString.hasPrefix("about:blank") {
                decisionHandler(.allow)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    decisionHandler(.cancel)
                    return
                } else {
                    decisionHandler(.allow)
                }
            }
        } else {
            if let getHost = url.host, getHost.contains("yeogiya"), url.path != "/", self.urlString.hasSuffix("yeogiya.io/") {
                self.isLoaded = true
                GlobalFunction.pushToWebViewController(title: "어디서했니", url: url.absoluteString, addfooter: true, webType: .yeogiya)
                decisionHandler(.cancel)
                return
            } else {
                if let getHost = url.host, getHost.contains("yeogiya") {
                    self.webType.setYeogiyaAgent(webView)
                }
                decisionHandler(.allow)
            }
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel) {_ in
            if message.hasPrefix("본인인증실패") {
                GlobalDefine.shared.curNav?.popViewController(animated: true)
            }
            completionHandler()
        })
        
        if self.isViewLoaded && self.view.window != nil {
            self.present(alertController, animated: true, completion: nil)
        } else {
            completionHandler()
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
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
        loadWebView(with: url.absoluteString)
    }
}

extension CashdocWebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        webType.receiveMessage(message, webView: self.webView ?? WKWebView())
    }
}

extension CashdocWebViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y == 0 {
            return
        }
        
        if scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0 {
            GlobalDefine.shared.freeSeg?.scrollDirection(true)
        } else {
            GlobalDefine.shared.freeSeg?.scrollDirection(false)
        }
    }
}

extension WKWebViewConfiguration {
    func includeCustomCookies(urlString: String, cookies: [HTTPCookie], completion: @escaping  () -> Void) {
        var dataStore = WKWebsiteDataStore.default()

        if urlString.contains("community.cashdoc.me") || urlString.contains("community-test.cashdoc.me") {
            dataStore = WKWebsiteDataStore.nonPersistent()
        }
        
        let waitGroup = DispatchGroup()
        
        for cookie in cookies {
            waitGroup.enter()
            dataStore.httpCookieStore.setCookie(cookie) { waitGroup.leave() }
        }
        
        waitGroup.notify(queue: DispatchQueue.main) {
            self.websiteDataStore = dataStore
            completion()
        }
    }
}
