//
//  InviteService.swift
//  Cashdoc
//
//  Created by Taejune Jung on 26/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum InviteService {
    case getInvite
    case putInvite(inviteCode: String)
}

extension InviteService: TargetType {
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .getInvite:
            return "invite"
        case .putInvite:
            return "invite"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getInvite:
            return .get
        case .putInvite:
            return .put
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getInvite:
            parameters["access_token"] = AccessTokenManager.accessToken
        case .putInvite(let inviteCode):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["code"] = inviteCode
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
}
