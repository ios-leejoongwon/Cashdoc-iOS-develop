//
//  ShopCategoryModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct ShopCategoryModelResponse: Decodable {
    let result: ShopCategoryModelResult
}

struct ShopCategoryModelResult: Decodable {
    let category: [ShopCategoryModel]?
    let bestGoods: [ShopBestModel]?
    let cashWithdrawal: [Int]?
}

struct ShopCategoryModel: Decodable {
    let id: Int?
    let title: String?
    let imageUrl: String?
    let price: Int?
    var affiliates: [ShopCategoryModel]?
    
    /// shop ad category properties
    let name: String?
    let url: String?
}
