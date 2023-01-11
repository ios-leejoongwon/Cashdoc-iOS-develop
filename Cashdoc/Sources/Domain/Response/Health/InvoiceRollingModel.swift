//
//  InvoiceRollingModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/04/20.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

final class InvoiceRollingModel: Codable {
    var createdAt: Int = 0
    var amount: String = ""
    var name: String = ""
    
    init(_ json: JSON) {
        createdAt = json["createdAt"].intValue
        amount = json["amount"].stringValue
        name = json["name"].stringValue
    }
}
