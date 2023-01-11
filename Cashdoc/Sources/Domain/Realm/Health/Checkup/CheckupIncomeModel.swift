//
//  CheckupIncomeModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class CheckupIncomeModel: SwiftyJSONRealmObject {
    dynamic var JUDGMENT: String = ""
    dynamic var WAISTSIZE: String = ""
    dynamic var TOTCHOLESTEROL: String = ""
    dynamic var YGPT: String = ""
    dynamic var HDLCHOLESTEROL: String = ""
    dynamic var HEARING: String = ""
    dynamic var HEIGHT: String = ""
    dynamic var SERUMCREATININE: String = ""
    dynamic var YODANBAK: String = ""
    dynamic var GUNYEAR: String = ""
    dynamic var SGOT: String = ""
    dynamic var SIGHT: String = ""
    dynamic var GUNPLACE: String = ""
    dynamic var LDLCHOLESTEROL: String = ""
    dynamic var TRIGLYCERIDE: String = ""
    dynamic var BLOODPRESS: String = ""
    dynamic var WEIGHT: String = ""
    dynamic var BODYMASS: String = ""
    dynamic var BLOODSUGAR: String = ""
    dynamic var CHESTTROUBLE: String = ""
    dynamic var OSTEOPOROSIS: String = ""
    dynamic var GUNDATE: String = ""
    dynamic var HEMOGLOBIN: String = ""
    dynamic var SGPT: String = ""
    dynamic var GFR: String = ""
    dynamic var CHECKUPORGAN: String = ""
    dynamic var CHECKUPOPINION: String = ""
    dynamic var CHECKUPDATE: String = ""
    dynamic var BIRTH: String = ""
    dynamic var SEX: String = ""
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
        YODANBAK = json["YODANBAK"].stringValue
        GUNYEAR = json["GUNYEAR"].stringValue
        SGOT = json["SGOT"].stringValue
        SIGHT = json["SIGHT"].stringValue
        GUNPLACE = json["GUNPLACE"].stringValue
        LDLCHOLESTEROL = json["LDLCHOLESTEROL"].stringValue
        TRIGLYCERIDE = json["TRIGLYCERIDE"].stringValue
        BLOODPRESS = json["BLOODPRESS"].stringValue
        WEIGHT = json["WEIGHT"].stringValue
        BODYMASS = json["BODYMASS"].stringValue
        BLOODSUGAR = json["BLOODSUGAR"].stringValue
        CHESTTROUBLE = json["CHESTTROUBLE"].stringValue
        OSTEOPOROSIS = json["OSTEOPOROSIS"].stringValue
        GUNDATE = json["GUNDATE"].stringValue
        HEMOGLOBIN = json["HEMOGLOBIN"].stringValue
        SGPT = json["SGPT"].stringValue
        GFR = json["GFR"].stringValue
        CHECKUPORGAN = json["CHECKUPORGAN"].stringValue
        CHECKUPOPINION = json["CHECKUPOPINION"].stringValue
        CHECKUPDATE = json["CHECKUPDATE"].stringValue
        BIRTH = json["BIRTH"].stringValue
        SEX = json["SEX"].stringValue
        
        IDENTYTY = json["GUNDATE"].stringValue + json["BLOODPRESS"].stringValue
    }
    
    func toDict() -> [String: String] {
        var makeDict = [String: String]()
        makeDict.updateValue(JUDGMENT, forKey: "JUDGMENT")
        makeDict.updateValue(WAISTSIZE, forKey: "WAISTSIZE")
        makeDict.updateValue(TOTCHOLESTEROL, forKey: "TOTCHOLESTEROL")
        makeDict.updateValue(YGPT, forKey: "YGPT")
        makeDict.updateValue(HDLCHOLESTEROL, forKey: "HDLCHOLESTEROL")
        makeDict.updateValue(HEARING, forKey: "HEARING")
        makeDict.updateValue(HEIGHT, forKey: "HEIGHT")
        makeDict.updateValue(SERUMCREATININE, forKey: "SERUMCREATININE")
        makeDict.updateValue(YODANBAK, forKey: "YODANBAK")
        makeDict.updateValue(GUNYEAR, forKey: "GUNYEAR")
        makeDict.updateValue(SGOT, forKey: "SGOT")
        makeDict.updateValue(SIGHT, forKey: "SIGHT")
        makeDict.updateValue(GUNPLACE, forKey: "GUNPLACE")
        makeDict.updateValue(LDLCHOLESTEROL, forKey: "LDLCHOLESTEROL")
        makeDict.updateValue(TRIGLYCERIDE, forKey: "TRIGLYCERIDE")
        makeDict.updateValue(BLOODPRESS, forKey: "BLOODPRESS")
        makeDict.updateValue(WEIGHT, forKey: "WEIGHT")
        makeDict.updateValue(BODYMASS, forKey: "BODYMASS")
        makeDict.updateValue(BLOODSUGAR, forKey: "BLOODSUGAR")
        makeDict.updateValue(CHESTTROUBLE, forKey: "CHESTTROUBLE")
        makeDict.updateValue(OSTEOPOROSIS, forKey: "OSTEOPOROSIS")
        makeDict.updateValue(GUNDATE, forKey: "GUNDATE")
        makeDict.updateValue(HEMOGLOBIN, forKey: "HEMOGLOBIN")
        makeDict.updateValue(SGPT, forKey: "SGPT")
        makeDict.updateValue(CHECKUPORGAN, forKey: "CHECKUPORGAN")
        makeDict.updateValue(CHECKUPOPINION, forKey: "CHECKUPOPINION")
        makeDict.updateValue(CHECKUPDATE, forKey: "CHECKUPDATE")
        makeDict.updateValue(BIRTH, forKey: "BIRTH")
        makeDict.updateValue(SEX, forKey: "SEX")
        makeDict.updateValue(IDENTYTY, forKey: "IDENTYTY")        
        return makeDict
    }
}
