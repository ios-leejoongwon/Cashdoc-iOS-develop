//
//  MedicIneListModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import SwiftyJSON
import RealmSwift

@objcMembers
class MedicIneListModel: SwiftyJSONRealmObject {
    dynamic var TREATDSGB: String = ""
    dynamic var TREATDSNM: String = ""
    dynamic var TREATMEDICALNM: String = ""
    dynamic var TREATDATE: String = ""
    dynamic var TREATTYPE: String = ""
    dynamic var VISITCNT: String = ""
    dynamic var PRESCRIBECNT: String = ""
    dynamic var MEDICINECNT: String = ""
    dynamic var IDENTYTY: String = ""
    dynamic var PRICE: Int = 0
    dynamic var DETAILLIST = List<MedicIneDetail>()
    
    override static func primaryKey() -> String? {
        return "IDENTYTY"
    }
    
    convenience required init(json: JSON) {
        self.init()
        TREATDSGB = json["TREATDSGB"].stringValue
        TREATDSNM = json["TREATDSNM"].stringValue
        TREATMEDICALNM = json["TREATMEDICALNM"].stringValue
        TREATDATE = json["TREATDATE"].stringValue
        TREATTYPE = json["TREATTYPE"].stringValue
        VISITCNT = json["VISITCNT"].stringValue
        PRESCRIBECNT = json["PRESCRIBECNT"].stringValue
        MEDICINECNT = json["MEDICINECNT"].stringValue
        IDENTYTY = json["TREATDATE"].stringValue + json["TREATMEDICALNM"].stringValue
        DETAILLIST = SwiftyJSONRealmObject.createList(ofType: MedicIneDetail.self, fromJson: json["DETAILLIST"])
    }
}

@objcMembers
class MedicIneDetail: SwiftyJSONRealmObject {
    dynamic var TREATDATE: String = ""
    dynamic var TREATTYPE: String = ""
    dynamic var PRESCRIBECNT: String = ""
    dynamic var MEDICINENM: String = ""
    dynamic var MEDICINEEFFECT: String = ""
    dynamic var ADMINISTERCNT: String = ""
    dynamic var DRUGINFOLIST = List<MedicIneDrugDetail>()

    convenience required init(json: JSON) {
        self.init()
        TREATDATE = json["TREATDATE"].stringValue
        TREATTYPE = json["TREATTYPE"].stringValue
        PRESCRIBECNT = json["PRESCRIBECNT"].stringValue
        MEDICINENM = json["MEDICINENM"].stringValue
        MEDICINEEFFECT = json["MEDICINEEFFECT"].stringValue
        ADMINISTERCNT = json["ADMINISTERCNT"].stringValue
        DRUGINFOLIST = SwiftyJSONRealmObject.createList(ofType: MedicIneDrugDetail.self, fromJson: json["DRUGINFOLIST"])
    }
}

@objcMembers
class MedicIneDrugDetail: SwiftyJSONRealmObject {
    dynamic var PRODUCTNM: String = ""
    dynamic var SPECIALYN: String = ""
    dynamic var SINGLEYN: String = ""
    dynamic var MAKINGCOMPANY: String = ""
    dynamic var SALESCOMPANY: String = ""
    dynamic var SHAPE: String = ""
    dynamic var ADMINISTERPATH: String = ""
    dynamic var MEDICINEGROUP: String = ""
    dynamic var PAYINFO: String = ""
    dynamic var ATC: String = ""
    dynamic var INGREDIENTNMLIST = List<MedicIneIngrediList>()
    dynamic var KPICLIST = List<MedicIneKpicList>()
    dynamic var DUR = List<MedicIneDurList>()
    
    convenience required init(json: JSON) {
        self.init()
        PRODUCTNM = json["PRODUCTNM"].stringValue
        SPECIALYN = json["SPECIALYN"].stringValue
        SINGLEYN = json["SINGLEYN"].stringValue
        MAKINGCOMPANY = json["MAKINGCOMPANY"].stringValue
        SALESCOMPANY = json["SALESCOMPANY"].stringValue
        SHAPE = json["SHAPE"].stringValue
        ADMINISTERPATH = json["ADMINISTERPATH"].stringValue
        MEDICINEGROUP = json["MEDICINEGROUP"].stringValue
        PAYINFO = json["PAYINFO"].stringValue
        ATC = json["ATC"].stringValue
        INGREDIENTNMLIST = SwiftyJSONRealmObject.createList(ofType: MedicIneIngrediList.self, fromJson: json["INGREDIENTNMLIST"])
        KPICLIST = SwiftyJSONRealmObject.createList(ofType: MedicIneKpicList.self, fromJson: json["KPICLIST"])
        DUR = SwiftyJSONRealmObject.createList(ofType: MedicIneDurList.self, fromJson: json["DUR"])
    }
}

@objcMembers
class MedicIneIngrediList: SwiftyJSONRealmObject {
    dynamic var INGREDIENTNM: String = ""

    convenience required init(json: JSON) {
        self.init()
        INGREDIENTNM = json["INGREDIENTNM"].stringValue
    }
}

@objcMembers
class MedicIneKpicList: SwiftyJSONRealmObject {
    dynamic var KPIC: String = ""
    
    convenience required init(json: JSON) {
        self.init()
        KPIC = json["KPIC"].stringValue
    }
}

@objcMembers
class MedicIneDurList: SwiftyJSONRealmObject {
    dynamic var COMBINEDTABOO: String = ""
    dynamic var AGETABOO: String = ""
    dynamic var PREGNANTTABOO: String = ""

    convenience required init(json: JSON) {
        self.init()
        COMBINEDTABOO = json["COMBINEDTABOO"].stringValue
        AGETABOO = json["AGETABOO"].stringValue
        PREGNANTTABOO = json["PREGNANTTABOO"].stringValue
    }
}
