//
//  CurrentPoint.swift
//  Cashdoc
//
//  Created by Taejune Jung on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct CurrentPoint: Decodable {
    let result: ResultCurrentPoint
}

struct ResultCurrentPoint: Decodable {
    let currentPoint: Int
    let expiredPoint: Int
    let expiredAtNextMonth: Int
}
