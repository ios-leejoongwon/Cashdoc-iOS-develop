//
//  ADConfiguration.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/04/05.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import Appboy_iOS_SDK
import AdPieSDK 

struct ADConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        // 광고모듈 추가
        #if RELEASE
        MediactionManager.shared().initAppwithADSetting(CASHDOC, isRelease: true)
        #else
        MediactionManager.shared().initAppwithADSetting(CASHDOC, isRelease: false, isLoadVideo: false)
        #endif
         
        // Appboy
        Appboy.start(withApiKey: "YOUR-APP-IDENTIFIER-API-KEY", in: application, withLaunchOptions: launchOptions)
        
        // adpid
        AdPieSDK.sharedInstance().initWithMediaId(AdPie_APPID)
    }
}
