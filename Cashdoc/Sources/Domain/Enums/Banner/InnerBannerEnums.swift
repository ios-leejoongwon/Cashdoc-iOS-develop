//
//  InnerBannerEnums.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum InnerBannerAdType {
    case close
    case coinbox
    case drawer(InnerBannerDrawerAdType)
    
    var endPoint: String {
        switch self {
        case .close:
            return "end"
        case .coinbox:
            return "coinbox"
        case .drawer:
            return "drawer"
        }
    }
    
    var params: [String: Any] {
        var params = [String: Any]()
        
        switch self {
        case .drawer(let drawerAdType):
            params["adType"] = drawerAdType.rawValue
        default:
            break
        }
        
        return params
    }
}

enum InnerBannerDrawerAdType: String {
    case drawerad1
    case drawerad2
    case drawerad3
    case drawerad4
    case drawerad5
}

enum InnerBannerPositionType: String {
    case cashinbody
    case cashwatch
    case diet
    case shop
    case quiz
    case checkup
    case treatment
    case insurance
}
