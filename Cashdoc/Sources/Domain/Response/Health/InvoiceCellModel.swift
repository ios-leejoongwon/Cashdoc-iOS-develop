//
//  InvoiceCellModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/04/21.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

final class InvoiceCellModel: Codable {
    var hTotal: Int = 0
    var lastName: String = ""
    var lastBal: Int = 0
    var personCount: Int = 0
    var aTotal: Int = 0
}
