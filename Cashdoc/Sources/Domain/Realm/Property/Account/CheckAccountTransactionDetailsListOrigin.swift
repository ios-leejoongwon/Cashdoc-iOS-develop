//
//  CheckAccountTransactionDetailsListOrigin.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/25.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

@objcMembers
final class CheckAccountTransactionDetailsListOrigin: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case tranDate = "TRANDATE"
        case tranGb = "TRANGB"
        case outBal = "OUTBAL"
        case inBal = "INBAL"
        case tranBal = "TRANABAL"
        case jukyo = "JUKYO"
        case tranDes = "TRANDES"
        case tranDep = "TRANDEP"
        case tranDt = "TRANDT"
    }
    
    // MARK: - Properties
    
    dynamic var identity: String = ""
    dynamic var number: String = ""
    dynamic var tranDate: Date = .init()
    dynamic var tranGb: String = ""
    dynamic var outBal: Int = 0
    dynamic var inBal: Int = 0
    dynamic var originalPrice: Int = 0
    dynamic var tranBal: Int = 0
    dynamic var jukyo: String = ""
    dynamic var tranDes: String = ""
    dynamic var tranDep: String = ""
    dynamic var tranDt: String = ""
    let details = LinkingObjects(fromType: CheckAccountTransactionDetails.self, property: "originList")
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let tranDateString = try container.decode(String.self, forKey: .tranDate)
        tranDate = tranDateString.simpleDateFormat("yyyyMMdd")
        tranGb = try container.decode(String.self, forKey: .tranGb)
        outBal = try container.decode(String.self, forKey: .outBal).toInt
        inBal = try container.decode(String.self, forKey: .inBal).toInt
        tranBal = try container.decode(String.self, forKey: .tranBal).toInt
        jukyo = try container.decode(String.self, forKey: .jukyo).replace(target: "'", withString: "''")
        tranDes = try container.decode(String.self, forKey: .tranDes)
        tranDep = try container.decode(String.self, forKey: .tranDep)
        tranDt = try container.decode(String.self, forKey: .tranDt)
        if tranGb == "입금" {
            originalPrice = inBal
        } else {
            originalPrice = outBal
        }
        identity = String(format: "%@_%@_%@_%d", tranDate.simpleDateFormat("yyyyMMdd"), tranDt, tranGb, tranBal)
    }
    
    required convenience init(_ detailList: CheckAccountTransactionDetailsList) {
        self.init()
        identity = detailList.identity
        tranDate = detailList.tranDate
        tranGb = detailList.tranGb
        outBal = detailList.outBal
        inBal = detailList.inBal
        originalPrice = detailList.originalPrice
        tranBal = detailList.tranBal
        jukyo = detailList.jukyo
        tranDes = detailList.tranDes
        tranDep = detailList.tranDep
        tranDt = detailList.tranDt
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
}
