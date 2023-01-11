//
//  ConsumeService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum ConsumeService {
    case upload(value: String, date: String)
    case getList(date: String)
    case getCategory
}

// MARK: - TargetType

extension ConsumeService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .upload:
            return "consume/upload"
        case .getList:
            return "consume/getList"
        case .getCategory:
            return "consume/getCategory"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .upload:
            return .post
        case .getList, .getCategory:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .upload(let value, let date):
            parameters["value"] = value
            parameters["date"] = date
        case .getList(let date):
            parameters["date"] = date
        default:
            break
        }
        parameters["access_token"] = AccessTokenManager.accessToken
        return .requestParameters(parameters: parameters,
                                  encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
