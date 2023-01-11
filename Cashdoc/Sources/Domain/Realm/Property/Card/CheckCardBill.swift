//
//  CheckCardBill.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardBill: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
        case errMsg = "ERRMSG"
        case errDoc = "ERRDOC"
        case eCode = "ECODE"
        case eTrack = "ETRACK"
        case payDate = "PAYDATE"
        case payAmt = "PAYAMT"
        case sumList = "SUMLIST"
        case list = "LIST"
    }
    
    // MARK: - Properties
    
    var result: String?
    var errMsg: String?
    var errCode: String?
    dynamic var payDate: String?
    dynamic var payAmt: String?
    let sumList = List<CheckCardBillSumaryList>()
    let list = List<CheckCardBillDetailList>()
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        result = try container.decode(String.self, forKey: .result)
        errMsg = try container.decode(String.self, forKey: .errMsg)
        errCode = try container.decode(String.self, forKey: .eCode)
        payDate = try container.decode(String.self, forKey: .payDate)
        payAmt = try container.decode(String.self, forKey: .payAmt)
        if let billSumaries = try? container.decode([CheckCardBillSumaryList].self, forKey: .sumList) {
            billSumaries.forEach {sumList.append($0)}
        }
        if let billDetails = try? container.decode([CheckCardBillDetailList].self, forKey: .list) {
            billDetails.forEach {list.append($0)}
        }
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "payDate"
    }
    
}
