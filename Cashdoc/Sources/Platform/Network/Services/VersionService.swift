//
//  VersionService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/11/06.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum VersionService {
    case getVersion
    case getBannerType
}

// MARK: - TargetType

extension VersionService: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getVersion:
            return URL(string: API.IMAGES_URL)!
        case .getBannerType:
            return URL(string: API.CASHDOC_URL)!
        }
    }
    
    var path: String {
        switch self {
        case .getVersion:
            if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
                let serverType = APIServer(rawValue: rawValue) {
                return serverType.versionurl
            } else {
                return APIServer.production.versionurl
            }
        case .getBannerType:
            return "banner/type"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getVersion, .getBannerType:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }

    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getBannerType:
            parameters["access_token"] = AccessTokenManager.accessToken
        default:
            break
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
