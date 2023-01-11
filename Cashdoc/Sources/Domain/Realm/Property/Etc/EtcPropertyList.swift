//
//  EtcPropertyList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class EtcPropertyList: Object {
    
    // MARK: - Properties
    
    dynamic var id: String = ""
    dynamic var nickName: String = ""
    dynamic var balance: Int = 0
    dynamic var memo: String = ""
    
    override class func primaryKey() -> String? {
        return "id"
    }
}
