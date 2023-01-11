//
//  EventService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 29/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum EventSerivce {
    case putFlagToShowEventCard(flag: Bool)
}

// MARK: - TargetType

extension EventSerivce: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .putFlagToShowEventCard:
            return "event/status/initfront"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .putFlagToShowEventCard:
            return .put
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .putFlagToShowEventCard(let flag):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["flag"] = flag ? "1" : "0"
        }
        
        return .requestParameters(parameters: parameters,
                                  encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
