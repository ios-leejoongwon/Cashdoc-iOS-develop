//
//  ShopModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct ShopModel: Decodable {
    let bestGoods: [ShopItemModel]?
    let result: ShopCategoryModel?
    let shopAd: ShopCategoryModel?
    let exchangeRate: Float?
    let isOpen: Bool?
}
