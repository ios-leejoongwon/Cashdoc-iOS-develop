//
//  WebType.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/12/02.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import WebKit
import SafariServices

enum WebType: Equatable {
    case normal
    case yeogiya
    case terms
    
    var params: [String] {
        switch self {
        case .yeogiya:
            return [
                "getNewHospitalSubscription",
                "getUserId",
                "getAppVersion",
                "sendUrl" // 외부 결제용
            ]
        default:
            return ["cashdocHandler"]
        }
    }
    
    var title: String {
        switch self {
        case .yeogiya:
            return "병원 이벤트"
        default:
            return "캐시닥"
        }
    }
    
    func makeBody(url: URL) -> [String: String] {
        switch self {
        case .yeogiya:
            return [:]
        default:
            let getHost = url.host ?? ""
            if url.absoluteString.hasPrefix(API.HOME_WEB_URL) || getHost.contains(API.COMMUNITY_WEB_URL) {
                return ["cashdocAccessToken": AccessTokenManager.accessToken,
                        "cashdocDevice": "ios",
                        "cashdocAdvId": GlobalFunction.getDeviceID(),
                        "cashdocAppReview": "\(UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue))",
                        "cashdocUserAppVersion": getAppVersion()]
            } else {
                return [:]
            }
        }
    }
    
    func userContents(_ target: CashdocWebViewController) -> WKUserContentController {
        let contentController = WKUserContentController()

        params.forEach {
            contentController.add(target, name: $0)
        }
        
        return contentController
    }
    
    func receiveMessage(_ message: WKScriptMessage, webView: WKWebView) {
        
            Log.al("message.name = \(message.name)")
        switch message.name {
        case "getNewHospitalSubscription": // 어디서했니
            sendSubscriptionData(webView)
        case "getUserId": // 어디서했니
            sendId(webView)
        case "getAppVersion": // 어디서했니
            sendAppVersion(webView)
        case "sendUrl":
            if let url = message.body as? String {
                guard let mainSegVC = GlobalDefine.shared.mainSeg else { return }
                guard let openURL = URL(string: url) else {
                    let urlEncodeParam = "\"%<>[\\]^`{|} "
                    let allowedQueryParamAndKey = NSCharacterSet(charactersIn: urlEncodeParam).inverted
                    let encodedString = url.addingPercentEncoding(withAllowedCharacters: allowedQueryParamAndKey) ?? ""
                    Log.al("encodedString : \(encodedString)")
                    guard let encodedOpenURL = URL(string: encodedString) else {return}
                    let controller = SFSafariViewController(url: encodedOpenURL)
                    controller.setTintColor()
                    mainSegVC.present(controller, animated: true, completion: nil)
                    Log.al("인코딩 필요함")
                    return
                }
                Log.al("인코딩 안함")
                let controller = SFSafariViewController(url: openURL)
                controller.setTintColor()
                mainSegVC.present(controller, animated: true, completion: nil)
            }
        default:
            return
        }
    }
    
    func removeScriptMessageHandler(_ webView: WKWebView?) {
        params.forEach {
            webView?.configuration.userContentController.removeScriptMessageHandler(forName: $0)
        }
    }
}

// 어디서했니 전용 funcs
extension WebType {
    /*
     * 알림 구독 정보를 보냄. by.al
     */
    func sendSubscriptionData(_ webView: WKWebView) {
        Log.al("sendSubscriptionData")
        
        var isNoti = "off"
        if let isOn = UserDefaults.standard.object(forKey: UserDefaultKey.kIsOnYeogiya.rawValue) as? Bool {
            if isOn {
                isNoti = "on"
            }
        }
        
        let newHospitalSubscription = String(format: "setNewHospitalSubscription('%@')", isNoti)
        
        webView.evaluateJavaScript(newHospitalSubscription) { (result, error) in
            if let result = result {
                Log.al("result = \(result)")
            }
            if let error = error {
                Log.al("error = \(error)")
            }
        }
    }
    
    func sendId(_ webView: WKWebView) {
        Log.al("sendId")
        
        guard let userId = UserManager.shared.userModel?.id else { return }
        let sendId = String(format: "setUserId('%@')", userId)
        
        webView.evaluateJavaScript(sendId) { (result, error) in
            if let result = result {
                Log.al("result = \(result)")
            }
            if let error = error {
                Log.al("error = \(error)")
            }
        }
    }
    
    func sendAppVersion(_ webView: WKWebView) {
        Log.al("sendAppVersion")
        
        let sendId = String(format: "setAppVersion('%@')", getAppVersion())
        
        webView.evaluateJavaScript(sendId) { (result, error) in
            if let result = result {
                Log.al("result = \(result)")
            }
            if let error = error {
                Log.al("error = \(error)")
            }
        }
    }
    
    func setYeogiyaAgent(_ webView: WKWebView) {
        webView.evaluateJavaScript("navigator.userAgent") { (result, _) in
            if let originUserAgent = result as? String {
                Log.al("originUserAgent = \(originUserAgent)")
                let agent = originUserAgent+" IOS_YEOGIYA_WEBVIEW"
                webView.customUserAgent = agent
                
            }
            
        }
    }
}
