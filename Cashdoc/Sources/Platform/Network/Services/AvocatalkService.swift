//
//  AvocatalkService.swift
//  Cashdoc
//
//  Created by 이아림 on 2021/10/13.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Moya

enum AvocatalkService {
    case getCategory
}

extension AvocatalkService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .getCategory:
            return "community/category"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCategory:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getCategory:
            parameters["access_token"] = AccessTokenManager.accessToken
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
}
