//
//  WinnerModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 30/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct WinnerModel: Decodable {
    let result: Winners
}

struct Winners: Decodable {
    let winners: [WinnerList]
}

struct WinnerList: Decodable {
    let nickname: String
    let point: Int
    let id: Int
}
