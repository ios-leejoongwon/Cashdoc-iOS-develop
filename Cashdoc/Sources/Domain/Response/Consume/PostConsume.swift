//
//  PostConsume.swift
//  Cashdoc
//
//  Created by Taejune Jung on 08/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PostConsume: Codable {
    let result: PostConsumeResult
}

struct PostConsumeResult: Codable {
    let total: Int
    let account: Int
    let card: Int
    let loan: Int
    let insurance: Int?
}
