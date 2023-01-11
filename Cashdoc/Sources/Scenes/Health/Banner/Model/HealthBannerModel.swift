//
//  HealthBannerModel.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/17.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation

final class HealthBannerModel: Decodable {
    var order: Int?
    var startDate: String?
    var endDate: String?
    var image: String?
    var os: String?
    var id: String?
    var stamp: Int?
    var state: Int?
}
