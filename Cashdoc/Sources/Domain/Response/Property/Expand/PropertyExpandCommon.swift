//
//  PropertyExpandCommon.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/12/20.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

class PropertyExpandCommon {
    let type: PropertyCardType
    
    init(type: PropertyCardType) {
        self.type = type
    }
}

class PropertyExpandCash: PropertyExpandCommon {
    let point: Int
    
    init(type: PropertyCardType, point: Int) {
        self.point = point
        super.init(type: type)
    }
}

class PropertyExpandCredit: PropertyExpandCommon {
    let rating: String
    let score: String
    
    init(type: PropertyCardType, rating: String, score: String) {
        self.rating = rating
        self.score = score
        super.init(type: type)
    }
}

class PropertyExpandInsurance: PropertyExpandCommon {
    let insCount: Int
    let insTotalAmt: Int
    
    init(type: PropertyCardType, count: Int, total: Int) {
        self.insCount = count
        self.insTotalAmt = total
        super.init(type: type)
    }
}
