//
//  RewardPointService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum RewardPointService {
    case putPoint(point: String)
    case rullette
    case winner
    case rewardAssets
}

// MARK: - TargetType

extension RewardPointService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .putPoint:
            return "point/rewardClickPoint"
        case .rullette:
            return "roulette"
        case .winner:
            return "point/winners"
        case .rewardAssets:
            return "point/reward/assets"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .putPoint:
            return .put
        case .winner, .rewardAssets:
            return .get
        case .rullette:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .putPoint(let point):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["point"] = point
        case .rullette:
            parameters["access_token"] = AccessTokenManager.accessToken
            #if DEBUG
            parameters["version"] = "1.0.4"
            #else
            parameters["version"] = getAppVersion()
            #endif
        case .winner, .rewardAssets:
            parameters["access_token"] = AccessTokenManager.accessToken
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
