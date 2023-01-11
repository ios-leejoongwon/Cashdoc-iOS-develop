//
//  RemoteConfigManager.swift
//  Cashdoc
//
//  Created by Taejune Jung on 28/02/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import FirebaseRemoteConfig

final class RemoteConfigManager {
    
    // MARK: - Constants
    
    static let shared = RemoteConfigManager()
    
    // MARK: - Properties
    
    let remoteConfig = RemoteConfig.remoteConfig()
    
    // MARK: - Internal methods
    
    func fetchConfig() {
        #if DEBUG
        remoteConfig.configSettings = RemoteConfigSettings()
        let expirationDuration = 0
        #else
        let expirationDuration = 3600
        #endif
        
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) in
            guard error == nil, status == .success else { return }
            self.remoteConfig.activate { (isUpdate, error) in
                guard error == nil else { return }
                Log.osh("무슨 bool값이야?? : \(isUpdate)")
            }
            
        }
    }
    
    func getBool(from key: RemoteConfigKey) -> Bool? {
        return remoteConfig.configValue(forKey: key.rawValue).boolValue
    }
    
    func getString(from key: RemoteConfigKey) -> String? {
        return remoteConfig.configValue(forKey: key.rawValue).stringValue
    }
    
    func getNumber(from key: RemoteConfigKey) -> NSNumber? {
        return remoteConfig.configValue(forKey: key.rawValue).numberValue
    }
    
    func getData(from key: RemoteConfigKey) -> Data? {
        return remoteConfig.configValue(forKey: key.rawValue).dataValue
    }
}
