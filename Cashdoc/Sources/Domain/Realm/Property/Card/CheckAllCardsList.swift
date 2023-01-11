//
//  CheckAllCardsList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckAllCardsList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case cardName = "CARDNAME"
        case cardNum = "CARDNUM"
        case cardIssue = "CARDISSUE"
    }
    
    // MARK: - Properties
    
    dynamic var cardName: String?
    dynamic var cardNum: String?
    dynamic var cardIssue: String?
    dynamic var fCode: String?
    let cardLoanList = List<CheckCardLoanDetailsList>()
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        cardName = try container.decode(String.self, forKey: .cardName)
        cardNum = try container.decode(String.self, forKey: .cardNum)
        cardIssue = try? container.decode(String.self, forKey: .cardIssue)
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "cardNum"
    }
    
}
