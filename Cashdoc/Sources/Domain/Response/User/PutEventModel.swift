//
//  PutEventModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 29/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PutEventModel: Decodable {
    let result: PutEventModelResult
}

struct PutEventModelResult: Decodable {
    let user: PutEventInitFront
}

struct PutEventInitFront: Decodable {
    let id: String
    let eventShow: Int
}
