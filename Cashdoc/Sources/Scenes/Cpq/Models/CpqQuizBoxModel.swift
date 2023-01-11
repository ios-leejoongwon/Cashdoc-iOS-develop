//
//  CpqQuizBoxModel.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import SwiftyJSON

final class CpqQuizBoxModels: Decodable {
    private(set) var arrQuizBox: [CpqQuizBoxModel]?
    
    required init?(json: JSON) {
        guard json.exists() else {return nil}
        parse(json: json)
    }
    
    // MARK: - Abstract methods
    
    func parse(json: JSON) {
        arrQuizBox = json["result"].array?.compactMap {CpqQuizBoxModel(json: $0)}
    }
}

final class CpqQuizBoxModel: Decodable {
    var targetId: String?
    var imageUrl: String?
    var os: String?
    var endDate: String?
    var startDate: String?
    var id: String?
    var show: Int?
    var title: String?
    var type: String?
    var lock: Int?
    
    required init?(json: JSON) {
        guard json.exists() else {return nil}
        parse(json: json)
    }
    
    func parse(json: JSON) {
        targetId = json["targetId"].string
        imageUrl = json["imageUrl"].string
        os = json["os"].string
        endDate = json["endDate"].string
        startDate = json["startDate"].string
        id = json["id"].string
        show = json["show"].int
        title = json["title"].string
        type = json["type"].string
        lock = json["lock"].int
    }
}
