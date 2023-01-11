//
//  InsuranceJListModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/11.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class InsuranceJListModel: SwiftyJSONRealmObject {
    dynamic var NAPIPGIGAN: String = ""
    dynamic var GYEYAKSANGTAE: String = ""
    dynamic var JEUNGGWONBUNHO: String = ""
    dynamic var NAPIPJOOGI: String = ""
    dynamic var GYEYAKJA: String = ""
    dynamic var ILHOIBOHUMRYO: String = ""
    dynamic var BOJANGJONGRYOIL: String = ""
    dynamic var BOJANGSIJAKIL: String = ""
    dynamic var HOISAMYUNG: String = ""
    dynamic var SANGPUMMYUNG: String = ""
    dynamic var PIBOHUMJA: String = ""
    dynamic var IDENTYTY: String = ""
    dynamic var NAPIPSANGSE = List<InsuranceJDetail>()
    
    override static func primaryKey() -> String? {
        return "IDENTYTY"
    }
    
    convenience required init(json: JSON) {
        self.init()
        NAPIPGIGAN = json["NAPIPGIGAN"].stringValue
        GYEYAKSANGTAE = json["GYEYAKSANGTAE"].stringValue
        JEUNGGWONBUNHO = json["JEUNGGWONBUNHO"].stringValue
        NAPIPJOOGI = json["NAPIPJOOGI"].stringValue
        GYEYAKJA = json["GYEYAKJA"].stringValue
        ILHOIBOHUMRYO = json["ILHOIBOHUMRYO"].stringValue
        BOJANGJONGRYOIL = json["BOJANGJONGRYOIL"].stringValue
        BOJANGSIJAKIL = json["BOJANGSIJAKIL"].stringValue
        HOISAMYUNG = json["HOISAMYUNG"].stringValue
        SANGPUMMYUNG = json["SANGPUMMYUNG"].stringValue
        IDENTYTY = json["BOJANGSIJAKIL"].stringValue + json["SANGPUMMYUNG"].stringValue
        
        NAPIPSANGSE = SwiftyJSONRealmObject.createList(ofType: InsuranceJDetail.self, fromJson: json["NAPIPSANGSE"])
        
        if let firstModel = NAPIPSANGSE.first {
            PIBOHUMJA = firstModel.PIBOHUMJA
        }
    }
}

@objcMembers
class InsuranceJDetail: SwiftyJSONRealmObject {
    dynamic var PIBOHUMJA: String = ""
    dynamic var BOJANGGUBUN: String = ""
    dynamic var HOISABOJANGMYUNG: String = ""
    dynamic var BOJANGSANGTAE: String = ""
    dynamic var BOJANGGEUMAEK: String = ""

    convenience required init(json: JSON) {
        self.init()
        PIBOHUMJA = json["PIBOHUMJA"].stringValue
        BOJANGGUBUN = json["BOJANGGUBUN"].stringValue
        HOISABOJANGMYUNG = json["HOISABOJANGMYUNG"].stringValue
        BOJANGSANGTAE = json["BOJANGSANGTAE"].stringValue
        BOJANGGEUMAEK = json["BOJANGGEUMAEK"].stringValue
    }
}
