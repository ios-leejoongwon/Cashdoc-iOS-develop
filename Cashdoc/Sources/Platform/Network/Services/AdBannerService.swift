//
//  BannerService.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 19/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum AdBannerService {
    case getConsumeBanner
    case getShopBanner(position: String)
    case postBanner(type: String, id: String)
}

// MARK: - TargetType

extension AdBannerService: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getShopBanner, .postBanner, .getConsumeBanner:
            return URL(string: API.ADCENTER_URL)!
        }
    }
    
    var path: String {
        switch self {
        case .getShopBanner, .postBanner:
            return "banner"
        case .getConsumeBanner:
            return "banner/ledger"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getShopBanner, .getConsumeBanner:
            return .get
        case .postBanner:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getShopBanner(let position):
            if position == "quiz" {
                parameters["access_token"] = AccessTokenManager.accessToken
            }
            parameters["os"] = "ios"
            parameters["position"] = position
        case .postBanner(let type, let id):
            parameters["type"] = type
            parameters["id"] = id
            parameters["device"] = "ios"
        case .getConsumeBanner:
            parameters["device"] = "ios"
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
