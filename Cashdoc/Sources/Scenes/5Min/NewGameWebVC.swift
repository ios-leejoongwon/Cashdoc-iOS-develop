//
//  NewGameWebVC.swift
//  Cashwalk
//
//  Created by lovelycat on 2020/06/05.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import AdSupport
import WebKit
import Firebase
import FirebaseAnalytics
import CoreTelephony
import Then

protocol NewGameWebVCDelegate: NSObjectProtocol {
    func gameWebVCClose(_ viewController: NewGameWebVC)
}

final class NewGameWebVC: UIViewController {
    
    weak var delegate: NewGameWebVCDelegate?
    
    // MARK: - Constants
    
    struct Const {
        static let back = "cashwalk://back"
        static let coin = "cashwalk://coin"
        static let invite = "cashwalk://invite"
        static let mailTo = "mailto:cashwalk.games@gmail.com"
        static let ad_start = "cashwalk://ad_start"
        static let ad_start_gamen = "cashwalk://ad_start_gamen"
        static let ad_popup = "cashwalk://ad_popup"
        static let ad_video = "cashwalk://ad_video"
        static let ad_popup_gamen = "cashwalk://ad_popup_gamen"
        static let ad_video_gamen = "cashwalk://ad_video_gamen"
    }
    
    // MARK: - Properties
    
    var gameId: String = ""
    var gameUrl: String = ""
    var game: String?
    var season: String?
    var gameType: MoviGame?
    
    private var isWebViewLoaded = false
    private weak var mainTabBC: UITabBarController?
    
    // MARK: - UI Components
    
    private let statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 20)).then {
        $0.backgroundColor = UIColor.fromRGB(255, 210, 0)
        $0.isHidden = true
    }
    private let webViewConfiguration = WKWebViewConfiguration().then {
        $0.allowsInlineMediaPlayback = true
        if #available(iOS 10.0, *) {
            $0.mediaTypesRequiringUserActionForPlayback = []
        } else {
            $0.requiresUserActionForMediaPlayback = false
        }
    }
    
    private var webView: WKWebView!
    // MARK: - Con(De)structor
    
    init(gameId: String, gameUrl: String, game: String? = nil, season: String? = nil, gameType: MoviGame? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        self.gameId = gameId
        self.gameUrl = gameUrl
        self.game = game
        self.season = season
        self.gameType = gameType
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MediactionManager.shared().delegate = self
        setProperties()
        view.addSubview(webView)
        #if CASHWALK
        view.insertSubview(statusBarView, aboveSubview: view)
        #endif
        layout()
        //        clearWebviewCache()
        webLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AnalyticsLog("game_main")
        navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - Private methods
    
    private func gameUrlWithParam(gameUrl: String) -> String {
        var url = "\(gameUrl)?cashwalk_user_id=\(gameId)"
        var param = [String: Any]()
        #if CASWHALK
        param["birth"] = UserManager.shared.birth
        param["gender"] = UserManager.shared.gender
        param["model"] = getModelName()
        param["app_name"] = "cashwalk"
        #else
        param["birth"] = ""
        param["gender"] = ""
        param["model"] = UIDevice.current.modelName.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed)
        param["app_name"] = "cashdoc"
        #endif
        param["maker"] = "Apple"
        param["os"] = getOSVersion()
        param["app"] = getAppVersion()
        param["game"] = game
        param["season"] = season
        param["game_no"] = gameType?.rawValue
        param.enumerated().forEach { (_, element) in
            url.append("&\(element.key)=\(element.value)")
        }
        return url
    }
    
    private func isAdUrl(url: String) -> Bool {
        return url.contains("api.exelbid.com/exelbid")
    }
    
    private func isMoviGameUrl(url: String) -> Bool {
        return url.contains("movigame.com") || url.contains("movigamebucket.s3.amazonaws.com")
    }
    
    private func isValidUrlScheme(url: String) -> Bool {
        switch url {
        case Const.back:
            return true
        case Const.coin:
            return true
        case Const.invite:
            return true
        case Const.mailTo:
            return true
        case Const.ad_start, Const.ad_popup, Const.ad_video:
            return true
        case Const.ad_start_gamen, Const.ad_popup_gamen, Const.ad_video_gamen:
            return true
        default:
            guard isAdUrl(url: url) else {return false}
            return true
        }
    }
    
    private func setProperties() {
        title = ""
        view.backgroundColor = UIColor.fromRGB(255, 210, 0)
        webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        mainTabBC = tabBarController
    }
    
    private func clearWebviewCache() {
        // 모든 열어본 페이지에 대한 데이터를 모두 삭제
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), completionHandler: { (records) -> Void in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
                // remove callback
            }
        })
    }
    
    private func showGameDataPopup() {
        guard let presentView = navigationController?.view else {return}
        let gameDataPopup = GameDataPopupView(frame: presentView.bounds)
        presentView.addSubview(gameDataPopup)
    }
    
    private func webLoad() {
        #if CASHWALK
        showLoading()
        #else
        GlobalFunction.CDShowLogoLoadingView()
        #endif
        //        guard let url = URL(string: gameUrlWithParam(gameUrl: gameUrl)) else {return}
        guard let url = URL(string: gameUrl) else {return}
        Log.i(url)
        let gameRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        webView.load(gameRequest)
    }
    
}

// MARK: - Layout

extension NewGameWebVC {
    
    private func layout() {
        webView.snp.makeConstraints { (m) in
            m.left.right.top.bottom.equalToSuperview()
        }
    }
    
}

// MARK: - WKNavigationDelegate

extension NewGameWebVC: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if isWebViewLoaded == false {
            isWebViewLoaded = true
            
            statusBarView.isHidden = false
            #if CASHWALK
            hideLoading()
            #else
            GlobalFunction.CDHideLogoLoadingView()
            #endif
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        guard let url = navigationAction.request.url?.absoluteString, isValidUrlScheme(url: url) else {
            decisionHandler(WKNavigationActionPolicy.allow)
            return
        }
        
        #if CASHDOC
        if url.hasPrefix("cdapp") {
            DeepLinks.openSchemeURL(urlstring: url, gotoMain: false)
            decisionHandler(.cancel)
            return
        }
        #endif
        
        Log.i("모비게임 스킴 url : \(url)")
        switch url {
        case Const.back:
            Log.i("게임 - 튀로")
            DispatchQueue.main.async { [weak self] in
                self?.dismiss(animated: true, completion: nil)
            }
            self.delegate?.gameWebVCClose(self)
        case Const.ad_start:
            Log.i("모비게임 - 초기화")
            MediactionManager.shared().firstLoadAds(MOVI)
        case Const.ad_popup:
            Log.i("모비게임 - 전면광고")
            AnalyticsLog("ad_inventory_movi_popup")
            MediactionManager.shared().start(self, nextVC: nil, adKind: MOVI_POPUP, adType: NONE)
        case Const.ad_video:
            Log.i("모비게임 - 리워드광고")
            AnalyticsLog("ad_inventory_movi_reward")
            MediactionManager.shared().start(self, nextVC: nil, adKind: MOVI_VIDEO, adType: NONE)
        case Const.ad_start_gamen:
            Log.i("게임엔 - 초기화")
            MediactionManager.shared().firstLoadAds(GAMEN)
        case Const.ad_popup_gamen:
            Log.i("게임엔 - 전면광고")
            AnalyticsLog("ad_inventory_gamen_popup")
            MediactionManager.shared().start(self, nextVC: nil, adKind: GAMEN_POPUP, adType: NONE)
        case Const.ad_video_gamen:
            Log.i("게임엔 - 리워드광고")
            AnalyticsLog("ad_inventory_gamen_reward")
            MediactionManager.shared().start(self, nextVC: nil, adKind: GAMEN_VIDEO, adType: NONE)
        case Const.invite:
            #if CASHWALK
            if let inviteEvent = VersionManager.shared.inviteEvent, inviteEvent {
                let controller: UIViewController = InviteEventVC()
                navigationController?.pushViewController(controller, animated: true)
            } else {
                let controller: UIViewController = InviteVC()
                navigationController?.pushViewController(controller, animated: true)
            }
            #else
            #endif
        case Const.mailTo:
            if let mailURL = URL(string: url) {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(mailURL)
                }
            }
        default:
            decisionHandler(.allow)
            return
        }
        
        decisionHandler(WKNavigationActionPolicy.cancel)
    }
    
    func AnalyticsLog(_ event: String) {
        Analytics.logEvent(event, parameters: nil)
    }
}

extension NewGameWebVC: ADMediactionDelegate {
    func ad_finished() {
        webView.evaluateJavaScript("ad_finish()", completionHandler: nil)
    }
}
