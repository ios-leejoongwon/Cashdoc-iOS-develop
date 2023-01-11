//
//  UIConfiguration.swift
//  Cashdoc
//
//  Created by Oh Sangho on 01/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct UIConfiguration: AppConfigurable {
    func configuration(appDelegate: AppDelegate,
                       application: UIApplication,
                       launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        UIView.appearance().isExclusiveTouch = true
        UIButton.appearance().isExclusiveTouch = true
    }
}
