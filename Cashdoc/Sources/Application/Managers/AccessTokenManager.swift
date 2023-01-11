//
//  AccessTokenManager.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum AccessTokenManager {
    static var accessToken: String {
        return UserDefaults.standard.string(forKey: UserDefaultKey.kAccessToken.rawValue) ?? ""
    }
    
    static func setAccessToken(with token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultKey.kAccessToken.rawValue)
    }
}
