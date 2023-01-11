//
//  GetVersion.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/11/06.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SwiftyJSON

struct GetVersion: Decodable {
    let version: String
    let must: Bool
    let reviewVersion: String
    let latest: String // 마켓에 올라간 최신버전
    
    init(_ json: JSON) {
        version = json["version"].stringValue
        must = json["must"].boolValue
        reviewVersion = json["reviewVersion"].stringValue
        latest = json["latest"].stringValue
    }
}
