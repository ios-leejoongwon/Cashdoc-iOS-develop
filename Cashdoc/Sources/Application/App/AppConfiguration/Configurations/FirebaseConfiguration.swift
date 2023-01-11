//
//  FirebaseConfiguration.swift
//  Cashdoc
//
//  Created by DongHeeKang on 17/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Firebase
import FirebaseCore
import FirebaseMessaging
import KakaoSDKCommon

struct FirebaseConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        Messaging.messaging().delegate = appDelegate
                
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = appDelegate
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        notificationCenter.requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        RemoteConfigManager.shared.fetchConfig()
                        
        // 카카오Init (2.8.3 명칭부터 바뀜)
        KakaoSDK.initSDK(appKey: "1163fb0c1f0a38b8f44b16afd9773f6a")
    }
}
