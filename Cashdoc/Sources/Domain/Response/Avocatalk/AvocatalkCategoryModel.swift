//
//  AvocatalkCategoryModel.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/13.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import SwiftyJSON

final class AvocatalkCategoryModel: Codable {
   
    var id: Int = 0
    var name: String?
    var link: String?
    var type: String?
    var order: Int = 0
    
    init(_ json: JSON) {
        id = json["id"].intValue
        name = json["name"].string
        link = json["link"].string
        type = json["type"].string
        order = json["order"].intValue
    }
    
    init() {
        id = 0
        name = ""
        link = "https://cashdoc.me"
        type = LinkType.browse.rawValue
        order = 1
    }
    
    enum LinkType: String {
        case webview
        case browse
        case link
        case chat
    }
}
