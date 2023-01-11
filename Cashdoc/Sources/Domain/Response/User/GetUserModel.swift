//
//  GetUserModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct GetUserModel: Decodable {
    let result: GetUserResultModel
}

struct GetUserResultModel: Decodable {
    let user: User
    let eventItem: EventItem?
    let version: Version
    let point: Point
}
