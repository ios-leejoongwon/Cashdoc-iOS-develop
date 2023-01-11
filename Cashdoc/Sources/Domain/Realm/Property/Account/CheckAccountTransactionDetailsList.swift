//
//  CheckAccountTransactionDetailsList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 16/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

@objcMembers
class CheckAccountTransactionDetailsList: Object, Decodable {
    
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
    
    dynamic var category: String = ""
    dynamic var subCategory: String = ""
    dynamic var expedient: String = ""
    dynamic var isTouchEnabled: Bool = false
    dynamic var isDeleted: Bool = false
    dynamic var touchCount: Int = 0
    dynamic var identity: String = ""
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
    dynamic var memo: String = ""
    dynamic var acctKind: String = ""
    let details = LinkingObjects(fromType: CheckAccountTransactionDetails.self, property: "list")
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        category = "기타"
        subCategory = "미분류"
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
        if outBal == 0 {
            originalPrice = inBal
            subCategory = CategoryManager.findIncomeSubCategory(with: jukyo)
            if subCategory != "미분류"{
                category = "수입"
            }
        } else {
            originalPrice = outBal
        }
        identity = String(format: "%@_%@_%@_%d", tranDate.simpleDateFormat("yyyyMMdd"), tranDt, tranGb, tranBal)
    }
    
    convenience required init(detailList: CheckAccountTransactionDetailsList) {
        self.init()
        
        self.category = detailList.category
        self.subCategory = detailList.subCategory
        self.isTouchEnabled = detailList.isTouchEnabled
        self.isDeleted = false
        self.touchCount = detailList.touchCount
        self.identity = detailList.identity
        self.tranDate = detailList.tranDate
        self.tranGb = detailList.tranGb
        self.outBal = detailList.outBal
        self.inBal = detailList.inBal
        self.tranBal = detailList.tranBal
        self.jukyo = detailList.jukyo
        self.tranDes = detailList.tranDes
        self.tranDep = detailList.tranDep
        self.tranDt = detailList.tranDt
        self.acctKind = detailList.acctKind
        self.memo = ""
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
}
