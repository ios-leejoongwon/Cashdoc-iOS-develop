//
//  MinService.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import UIKit
import Moya

enum MinService {
    case getGameId
}

// MARK: - TargetType

extension MinService: TargetType {
    
    var baseURL: URL {
        #if CASHWALK
        return URL(string: API_URL)!
        #else
        return URL(string: API.CASHDOC_URL)!
        #endif
    }
    
    var path: String {
        switch self {
        case .getGameId:
            return "game/id"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getGameId:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()

        #if CASHWALK
        let token = UserDefaults.standard.string(forKey: UserDefaultsKey.kAccessToken) ?? ""
        #else
        let token = AccessTokenManager.accessToken
        #endif
        
        switch self {
        case .getGameId:
            parameters["access_token"] = token
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        #if CASHWALK
        return nil
        #else
        return API.CASHDOC_HEADERS
        #endif
    }
}
