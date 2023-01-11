//
//  CheckupListModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class CheckupListModel: SwiftyJSONRealmObject {
    dynamic var CHECKUPKIND: String = ""
    dynamic var CHECKUPYEAR: String = ""
    dynamic var CHECKUPDATE: String = ""
    dynamic var CHECKUPORGAN: String = ""
    dynamic var CHECKUPOPINION: String = ""
    dynamic var IDENTYTY: String = ""

    override static func primaryKey() -> String? {
        return "IDENTYTY"
    }
    
    convenience required init(json: JSON) {
        self.init()
        CHECKUPKIND = json["CHECKUPKIND"].stringValue
        CHECKUPYEAR = json["CHECKUPYEAR"].stringValue
        CHECKUPDATE = json["CHECKUPDATE"].stringValue
        CHECKUPORGAN = json["CHECKUPORGAN"].stringValue
        CHECKUPOPINION = json["CHECKUPOPINION"].stringValue
        IDENTYTY = json["CHECKUPDATE"].stringValue + json["CHECKUPORGAN"].stringValue + json["CHECKUPKIND"].stringValue
    }
}
