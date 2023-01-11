//
//  CheckupReferceListModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class CheckupReferceListModel: SwiftyJSONRealmObject {
    dynamic var JUDGMENT: String = ""
    dynamic var WAISTSIZE: String = ""
    dynamic var TOTCHOLESTEROL: String = ""
    dynamic var YGPT: String = ""
    dynamic var HDLCHOLESTEROL: String = ""
    dynamic var HEARING: String = ""
    dynamic var HEIGHT: String = ""
    dynamic var SERUMCREATININE: String = ""
    dynamic var GFR: String = ""
    dynamic var YODANBAK: String = ""
    dynamic var SGOT: String = ""
    dynamic var SIGHT: String = ""
    dynamic var GUNPLACE: String = ""
    dynamic var LDLCHOLESTEROL: String = ""
    dynamic var TRIGLYCERIDE: String = ""
    dynamic var BLOODPRESS: String = ""
    dynamic var GUBUN: String = ""
    dynamic var WEIGHT: String = ""
    dynamic var BODYMASS: String = ""
    dynamic var BLOODSUGAR: String = ""
    dynamic var CHESTTROUBLE: String = ""
    dynamic var OSTEOPOROSIS: String = ""
    dynamic var GUNDATE: String = ""
    dynamic var HEMOGLOBIN: String = ""
    dynamic var SGPT: String = ""
    dynamic var IDENTYTY: String = ""

    override static func primaryKey() -> String? {
        return "IDENTYTY"
    }
    
    convenience required init(json: JSON) {
        self.init()
        JUDGMENT = json["JUDGMENT"].stringValue
        WAISTSIZE = json["WAISTSIZE"].stringValue
        TOTCHOLESTEROL = json["TOTCHOLESTEROL"].stringValue
        YGPT = json["YGPT"].stringValue
        HDLCHOLESTEROL = json["HDLCHOLESTEROL"].stringValue
        HEARING = json["HEARING"].stringValue
        HEIGHT = json["HEIGHT"].stringValue
        SERUMCREATININE = json["SERUMCREATININE"].stringValue
        GFR = json["GFR"].stringValue
        YODANBAK = json["YODANBAK"].stringValue
        SGOT = json["SGOT"].stringValue
        SIGHT = json["SIGHT"].stringValue
        LDLCHOLESTEROL = json["LDLCHOLESTEROL"].stringValue
        TRIGLYCERIDE = json["TRIGLYCERIDE"].stringValue
        BLOODPRESS = json["BLOODPRESS"].stringValue
        GUBUN = json["GUBUN"].stringValue
        WEIGHT = json["WEIGHT"].stringValue
        BODYMASS = json["BODYMASS"].stringValue
        BLOODSUGAR = json["BLOODSUGAR"].stringValue
        CHESTTROUBLE = json["CHESTTROUBLE"].stringValue
        OSTEOPOROSIS = json["OSTEOPOROSIS"].stringValue
        GUNDATE = json["GUNDATE"].stringValue
        HEMOGLOBIN = json["HEMOGLOBIN"].stringValue
        SGPT = json["SGPT"].stringValue
        
        IDENTYTY = json["OSTEOPOROSIS"].stringValue + json["BLOODPRESS"].stringValue
    }
}
