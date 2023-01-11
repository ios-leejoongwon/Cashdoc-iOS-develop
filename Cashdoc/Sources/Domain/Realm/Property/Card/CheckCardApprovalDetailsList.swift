//
//  CheckCardApprovalDetailsList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardApprovalDetailsList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case useDis = "USEDIS"
        case appNickname = "APPNICKNAME"
        case appDate = "APPDATE"
        case appTime = "APPTIME"
        case appNo = "APPNO"
        case appGubun = "APPGUBUN"
        case appQuota = "APPQUOTA"
        case appAmt = "APPAMT"
        case appFranName = "APPFRANNAME"
        case appTonghwa = "APPTONGHWA"
        case appFranRegNum = "APPFRANREGNUM"
        case appFranType = "APPFRANTYPE"
        case appFranTel = "APPFRANTEL"
        case appFranAddr = "APPFRANADDR"
        case appFransajang = "APPFRANSAJANG"
        case appCardNum = "APPCARDNUM"
        case checkGubun = "CHECKGUBUN"
        case cardIssue = "CARDISSUE"
    }
    
    // MARK: - Properties
    
    dynamic var category: String = ""
    dynamic var subCategory: String = ""
    dynamic var touchCount: Int = 0
    dynamic var isTouchEnabled: Bool = false
    dynamic var isDeleted: Bool = false
    dynamic var useDis: String = ""
    dynamic var appNickname: String = ""
    dynamic var appDate: Date = .init()
    dynamic var appTime: String = ""
    dynamic var appNo: String = ""
    dynamic var appGubun: String = ""
    dynamic var appQuota: String = ""
    dynamic var appAmt: Int = 0
    dynamic var originalAppAmt: Int = 0
    dynamic var appFranName: String = ""
    dynamic var appTonghwa: String = ""
    dynamic var appFranRegNum: String = ""
    dynamic var appFranType: String = ""
    dynamic var appFranTel: String = ""
    dynamic var appFranAddr: String = ""
    dynamic var appFransajang: String = ""
    dynamic var appCardNum: String = ""
    dynamic var checkGubun: String = ""
    dynamic var cardIssue: String = ""
    dynamic var memo: String = ""
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        useDis = try container.decode(String.self, forKey: .useDis)
        appNickname = try container.decode(String.self, forKey: .appNickname)
        let appDateString = try container.decode(String.self, forKey: .appDate)
        appDate = appDateString.simpleDateFormat("yyyyMMdd")
        appTime = try container.decode(String.self, forKey: .appTime)
        appNo = try container.decode(String.self, forKey: .appNo)
        appGubun = try container.decode(String.self, forKey: .appGubun)
        if let appQuota = try? container.decode(String.self, forKey: .appQuota) {
            self.appQuota = appQuota
        }
        appAmt = try container.decode(String.self, forKey: .appAmt).toInt
        originalAppAmt = appAmt
        appFranName = try container.decode(String.self, forKey: .appFranName)
        if let appTonghwa = try? container.decode(String.self, forKey: .appTonghwa) {
            self.appTonghwa = appTonghwa
        }
        appFranRegNum = try container.decode(String.self, forKey: .appFranRegNum)
        if let appFranType = try? container.decode(String.self, forKey: .appFranType) {
            self.appFranType = appFranType
        }
        appFranTel = try container.decode(String.self, forKey: .appFranTel)
        appFranAddr = try container.decode(String.self, forKey: .appFranAddr)
        if let appFransajang = try? container.decode(String.self, forKey: .appFransajang) {
            self.appFransajang = appFransajang
        }
        appCardNum = try container.decode(String.self, forKey: .appCardNum)
        checkGubun = try container.decode(String.self, forKey: .checkGubun)
        if let cardIssue = try? container.decode(String.self, forKey: .cardIssue) {
            self.cardIssue = cardIssue
        }
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "appNo"
    }
}
