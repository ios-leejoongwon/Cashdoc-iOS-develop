//
//  CheckAccountTransactionDetails.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckAccountTransactionDetails: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
        case errMsg = "ERRMSG"
        case errDoc = "ERRDOC"
        case eCode = "ECODE"
        case eTrack = "ETRACK"
        case acctKind = "ACCTKIND"
        case number = "NUMBER"
        case curBal = "CURBAL"
        case enbBal = "ENBBAL"
        case acctNm = "ACCTNM"
        case openDate = "OPENDATE"
        case list = "LIST"
    }
    
    // MARK: - Properties
    
    var result: String?
    var errMsg: String?
    var errCode: String?
    dynamic var fCodeName: String = ""
    dynamic var acctKind: String = ""
    dynamic var number: String = ""
    dynamic var curBal: String = ""
    dynamic var enbBal: String = ""
    dynamic var acctNm: String = ""
    dynamic var openDate: String = ""
    var list = List<CheckAccountTransactionDetailsList>()
    var originList = List<CheckAccountTransactionDetailsListOrigin>()
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        result = try container.decode(String.self, forKey: .result)
        errMsg = try? container.decode(String.self, forKey: .errMsg)
        errCode = try? container.decode(String.self, forKey: .eCode)
        acctKind = try container.decode(String.self, forKey: .acctKind)
        number = try container.decode(String.self, forKey: .number)
        curBal = try container.decode(String.self, forKey: .curBal)
        enbBal = try container.decode(String.self, forKey: .enbBal)
        openDate = try container.decode(String.self, forKey: .openDate)
        if let list = try? container.decode([CheckAccountTransactionDetailsList].self, forKey: .list) {
            list.forEach { self.list.append($0) }
        }
        if let list = try? container.decode([CheckAccountTransactionDetailsListOrigin].self, forKey: .list) {
            list.forEach { self.originList.append($0) }
        }
    }
    
    convenience required init(details: CheckAccountTransactionDetails) {
        self.init()
        
        self.result = details.result
        self.errMsg = details.errMsg
        self.errCode = details.errCode
        self.acctKind = details.acctKind
        self.number = details.number
        self.curBal = details.curBal
        self.enbBal = details.enbBal
        self.acctNm = details.acctNm
        self.openDate = details.openDate
        let lists = List<CheckAccountTransactionDetailsList>()
        for list in details.list {
            lists.append(CheckAccountTransactionDetailsList(detailList: list))
        }
        self.list = lists
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "number"
    }
    
}
