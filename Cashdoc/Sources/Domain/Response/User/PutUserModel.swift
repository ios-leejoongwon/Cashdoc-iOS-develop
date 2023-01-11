//
//  PutUserModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 16/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

struct PutUserModel: Decodable {
    let result: PutUserResultModel
}

struct PutUserResultModel: Decodable {
    let pushId: String?
}

struct ResultModel: Decodable {
    let result: Bool?
}
