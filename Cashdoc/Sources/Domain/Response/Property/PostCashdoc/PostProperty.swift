//
//  PostProperty.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct Postproperty: Codable {
    let result: PostpropertyResult
}

struct PostpropertyResult: Codable {
    let total: Int
    let account: Int
    let card: Int
    let loan: Int
    let insurance: Int?
}
