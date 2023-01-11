//
//  AuthService.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 10/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum AuthService {
    case postAuthSms(code: String)
    case getAuthSms(phone: String)
}

// MARK: - TargetType

extension AuthService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .postAuthSms:
            return "auth"
        case .getAuthSms:
            return "auth"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postAuthSms:
            return .post
        case .getAuthSms:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postAuthSms(let code):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["code"] = code
        case .getAuthSms(let phone):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["phone"] = phone
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
