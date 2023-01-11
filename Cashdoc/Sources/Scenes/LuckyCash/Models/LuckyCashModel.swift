//
//  LuckyCashModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk. All rights reserved....
//

struct LuckyCashModel: Codable {
    var type: String?
    var point: Int?
    var canPlay: Bool? { return _canPlay == 1 ? true : false }
    
    private var _canPlay: Int?
    
    private enum CodingKeys: String, CodingKey {
        case _canPlay = "canPlay"
        case type, point
    }
}
