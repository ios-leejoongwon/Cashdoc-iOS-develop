//
//  CheckCardBillSumaryList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 16/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardBillSumaryList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case fieldName = "FILEDNAME"
        case value1 = "VALUE1"
        
    }
    
    // MARK: - Properties
    
    dynamic var fieldName: String?
    dynamic var value1: String?
    let bill = LinkingObjects(fromType: CheckCardBill.self, property: "sumList")
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        fieldName = try? container.decode(String.self, forKey: .fieldName)
        value1 = try? container.decode(String.self, forKey: .value1)
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "fieldName"
    }
    
}
