//
//  AppPushMessages.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/30.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Firebase
import FirebaseMessaging
import FirebaseDynamicLinks
import KakaoSDKAuth

extension AppDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().subscribe(toTopic: "cashdoc_background_ios")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Log.i("Recived: \(userInfo)")
        
        guard let aps = userInfo["aps"] as? [AnyHashable: Any], aps["alert"] == nil else {
            return
        }
        UserNotificationManager.shared.addNotificationFromFCM(data: userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [AnyHashable: Any], aps["alert"] == nil else {
            completionHandler(.noData)
            return
        }
        UserNotificationManager.shared.addNotificationFromFCM(data: userInfo)
        completionHandler(.newData)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        Log.al("url = \(url)")
        // 다이나믹링크에서 내려오는 값은 무시하도록 한다
        if url.scheme == "com.cashwalk.cashdoc" {
            return true
        }
        
        if GlobalDefine.shared.mainSeg != nil { 
            GlobalDefine.shared.isPossibleShowPopup = false
            DeepLinks.openSchemeURL(urlstring: url.absoluteString, gotoMain: true)
        } else {
            UserManager.shared.isPushDeepLink = url.absoluteString
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
         
        GlobalDefine.shared.isPossibleShowPopup = false
        guard let getURL = userActivity.webpageURL else { return false }
        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(getURL) { (dynamiclink, _) in
            if let linkURL = dynamiclink?.url { Log.al("linkURL = \(linkURL)")
                if linkURL.host == "cashdoc.me" || linkURL.host?.contains("yeogiya") ?? false {
                    if GlobalDefine.shared.mainSeg != nil {
                        DeepLinks.openSchemeURL(urlstring: linkURL.absoluteString, gotoMain: true)
                    } else {
                        UserManager.shared.isPushDeepLink = linkURL.absoluteString
                    }
                } else {
                    // cashdocme가 아닌경우 외부브라우져로 열어준다
                    GlobalFunction.pushToSafariOutside(url: linkURL.absoluteString)
                }
            }
        }
        return handled
    }
}

// MARK: - UNUserNotificationCenter
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Log.i("Recived: \(userInfo)")
        completionHandler(.newData)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        Log.i(notification.request)
        UserManager.shared.getUser()
        completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        Log.i("\(response.notification.request.content), \(response.notification.request.content.body)")
        
        let state = UIApplication.shared.applicationState
        UserManager.shared.getUser { (error) in
            if error == nil {
                if state == .active { // 앱이 
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
                        if let deepLink = response.notification.request.content.userInfo["deepLink"] as? String {
                            if GlobalDefine.shared.mainSeg != nil {
                                DeepLinks.openSchemeURL(urlstring: deepLink, gotoMain: true)
                            } else {
                                UserManager.shared.isPushDeepLink = deepLink
                            }
                        }
                        
                        switch response.notification.request.identifier {
                        case UserDefaultKey.kPointUpdatedNotification.rawValue:
                            UserDefaults.standard.set(0, forKey: UserDefaultKey.kPointUpdatedNotification.rawValue)
                        case NotificationIdentifier.DailyNotification1930.rawValue:
                            if let getMainSeg = GlobalDefine.shared.mainSeg {
                                getMainSeg.changeSegment(.가계부)
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let consumeVC = getMainSeg.children[safe: 1] as? ConsumeViewController {
                                        consumeVC.linkAfterVC.refresh()
                                    }
//                                }
                            }
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            let dateStr = formatter.string(from: Date())
                            if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
                                GlobalFunction.FirLog(string: "가계부_소비내역_Push_클릭", dateStr)
                            }
                        case NotificationIdentifier.DailyRetention1200.rawValue:
                            GlobalFunction.openLuckyCash(isPush: true)
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            let dateStr = formatter.string(from: Date())
                            GlobalFunction.FirLog(string: "가계부_리텐션_Push_클릭", dateStr)
                        default:
                            break
                        }
                    })
                } else {
                    GlobalDefine.shared.isPossibleShowPopup = false
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5, execute: {
                        
                        if let deepLink = response.notification.request.content.userInfo["deepLink"] as? String {
                            if GlobalDefine.shared.mainSeg != nil {
                                DeepLinks.openSchemeURL(urlstring: deepLink, gotoMain: true)
                            } else {
                                UserManager.shared.isPushDeepLink = deepLink
                            }
                        }
                        
                        switch response.notification.request.identifier {
                        case UserDefaultKey.kPointUpdatedNotification.rawValue:
                            UserDefaults.standard.set(0, forKey: UserDefaultKey.kPointUpdatedNotification.rawValue)
                        case NotificationIdentifier.DailyNotification1930.rawValue:
                            if let getMainSeg = GlobalDefine.shared.mainSeg {
                                getMainSeg.changeSegment(.가계부)
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    if let consumeVC = getMainSeg.children[safe: 1] as? ConsumeViewController {
                                        consumeVC.linkAfterVC.refresh()
                                    }
//                                }
                            }
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            let dateStr = formatter.string(from: Date())
                            if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
                                GlobalFunction.FirLog(string: "가계부_소비내역_Push_클릭", dateStr)
                            }
                        case NotificationIdentifier.DailyRetention1200.rawValue:
                            GlobalFunction.openLuckyCash(isPush: true)
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            let dateStr = formatter.string(from: Date())
                            GlobalFunction.FirLog(string: "가계부_리텐션_Push_클릭", dateStr)
                        default:
                            break
                        }
                    })
                }
            }
            completionHandler()
        }
    }
}

// MARK: - FIRMessagingDelegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        #if DEBUG
        Log.i("FCMToken: \(fcmToken ?? "")")
        Log.i("AccessToken: \(AccessTokenManager.accessToken)")
        #endif
        if let getFcmToken = fcmToken {
            UserManager.shared.uploadFCMToken(getFcmToken)
        }
    }
}
