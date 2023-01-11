//
//  SquareBanner.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/09/13.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

struct SquareBannerStatusModel {
    var attendance: Bool = false
    let create: Bool?
    let showAds: Bool?
    let squareBanner: SquareBannerModel?
    
    init(_ resultJson: JSON) {
        let json = resultJson["result"]
        Log.al("json = \(json)")
        attendance = json["attendance"].boolValue
        create = json["create"].bool
        showAds = json["showAds"].bool
        squareBanner = SquareBannerModel(json: json["squareBanner"])
    }
}

struct SquareBannerModel {
    
    var id: String = "" // 스퀘어 배너 고유값
    var title: String
    var company: String = "" // 광고주값이 있을 때만 직판배너 CASHDOC은 바탕채움
    var imageUrl: String = ""
    var url: String = "" // 클릭주소
    
    init(json: JSON) {
        id = json["id"].stringValue
        title = json["title"].stringValue
        company = json["company"].stringValue
        imageUrl = json["imageUrl"].stringValue
        url = json["url"].stringValue
    }
    
    init(resultJson: JSON) {
        let json = resultJson["result"]
        id = json["id"].stringValue
        title = json["title"].stringValue
        company = json["company"].stringValue
        imageUrl = json["imageUrl"].stringValue
        url = json["url"].stringValue
    }
}
