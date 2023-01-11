//
//  CommunityService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/04/23.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum CommunityService {
    case getToken(id: String)
}

// MARK: - TargetType

extension CommunityService: TargetType {
    var baseURL: URL {
        let urlString = String(API.CASHDOC_URL.dropLast(3))
        return URL(string: urlString)!
    }
    
    var path: String {
        return "oidc/custom/token"
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self {
        case .getToken(let id):
            params["owner"] = id
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
}
