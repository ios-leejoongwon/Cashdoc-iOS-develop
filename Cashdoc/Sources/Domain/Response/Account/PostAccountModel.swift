//
//  PostAccountModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PostAccountModel: Decodable {
    let result: PostAccountResultModel
}

struct PostAccountResultModel: Decodable {
    let token: String
    let isNew: Bool
    let user: User
    let eventItem: EventItem?
    let point: Point
}
