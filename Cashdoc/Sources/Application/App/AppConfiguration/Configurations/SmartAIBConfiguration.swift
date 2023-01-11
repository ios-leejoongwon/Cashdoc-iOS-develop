//
//  SmartAIBConfiguration.swift
//  Cashdoc
//
//  Created by Oh Sangho on 19/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

struct SmartAIBConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: SmartAIBManager.shared.timeOut)
    }
}
