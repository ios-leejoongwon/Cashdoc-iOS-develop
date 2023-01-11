//
//  MedicHistoryRealmManager.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

final class MedicHistoryRealmManager: RealmManageable {
    var isUseInMemory: Bool {
        return false
    }
    
    var schemaVersion: UInt64 {
        return 1
    }
    
    var fileName: String {
        return "medicHistory"
    }
    
    var objectTypes: [Object.Type]? {
        return [MedicIneListModel.self,
                MedicIneDetail.self,
                MedicIneDrugDetail.self,
                MedicIneIngrediList.self,
                MedicIneKpicList.self,
                MedicIneDurList.self,
                MedicJoinListModel.self
        ]
    }
}
