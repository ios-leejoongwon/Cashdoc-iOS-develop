//
//  CheckCardLoanDetailsList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardLoanDetailsList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case openDate = "OPENDATE"
        case closeDate = "CLOSEDATE"
        case interastRate = "INTERASTRATE"
        case loanAmt = "LOANAMT"
        case curAmt = "CURAMT"
        case payAmt = "PAYAMT"
        case intPayDate = "INTPAYDATE"
        case cardNum = "CARDNUM"
        case loanNum = "LOANNUM"
        case loanGubun = "LOANGUBUN"
        case loanTitle = "LOANTITLE"
        case cardIssue = "CARDISSUE"
    }
    
    // MARK: - Properties
    
    dynamic var identity: String?
    dynamic var fCodeName: String?
    dynamic var fCodeIndex: Int = 0
    dynamic var intCurAmt: Int = 0
    dynamic var openDate: String?
    dynamic var closeDate: String?
    dynamic var interastRate: String?
    dynamic var loanAmt: String?
    dynamic var curAmt: String?
    dynamic var payAmt: String?
    dynamic var intPayDate: String?
    dynamic var cardNum: String?
    dynamic var loanNum: String?
    dynamic var loanGubun: String?
    dynamic var loanTitle: String?
    dynamic var cardIssue: String?
    let cardList = LinkingObjects(fromType: CheckAllCardsList.self, property: "cardLoanList")
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        openDate = try container.decode(String.self, forKey: .openDate)
        closeDate = try? container.decode(String.self, forKey: .closeDate)
        interastRate = try? container.decode(String.self, forKey: .interastRate)
        loanAmt = try container.decode(String.self, forKey: .loanAmt)
        curAmt = try? container.decode(String.self, forKey: .curAmt)
        payAmt = try? container.decode(String.self, forKey: .payAmt)
        intPayDate = try? container.decode(String.self, forKey: .intPayDate)
        cardNum = try? container.decode(String.self, forKey: .cardNum)
        loanNum = try? container.decode(String.self, forKey: .loanNum)
        loanGubun = try container.decode(String.self, forKey: .loanGubun)
        loanTitle = try? container.decode(String.self, forKey: .loanTitle)
        cardIssue = try? container.decode(String.self, forKey: .cardIssue)
        
        if let openDate = openDate, let loanGubun = loanGubun, let loanAmt = loanAmt {
            identity = String(format: "%@_%@_%@", openDate, loanGubun, loanAmt)
        }
        
        if let curAmt = curAmt,
            let intCurAmt = Int(curAmt) {
            self.intCurAmt = intCurAmt
        }
        
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
    // MARK: - Internal methods
    
    func getCardName(with cardNum: String) -> String {
        for card in cardList where card.cardNum == cardNum {
            if let cardName = card.cardName {
                return cardName
            }
        }
        return ""
    }
    
}
