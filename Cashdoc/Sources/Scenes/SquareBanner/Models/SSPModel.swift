//
//  SSPModel.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/09/27.
//  Copyright © 2022 Cashwalk. All rights reserved.
//
import SwiftyJSON
struct SSPListModel {
    
    enum AdType: String {
        case ADPIE
        case EXELBID
        case NONE
    }
    
    var order: [String]?
    var ADPIE_Timeout: Int = 1000
    var EXELBID_Timeout: Int = 1000
     
    init(_ resultJson: JSON) {
        let json = resultJson["result"]
        order = json["order"].arrayValue.map { $0.stringValue }
        ADPIE_Timeout = json["timeout"][SSPListModel.AdType.ADPIE.rawValue].intValue
        EXELBID_Timeout = json["timeout"][SSPListModel.AdType.EXELBID.rawValue].intValue
    }
}
