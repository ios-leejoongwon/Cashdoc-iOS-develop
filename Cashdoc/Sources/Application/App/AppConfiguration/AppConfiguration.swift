//
//  AppConfiguration.swift
//  Cashdoc
//
//  Created by DongHeeKang on 17/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

import FirebaseCrashlytics

enum AppConfiguration: CaseIterable {
    case firebase
    case reachability
    case smartAIB
    case db
    case audio
    case ui
    case ad
}

extension AppConfiguration {
    // MARK: - Properties
    
    private var appConfigurable: AppConfigurable.Type {
        switch self {
        case .firebase:
            return FirebaseConfiguration.self
        case .reachability:
            return ReachabilityConfiguration.self
        case .smartAIB:
            return SmartAIBConfiguration.self
        case .db:
            return DBConfiguration.self
        case .audio:
            return AudioConfiguration.self
        case .ui:
            return UIConfiguration.self
        case .ad:
            return ADConfiguration.self
        }
    }
    
    // MARK: - Static methods
    
    static func setConfiguration(filter: [AppConfiguration] = AppConfiguration.allCases,
                                 appDelegate: AppDelegate,
                                 application: UIApplication,
                                 launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        AppConfiguration.allCases
            .filter {filter.contains($0)}
            .forEach { (configuration) in
                configuration
                    .appConfigurable.init()
                    .configuration(appDelegate: appDelegate,
                                   application: application,
                                   launchOptions: launchOptions)
        }
    }
    
    // MARK: - Private methods
    
    private func configuration(appDelegate: AppDelegate,
                               application: UIApplication,
                               launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        appConfigurable.init()
            .configuration(appDelegate: appDelegate,
                           application: application,
                           launchOptions: launchOptions)
    }
}
