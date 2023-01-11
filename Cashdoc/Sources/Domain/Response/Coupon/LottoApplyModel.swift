//
//  LottoApplyModel.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/05/03.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LottoApplyModel {
    var roundNumber = 0
    var success = true
    var lottoNumber = [Int]()
    var roundCoupons = 0
    var raffleDate = Date()
    
    init(_ json: JSON) {
        roundNumber = json["roundNumber"].intValue
        success = json["success"].boolValue
        roundCoupons = json["roundCoupons"].intValue
        raffleDate = json["raffleDate"].stringValue.simpleDateFormat("yyyy-MM-dd HH:mm:ss")
        let numbers = json["lottoNumber"].stringValue.split(separator: ",")
        for num in numbers {
            lottoNumber.append(Int(num) ?? 0)
        }
    }
}
