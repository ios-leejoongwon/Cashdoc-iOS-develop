//
//  ManualConsumeRealmManager.swift
//  Cashdoc
//
//  Created by Taejune Jung on 13/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

final class ManualConsumeRealmManager: RealmManageable {
    
    var isUseInMemory: Bool {
        return false
    }
    
    var schemaVersion: UInt64 {
        return 2
    }
    
    var fileName: String {
        return "manualConsume"
    }
    
    var objectTypes: [Object.Type]? {
        return [ManualConsumeList.self]
    }
    
}
