//
//  PincruxService.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/03/20.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum PincruxService {
    case getADInfo
}

// MARK: - TargetType

extension PincruxService: TargetType {
    
    var baseURL: URL {
        return URL(string: "https://ssl.pincrux.com/")!
    }
    
    var path: String {
        switch self {
        case .getADInfo:
            return "api/ad_info.pin"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getADInfo:
            return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .getADInfo:
            parameters["usrkey"] = UserManager.shared.userModel?.id
            parameters["pubkey"] = "910891"
            parameters["os_flag"] = "2"
            parameters["adv_id"] = GlobalFunction.getDeviceID()
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
