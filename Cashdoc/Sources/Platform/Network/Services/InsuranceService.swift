//
//  InsuranceService.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/20.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum InsuranceService {
    case postInsurance(value: String)
    case getInsurance
    case getRolling
    case getTotalInvoices
}

// MARK: - TargetType

extension InsuranceService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .postInsurance:
            return "insurance/upload"
        case .getInsurance:
            return "insurance/getList"
        case .getRolling:
            return "insurance/invoices/advertise/rolling"
        case .getTotalInvoices:
            return "insurance/invoices/advertise/total"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postInsurance:
            return .post
        case .getInsurance, .getRolling, .getTotalInvoices:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postInsurance(let value):
            parameters["value"] = value
            parameters["access_token"] = AccessTokenManager.accessToken
        case .getInsurance, .getRolling, .getTotalInvoices:
            parameters["access_token"] = AccessTokenManager.accessToken
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
