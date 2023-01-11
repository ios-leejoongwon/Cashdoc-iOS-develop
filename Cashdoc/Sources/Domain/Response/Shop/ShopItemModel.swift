//
//  ShopItemModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct ShopItemModelResponse: Decodable {
    let result: [ShopItemModel]?
}

struct ShopItemModel: Decodable {
    let title: String?
    let goodsId: String?
    let price: Int?
    let imageUrl: String?
    let affiliate: String?
    let type: String?
    let validity: Int?
    let description: String?
    let pinNo: String?
    let ctrId: String?
    let expiredAt: String?
    let delay: Int?
}
