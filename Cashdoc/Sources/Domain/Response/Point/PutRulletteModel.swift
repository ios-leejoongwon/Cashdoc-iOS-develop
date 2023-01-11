//
//  PutRulletteModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 29/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PutRulletteModel: Decodable {
    let result: RullettePointModel
}

struct RullettePointModel: Decodable {
    let point: Int
}
