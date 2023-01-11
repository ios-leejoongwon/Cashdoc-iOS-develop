//
//  Game5MinutesVC.swift
//  Cashwalk
//
//  Created by lovelycat on 17/01/2020.
//  Copyright © 2020 Cashwalk, Inc. All rights reserved.
//

import WebKit
import Foundation
import SnapKit
import Then
import AdSupport
import Alamofire

class Game5MinutesVC: UIViewController {
    // MARK: - Properties
    
    // var itemInfo: IndicatorInfo = IndicatorInfo(title: "5분게임")
    
    private weak var indicatorView: UIActivityIndicatorView!
    private weak var webView: WKWebView!
    
    // MARK: - Overridden: BaseViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setProperties()
        //        clearWebviewCache()
        self.loadGame5m()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
    }
    // MARK: - Overridden: BaseViewController - Protocol
    
    func setupView() {
        webView = WKWebView().then {
            $0.contentMode = .scaleAspectFit
            $0.isOpaque = false
            $0.backgroundColor = .clear
            $0.allowsBackForwardNavigationGestures = true
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.left.right.equalToSuperview()
                m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            }
        }
        indicatorView = UIActivityIndicatorView().then {
            $0.style = .gray
            $0.startAnimating()
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.centerX.equalToSuperview()
                m.centerY.equalToSuperview()
            }
        }
    }
    
    private func clearWebviewCache() {
        if let websiteDataType = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeCookies]) as? Set<String> {
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataType, modifiedSince: Date()) {}
        }
    }
    
    private func gameUrlWithParam(gameUrl: String) -> String {
        var url = "\(gameUrl)"
        let type = MinConstants.GAME_TYPE
        
        Log.i("gameUrlWithParam 11111 :  \(type)")
        
        guard let moviGameId = UserDefaults.standard.string(forKey: "kIdOfMoviGame") else {
            
            self.getGameId { [weak self] (result) in
                guard let self = self else {return}

                UserDefaults.standard.set(result, forKey: "kIdOfMoviGame")
                var param = [String: Any]()
                param["cashwalk_user_id"] = result
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
                param["country"] = ""
                param["countryCode"] = ""
                param["maker"] = "Apple"
                param["os"] = getOSVersion()
                param["app"] = getAppVersion()
                param["game"] = ""
                param["season"] = ""
                param["game_no"] = ""
                param["type"] = type
                param.enumerated().forEach { (_, element) in
                    url.append("&\(element.key)=\(element.value)")
                    Log.i("param : \(param), emlement : \(element.key), \(element.value), url : \(url)")
                }
                
                Log.i("gameUrlWithParam 33333 : \(url)")
                guard let sharedCodeUrl = URL(string: url) else {return}
                let gameRequest = URLRequest(url: sharedCodeUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                self.webView.load(gameRequest)
            }
            return url
        }
        
        var param = [String: Any]()
        param["cashwalk_user_id"] = moviGameId
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
        param["country"] = ""
        param["countryCode"] = ""
        param["maker"] = "Apple"
        param["os"] = getOSVersion()
        param["app"] = getAppVersion()
        param["game"] = ""
        param["season"] = ""
        param["game_no"] = ""
        param["type"] = type
        param.enumerated().forEach { (_, element) in
            url.append("&\(element.key)=\(element.value)")
        }
        Log.i("gameUrlWithParam 44444 : \(url)")
        return url
    }
    
    private func loadGame5m() {
        
        var url = "\(MinConstants.GAME_URL)?"
        url = gameUrlWithParam(gameUrl: url)
        Log.i(url)
        
        if UserDefaults.standard.string(forKey: "kIdOfMoviGame") != nil {
            guard let sharedCodeUrl = URL(string: url) else {return}
            Log.i("sharedCodeUrl : \(sharedCodeUrl)")
            let gameRequest = URLRequest(url: sharedCodeUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
            webView.load(gameRequest)
        } else {
            // 저장된 게임 아이디가 없으면 서버통신 해야됨
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0, execute: { [weak self] in
                guard let self = self else {return}
                url = self.gameUrlWithParam(gameUrl: url)
                Log.i(url)
                guard let sharedCodeUrl = URL(string: url) else {return}
                let gameRequest = URLRequest(url: sharedCodeUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
                self.webView.load(gameRequest)
            })
        }
    }
    
    private func getGameId(completion: @escaping (String) -> Void) {
        #if CASWHALK
        let url = "\(API_URL)game/id?access_token=\(CashwalkAccessToken)"
        return dataTask(url) { (error, result) in
            guard let result = result else {
                completion(error, nil)
                return
            }
            
            completion(error, result["result"].string)
        }
        #else
        // 캐시닥엔 랭킹이 일단 빠져서 gameID 제외함
//        let provider = CashdocProvider<MinService>()
//        provider.CDRequest(.getGameId) { (json) in
//            completion(json["result"].stringValue)
//        }
        completion("")
        #endif
    }
    
    private func setProperties() {
        title = "5분게임"
        view.backgroundColor = UIColor.white
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    private func showGameWebVC(gameUrl: String, game: String? = nil, season: String? = nil) {
        func presentGame(controller: NewGameWebVC) {
            DispatchQueue.main.async {
                controller.delegate = self
                GlobalDefine.shared.curNav?.present(controller, animated: true, completion: nil)
            }
        }
        
        guard let moviGameId = UserDefaults.standard.string(forKey: "kIdOfMoviGame") else {
            self.getGameId { (result) in
                UserDefaults.standard.set(result, forKey: "kIdOfMoviGame")
                let controller = NewGameWebVC(gameId: result, gameUrl: gameUrl, game: game, season: season)
                controller.modalPresentationStyle = .fullScreen
                presentGame(controller: controller)
            }
            return
        }
        Log.i("moviGameId : \(moviGameId)")
        let controller = NewGameWebVC(gameId: moviGameId, gameUrl: gameUrl, game: game, season: season)
        controller.modalPresentationStyle = .fullScreen
        presentGame(controller: controller)
    }
}

// MARK: - WKNavigationDelegate

extension Game5MinutesVC: WKNavigationDelegate, WKUIDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        indicatorView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url?.absoluteString else { return }
        Log.i("웹뷰 url : \(url)")
        
        guard !url.contains("\(MinConstants.GAME_URL)") else {
            decisionHandler(.allow)
            return
        }
        
        #if CASHDOC
        if url.hasPrefix("cdapp") {
            DeepLinks.openSchemeURL(urlstring: url, gotoMain: false)
            decisionHandler(.cancel)
            return
        }
        #endif
        
        if let url = navigationAction.request.url, url.scheme == "cashwalk" {
            guard !url.absoluteString.contains("game") else {
                let urlGame = URL(string: url.absoluteString)
                if let tmpUrl = urlGame?.absoluteURL {
                    if let link = tmpUrl.value(for: "link") { // 모비게임 URL
                        Log.i("5분 게임 스키마 테스트 : link : \(link)")
                        
                        var replacingString = link.replacingOccurrences(of: "{_cpf_}", with: "?")
                        replacingString = replacingString.replacingOccurrences(of: "{_cp_}", with: "&")
                        replacingString = replacingString.replacingOccurrences(of: "#", with: "")
                        replacingString = replacingString.replacingOccurrences(of: " ", with: "+")
                        Log.i("replacingString: \(replacingString)")
                        guard URL(string: replacingString) != nil else {
                            Log.i("url 주소 비정상 : \(replacingString)")
                            decisionHandler(.cancel)
                            return}
                        if url.absoluteString.hasSuffix("ad_start") {
                            Log.i("모비게임 초기화 해주기 ad_start")
                            MediactionManager.shared().firstLoadAds(MOVI)
                        }
                        if url.absoluteString.hasSuffix("ad_start_gamen") {
                            Log.i("게임엔 초기화 해주기 ad_start")
                            MediactionManager.shared().firstLoadAds(GAMEN)
                        }
                        showGameWebVC(gameUrl: String(replacingString))
                    }
                }
                decisionHandler(.cancel)
                return
            }
            guard !url.absoluteString.contains("roulette") else {
                #if CASHWALK
                AppGlobalFunc.openLuckyCash(self)
                #else
                GlobalFunction.openLuckyCash(isPush: false)
                #endif
                decisionHandler(.cancel)
                return
            }
            decisionHandler(.allow)
        } else {
            decisionHandler(.allow)
            return
        }
        
    }
    
}

// MARK: - QuizAnswerPopupViewDelegate

extension Game5MinutesVC: NewGameWebVCDelegate {
    func gameWebVCClose(_ viewController: NewGameWebVC) {
        Log.i("게임 종료 시 광고 close Delegate")
    }
}
