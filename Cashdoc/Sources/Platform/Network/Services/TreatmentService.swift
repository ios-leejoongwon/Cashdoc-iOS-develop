//
//  TreatmentService.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/02/06.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum TreatmentService {
    case postTreatment(treat: String, jinds: String)
    case getTreatment
    case postTreatmentCallback(callbackId: String, _ isTest: Bool = false)
    case postTreatmentCert(loginOption: String, birth: String, userName: String, phoneNum: String, telecomType: String, _ isTest: Bool = false)
}

// MARK: - TargetType

extension TreatmentService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .postTreatmentCallback:
            return "treatment/cert/callback"
        case .postTreatmentCert:
            return "treatment/cert"
        default:
            return "treatment"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postTreatment, .postTreatmentCallback, .postTreatmentCert:
            return .post
        case .getTreatment:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postTreatment(let value01, let value02):
            parameters["treat"] = value01
            parameters["jinds"] = value02
            parameters["access_token"] = AccessTokenManager.accessToken
        case .getTreatment:
            parameters["access_token"] = AccessTokenManager.accessToken
        case .postTreatmentCallback(let callbackId, let isTest):
            parameters["callbackId"] = callbackId
            parameters["isTest"] = isTest
            parameters["access_token"] = AccessTokenManager.accessToken
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .postTreatmentCert(let loginOption, let birth, let userName, let phoneNum, let telecomType, let isTest):
            parameters["loginOption"] = loginOption
            parameters["birth"] = birth
            parameters["username"] = userName
            parameters["phoneNumber"] = phoneNum
            parameters["telecomType"] = telecomType
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
