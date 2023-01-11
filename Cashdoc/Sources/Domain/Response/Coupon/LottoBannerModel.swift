//
//  LottoBannerModel.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/04/28.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LottoBannerModel {
    var id = 0
    var linkUrl = ""
    var imageUrl = ""
    var order = 0
    
    init(_ json: JSON) {
        id = json["id"].intValue
        id = json["order"].intValue
        linkUrl = json["linkUrl"].stringValue
        imageUrl = json["imageUrl"].stringValue
    }
}
        
