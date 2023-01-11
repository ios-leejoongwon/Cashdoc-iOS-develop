//
//  Login.swift
//  Cashdoc
//
//  Created by Taejune Jung on 27/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct InviteState: Decodable {
    let result: InviteResultState
}

struct InviteResultState: Decodable {
    let point: Int
    let count: Int
    let code: String
    let recommendPoint: Int
    let recommendEvent: Int
    let joinPoint: Int
    let invitedPoint: Int
}
