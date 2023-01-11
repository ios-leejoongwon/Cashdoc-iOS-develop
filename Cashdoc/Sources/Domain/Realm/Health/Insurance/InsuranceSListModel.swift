//
//  InsuranceSListModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/11.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class InsuranceSListModel: SwiftyJSONRealmObject {
    dynamic var HOISAMYUNG: String = ""
    dynamic var SANGPUMMYUNG: String = ""
    dynamic var JEUNGGWONBUNHO: String = ""
    dynamic var GYEYAKSANGTAE: String = ""
    dynamic var PIBOHUMJA: String = ""
    dynamic var IDENTYTY: String = ""
    dynamic var NAPIPSANGSE = List<InsuranceSDetail>()
        
    override static func primaryKey() -> String? {
        return "IDENTYTY"
    }
    
    convenience required init(json: JSON) {
        self.init()
        HOISAMYUNG = json["HOISAMYUNG"].stringValue
        SANGPUMMYUNG = json["SANGPUMMYUNG"].stringValue
        JEUNGGWONBUNHO = json["JEUNGGWONBUNHO"].stringValue
        GYEYAKSANGTAE = json["GYEYAKSANGTAE"].stringValue
        IDENTYTY = json["SANGPUMMYUNG"].stringValue + json["JEUNGGWONBUNHO"].stringValue
        NAPIPSANGSE = SwiftyJSONRealmObject.createList(ofType: InsuranceSDetail.self, fromJson: json["NAPIPSANGSE"])
        
        if let firstModel = NAPIPSANGSE.first {
            PIBOHUMJA = firstModel.PIBOHUMJA
        }
    }
}

@objcMembers
class InsuranceSDetail: SwiftyJSONRealmObject {
    dynamic var BOJANGJONGRYOIL: String = ""
    dynamic var BOJANGSIJAKIL: String = ""
    dynamic var BOJANGGEUMAEK: String = ""
    dynamic var PIBOHUMJA: String = ""
    dynamic var SILSONGUBUN: String = ""
    dynamic var BOJANGMYUNG: String = ""

    convenience required init(json: JSON) {
        self.init()
        BOJANGJONGRYOIL = json["BOJANGJONGRYOIL"].stringValue
        BOJANGSIJAKIL = json["BOJANGSIJAKIL"].stringValue
        BOJANGGEUMAEK = json["BOJANGGEUMAEK"].stringValue
        PIBOHUMJA = json["PIBOHUMJA"].stringValue
        SILSONGUBUN = json["SILSONGUBUN"].stringValue
        BOJANGMYUNG = json["BOJANGMYUNG"].stringValue
    }
}
