//
//  InsuranRealmManager.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

final class InsuranRealmManager: RealmManageable {
    var isUseInMemory: Bool {
        return false
    }
    
    var schemaVersion: UInt64 {
        return 4
    }
    
    var fileName: String {
        return "insuran"
    }
    
    var objectTypes: [Object.Type]? {
        return [InsuranceJListModel.self,
                InsuranceJDetail.self,
                InsuranceSListModel.self,
                InsuranceSDetail.self
        ]
    }
    
}
