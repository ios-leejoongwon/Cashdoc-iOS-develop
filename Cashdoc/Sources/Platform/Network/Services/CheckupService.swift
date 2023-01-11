//
//  CheckupService.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/26.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum CheckupService {
    case postCheckup(value: String)
    case getCheckup
    case getRisk
    case postCheckupCallback(callbackId: String, _ isTest: Bool = false)
    case postCheckupCert(loginOption: String, birth: String, userName: String, phoneNum: String, telecomType: String, _ isTest: Bool = false)
}

// MARK: - TargetType

extension CheckupService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .postCheckup:
            return "checkup"
        case .getCheckup:
            return "checkup"
        case .getRisk:
            return "checkup/analysis/risk"
        case .postCheckupCallback:
            return "checkup/cert/callback"
        case .postCheckupCert:
            return "checkup/cert"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postCheckup, .postCheckupCallback, .postCheckupCert:
            return .post
        case .getCheckup, .getRisk:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postCheckup(let value):
            parameters["value"] = value
            parameters["access_token"] = AccessTokenManager.accessToken
        case .getCheckup:
            parameters["access_token"] = AccessTokenManager.accessToken
        case .getRisk:
            let convertDate = GlobalDefine.shared.checkDateString?.convertDateFormat(beforeFormat: "yyyyMMdd", afterFormat: "yyyy-MM-dd") ?? ""
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["date"] = convertDate
        case .postCheckupCallback(let callbackId, let isTest):
            parameters["callbackId"] = callbackId
            parameters["isTest"] = isTest
            parameters["access_token"] = AccessTokenManager.accessToken
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .postCheckupCert(let loginOption, let birth, let userName, let phoneNum, let telecomType, let isTest):
            parameters["loginOption"] = loginOption
            parameters["birth"] = birth
            parameters["username"] = userName
            parameters["phoneNumber"] = phoneNum
            if !telecomType.isEmpty {
                parameters["telecomType"] = telecomType
            }
            parameters["isTest"] = isTest
            parameters["access_token"] = AccessTokenManager.accessToken
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
