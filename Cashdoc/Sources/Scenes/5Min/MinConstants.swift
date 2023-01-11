//
//  5MinConstants.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

enum MinConstants {
    static var GAME_URL: String {
        #if CASHWALK
        let debugAPIServerRawvalue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServerRawValue)
        let serverType = APIServerType(rawValue: debugAPIServerRawvalue ?? "Production")
        #else
        let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
        let serverType = APIServer(rawValue: rawValue ?? "Production")
        #endif
        
        switch serverType {
        case .production:
            return "https://game.cashwalk.io"
        case .qa:
            return "https://qa-game.cashwalk.io"
        case .test, .none:
            return "https://test-game.cashwalk.io/"
        }
    }
    
    static var GAME_TYPE: String {
        #if CASHWALK
        let debugAPIServerRawvalue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServerRawValue)
        let serverType = APIServerType(rawValue: debugAPIServerRawvalue ?? "Production")
        #else
        let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue)
        let serverType = APIServer(rawValue: rawValue ?? "Production")
        #endif
        
        switch serverType {
        case .production, .qa:
            return "product"
        case .test, .none:
            return "dev"
        }
    }
}
