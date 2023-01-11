//
//  ShopBuyItemModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct ShopBuyItemResponse: Decodable {
    var goodsId: String?
    var point: ShopBuyPointModel?
    var coupon: ShopBuyItemModel?
}

struct ShopBuyPointModel: Decodable {
    var used: Int?
    var remain: Int?
}

struct ShopBuyItemModel: Decodable {
    var ctrId: String?
    var description: String?
    var title: String?
    var imageUrl: String?
    var affiliate: String?
    var pinNo: String?
    var expiredAt: Int?
    var errorCode: Int?
    var errorType: String?
}
