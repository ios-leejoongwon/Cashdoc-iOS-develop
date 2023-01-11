//
//  MedicJoinListModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class MedicJoinListModel: SwiftyJSONRealmObject {
    dynamic var JINDSGB: String = ""
    dynamic var JINDSNM: String = ""
    dynamic var JINDSBIRTH: String = ""
    dynamic var JINMEDICALNM: String = ""
    dynamic var JINDATE: String = ""
    dynamic var JINTYPE: String = ""
    dynamic var JINBANGMOONNUM: String = ""
    dynamic var JINCHURBANGNUM: String = ""
    dynamic var JINTUYAKNUM: String = ""
    dynamic var JINDSAMT: String = ""
    dynamic var JINGDAMT: String = ""
    dynamic var IDENTYTY: String = ""

    override static func primaryKey() -> String? {
        return "IDENTYTY"
    }
    
    convenience required init(json: JSON) {
        self.init()
        JINDSGB = json["JINDSGB"].stringValue
        JINDSNM = json["JINDSNM"].stringValue
        JINDSBIRTH = json["JINDSBIRTH"].stringValue
        JINMEDICALNM = json["JINMEDICALNM"].stringValue
        JINDATE = json["JINDATE"].stringValue
        JINTYPE = json["JINTYPE"].stringValue
        JINBANGMOONNUM = json["JINBANGMOONNUM"].stringValue
        JINCHURBANGNUM = json["JINCHURBANGNUM"].stringValue
        JINTUYAKNUM = json["JINTUYAKNUM"].stringValue
        JINDSAMT = json["JINDSAMT"].stringValue
        JINGDAMT = json["JINGDAMT"].stringValue
        IDENTYTY = json["JINDATE"].stringValue + json["JINMEDICALNM"].stringValue
    }
}
