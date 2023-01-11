//
//  EventItem.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct EventItem: Decodable {
    let price: Int
    let imageUrl: String
    let description: String
    let neededPrice: Int
}
