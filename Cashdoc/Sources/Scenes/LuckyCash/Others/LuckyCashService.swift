//
//  LuckyCashService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/24.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum LuckyCashService {
    case getWinners
    case getInterstitial
    case postInterstitial
}

extension LuckyCashService: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getWinners, .getInterstitial, .postInterstitial:
            #if CASHWALK
            return URL(string: API_URL)!
            #else
            return URL(string: API.CASHDOC_URL)!
            #endif
        }
    }
    
    var path: String {
        #if CASHWALK
        switch self {
        case .getWinners:
            return "roulette/winners"
        case .getInterstitial, .postInterstitial:
            return "roulette/intersticial"
        }
        #else
        switch self {
        case .getWinners:
            return "luckyCash/winners"
        case .getInterstitial, .postInterstitial:
            return "luckyCash/interstitial"
        }
        #endif
    }
    
    var method: Moya.Method {
        switch self {
        case .getWinners, .getInterstitial:
            return .get
        case .postInterstitial:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }

    var task: Task {
        var params: [String: Any] = [:]
        #if CASHWALK
        let token = UserDefaults.standard.string(forKey: UserDefaultsKey.kAccessToken) ?? ""
        #else
        let token = AccessTokenManager.accessToken
        #endif
        
        switch self {
        case .getWinners, .getInterstitial:
            params["access_token"] = token
            params["osType"] = "ios"
        case .postInterstitial:
            params["access_token"] = token
            params["osType"] = "ios"
        }
        return .requestParameters(parameters: params, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        #if CASHWALK
        return nil
        #else
        return API.CASHDOC_HEADERS
        #endif
    }
    
}
