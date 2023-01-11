//
//  CouponModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SwiftyJSON
struct CouponModel: Decodable {
    let delay: Int?
    let price: Int?
    let state: Int?
    let active: String?
    let affiliate: String?
    let date: String?
    let description: String?
    let expiredAt: Int?
    let id: Int?
    let imageUrl: String?
    let pinNo: String?
    let prize: String?
    let trId: String?
    let title: String?
    let used: String?
    let type: String?
    var createdAt: Int?
}
 
