//
//  AppConfigurable.swift
//  Cashdoc
//
//  Created by DongHeeKang on 17/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

protocol AppConfigurable {
    init()
    func configuration(appDelegate: AppDelegate,
                       application: UIApplication,
                       launchOptions: [UIApplication.LaunchOptionsKey: Any]?)
}
