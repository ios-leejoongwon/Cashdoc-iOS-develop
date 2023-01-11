//
//  PropertyService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum PropertyService {
    case postProperty(type: PropertyCardType, value: String)
    case getProperty(type: PropertyCardType)
}

// MARK: - TargetType

extension PropertyService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .postProperty(let type, _):
            return "property/upload/\(type.serviceType)"
        case .getProperty(let type):
            return "property/getList/\(type.serviceType)"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postProperty:
            return .post
        case .getProperty:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postProperty(_, let value):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["value"] = value
        case .getProperty:
             parameters["access_token"] = AccessTokenManager.accessToken
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
