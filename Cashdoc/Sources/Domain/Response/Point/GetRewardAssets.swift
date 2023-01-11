//
//  GetRewardAssets.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/12/02.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct GetRewardAssets: Decodable {
    let result: GetRewardAssetsResult
}

struct GetRewardAssetsResult: Decodable {
    let point: GetRewardAssetsResultPoint
}

struct GetRewardAssetsResultPoint: Decodable {
    let account: Int
    let card: Int
    let loan: Int
    let insurance: Int
    let creditinfo: Int
    let treatment: Int
    let checkup: Int
}
