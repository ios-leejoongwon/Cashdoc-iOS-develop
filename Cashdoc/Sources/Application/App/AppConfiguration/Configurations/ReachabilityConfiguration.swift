//
//  ReachabilityConfiguration.swift
//  Cashdoc
//
//  Created by DongHeeKang on 19/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Firebase
import Reachability

struct ReachabilityConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate, application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        try? ReachabilityManager.reachability.startNotifier()
    }
}
