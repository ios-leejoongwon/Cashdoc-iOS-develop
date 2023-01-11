//
//  GetCategory.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct GetCategory: Decodable {
    let result: [GetCategoryResult]
}

struct GetCategoryResult: Decodable {
    let id: Int
    let category: String
    let sub1: String
    let sub2: String
    let createdAt: Int?
}
