//
//  EtcPropertyRealmManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

final class EtcPropertyRealmManager: RealmManageable {
    
    var isUseInMemory: Bool {
        return false
    }
    
    var schemaVersion: UInt64 {
        return 1
    }
    
    var fileName: String {
        return "etcProperty"
    }
    
    var objectTypes: [Object.Type]? {
        return [EtcPropertyList.self]
    }
    
}
