//
//  BaseApiResponse.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/13.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import SwiftyJSON

class BaseApiResponse {

    // MARK: - Con(De)structor
    
    required init?(json: JSON) {
        guard json.exists() else {return nil}
        parse(json: json)
    }
    
    // MARK: - Abstract methods
    
    func parse(json: JSON) {
        fatalError("parse() has not been implemented")
    }
    
}
