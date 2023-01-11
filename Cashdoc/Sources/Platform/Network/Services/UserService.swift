//
//  UserService.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum UserSerivce {
    case getUser
    case delUserCache
    case getDeviceID
    case getAgree
}

// MARK: - TargetType

extension UserSerivce: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .getUser:
            return "user"
        case .delUserCache:
            return "user/cache"
        case .getDeviceID:
            return "device"
        case .getAgree:
            return "user/agree"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUser, .getDeviceID, .getAgree:
            return .get
        case .delUserCache:
            return .delete
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getUser, .delUserCache, .getDeviceID, .getAgree:
            parameters["access_token"] = AccessTokenManager.accessToken
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
