//
//  CertService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum CertService {
    case getAuthKey
    case getCertInfo(authKey: String)
}

// MARK: - TargetType

extension CertService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CERT_URL)!
    }
    
    var path: String {
        switch self {
        case .getAuthKey:
            return "authKey"
        case .getCertInfo:
            return "getCert"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getAuthKey, .getCertInfo:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getAuthKey:
            parameters["serviceKey"] = SMARTCERT_SERVICEKEY
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        case .getCertInfo(let authKey):
            parameters["serviceKey"] = SMARTCERT_SERVICEKEY
            parameters["authKey"] = authKey
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
