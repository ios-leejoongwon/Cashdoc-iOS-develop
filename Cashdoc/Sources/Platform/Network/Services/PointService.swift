//
//  PointService.swift
//  Cashdoc
//
//  Created by Taejune Jung on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum PointService {
    case getPoint
}

// MARK: - TargetType

extension PointService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .getPoint:
            return "user/getPoint"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getPoint:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getPoint:
            parameters["access_token"] = AccessTokenManager.accessToken
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
