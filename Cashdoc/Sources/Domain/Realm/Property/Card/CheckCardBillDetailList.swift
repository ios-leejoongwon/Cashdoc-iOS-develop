//
//  CheckCardBillDetailList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 16/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardBillDetailList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case useDis = "USEDIS"
        case useDate = "USEDATE"
        case franName = "FRANNAME"
        case appNum = "APPNUM"
        case appNickname = "APPNICKNAME"
        case surTax = "SURTAX"
        case tip = "TIP"
        case fxDate = "FXDATE"
        case regNum = "REGNUM"
        case workKind = "WORKKIND"
        case addr1 = "ADDR1"
        case addr2 = "ADDR2"
        case tel = "TEL"
        case fxUse = "FXUSE"
        case preName = "PRENAME"
        case fxCode = "FXCODE"
        case useAmt = "USEAMT"
        case fxAmt = "FXAMT"
        case fee = "FEE"
        case instrmNm = "INSTRMNM"
        case instrmMon = "INSTRMMON"
        case cardIssue = "CARDISSUE"
        
    }
    
    // MARK: - Properties
    
    dynamic var identity: String?
    dynamic var useDis: String?
    dynamic var useDate: String?
    dynamic var franName: String?
    dynamic var appNickname: String?
    dynamic var useAmt: String?
    dynamic var fee: String?
    dynamic var instrmNm: String?
    dynamic var instrmMon: String?
    dynamic var cardIssue: String?
    let bill = LinkingObjects(fromType: CheckCardBill.self, property: "list")
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        useDis = try container.decode(String.self, forKey: .useDis)
        useDate = try container.decode(String.self, forKey: .useDate)
        franName = try container.decode(String.self, forKey: .franName)
        appNickname = try? container.decode(String.self, forKey: .appNickname)
        useAmt = try container.decode(String.self, forKey: .useAmt)
        fee = try container.decode(String.self, forKey: .fee)
        instrmNm = try? container.decode(String.self, forKey: .instrmNm)
        instrmMon = try? container.decode(String.self, forKey: .instrmMon)
        cardIssue = try? container.decode(String.self, forKey: .cardIssue)
        if let useDate = useDate, let franName = franName, let useAmt = useAmt {
            identity = String(format: "%@_%@_%@", useDate, franName, useAmt)
        }
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
}
