//
//  ShopBestModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct ShopBestModel: Decodable {
    var title: String?
    var goodsId: String?
    var price: Int?
    var imageUrl: String?
    var description: String?
    var validity: Int?
    var affiliate: String?
    var categoryId: Int?
    var type: String?
}
