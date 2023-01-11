//
//  Manual.swift
//  Cashdoc
//
//  Created by Taejune Jung on 13/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift
import SwiftyJSON

@objcMembers
class ManualConsumeList: Object {
    
    // MARK: - Properties
    
    dynamic var identity: String = ""
    dynamic var category: String = ""
    dynamic var subCategory: String = ""
    dynamic var expedient: String = ""
    dynamic var contents: String = ""
    dynamic var income: Int = 0
    dynamic var outgoing: Int = 0
    dynamic var isTouchEnabled: Bool = false
    dynamic var isDeleted: Bool = false
    dynamic var touchCount: Int = 0
    dynamic var date: Date = .init()
    dynamic var time: String = ""
    dynamic var memo: String = ""
    dynamic var gb: String = ""
    
    // MARK: - Con(De)structor
    
    required convenience public init(json: JSON) {

        self.init()
        
        category = json["category"].stringValue
        subCategory = json["subCategory"].stringValue
        expedient = json["expedient"].stringValue
        contents = json["contents"].stringValue
        income = json["income"].stringValue.toInt
        outgoing = json["outgoing"].stringValue.toInt
        isTouchEnabled = json["isTouchEnabled"].boolValue
        isDeleted = json["isDeleted"].boolValue
        touchCount = json["touchCount"].intValue
        if let dateString = json["date"].string {
            date = dateString.simpleDateFormat("yyyyMMdd")
        }
        time = json["time"].stringValue
        memo = json["memo"].stringValue
        gb = json["gb"].stringValue
        
        identity = String(format: "%@_%@_%@", date.simpleDateFormat("yyyyMMdd"), time, contents)

    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
}
