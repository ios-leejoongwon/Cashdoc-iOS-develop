//
//  AppDelegate.swift
//  Cashdoc
//
//  Created by DongHeeKang on 13/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore
import FirebaseDynamicLinks
import FirebaseCrashlytics 

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 첫진입시에 크래시 나는걸 대비하기위해 userID만 먼저 넣는다
        FirebaseApp.configure()
        if let getCode = UserDefaults.standard.string(forKey: UserDefaultKey.kSaveRecommCode.rawValue) {
            Crashlytics.crashlytics().setUserID(getCode)
        }
//        ExelBid.sharedInstance().ebAppId = Exelbid_APPID
        AppConfiguration.setConfiguration(appDelegate: self, application: application, launchOptions: launchOptions)
        AppNavigator().start(in: self)
        
        // 푸시로 앱 실행했는지 체크
        if let notiOption = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject], notiOption["aps"] != nil {
            GlobalDefine.shared.isPossibleShowPopup = false
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        GlobalFunction.CrashLog(string: "applicationDidEnterBackground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        GlobalFunction.CrashLog(string: "applicationDidBecomeActive")
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 가계부쪽 재진입시에 보여줌
        if let consumeVC = GlobalDefine.shared.curNav?.viewControllers.first as? ConsumeViewController {
            consumeVC.linkAfterVC.didBecomeActive()
        }
        
        // 메인쪽 걸음수 리플래시
        if GlobalDefine.shared.curNav?.viewControllers.count == 1 {
            GlobalDefine.shared.mainHome?.requestRefresh()
        }
    }
}
