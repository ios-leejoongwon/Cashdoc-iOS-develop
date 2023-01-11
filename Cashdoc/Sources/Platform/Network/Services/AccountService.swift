//
//  AccountService.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum AccountService {
    case postAccount(type: LoginType, id: String, accessToken: String, idToken: String?, username: String?, profileURL: String?, email: String?, gender: String?, privacyInformationAgreed: Bool?)
    case putAccount(accessToken: String, username: String?, profileURL: String?, email: String?)
    case putAccountAgreed(privacyInformationAgreed: Bool?, sensitiveInformationAgreed: Bool?, healthServiceAgreed: Bool?)
    case putAccountByUserModel(params: [String: Any])
    case updateFCMToken(fcmToken: String)
    case deleteAccount
    case postAccountFind(type: LoginType, id: String)
}

// MARK: - TargetType

extension AccountService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .postAccount:
            return "account"
        case .putAccount, .putAccountAgreed:
            return "account"
        case .putAccountByUserModel:
            return "account/personal"
        case .updateFCMToken:
            return "account"
        case .deleteAccount:
            return "account"
        case .postAccountFind:
            return "account/find"
            
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postAccount:
            return .post
        case .putAccount, .putAccountAgreed:
            return .put
        case .putAccountByUserModel:
            return .put
        case .updateFCMToken:
            return .put
        case .deleteAccount:
            return .delete
        case .postAccountFind:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .postAccount(let idType, let id, let accessToken, let idToken, let username, let profileURL, let email, let gender, let privacyInformationAgreed):
            parameters["idType"] = idType.rawValue
            parameters["id"] = id
            parameters["accessToken"] = accessToken
            if let idToken = idToken {
                parameters["idToken"] = idToken
            }
            parameters["device"] = "ios"
            if let username = username {
                parameters["nickname"] = username
            }
            if let profileURL = profileURL {
                parameters["profileUrl"] = profileURL
            } else {
                parameters["profileUrl"] = ""
            }
            if let email = email {
                parameters["email"] = email
            } else {
                parameters["email"] = ""
            }
            if let gender = gender {
                parameters["gender"] = gender
            } else {
                parameters["gender"] = ""
            }
            
            if let privacyInformationAgreed = privacyInformationAgreed {
                parameters["privacyInformationAgreed"] = privacyInformationAgreed
            } else {
                parameters["privacyInformationAgreed"] = false
            }
            Log.al(parameters)
            // #if !DEBUG
            parameters["uuid"] = GlobalFunction.getDeviceID()
            // #endif
            
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .putAccountAgreed(let privacyInformationAgreed, let sensitiveInformationAgreed, let healthServiceAgreed):
            parameters["access_token"] = AccessTokenManager.accessToken

            if let privacyInformationAgreed = privacyInformationAgreed {
                parameters["privacyInformationAgreed"] = privacyInformationAgreed
            }
            
            if let sensitiveInformationAgreed = sensitiveInformationAgreed {
                parameters["sensitiveInformationAgreed"] = sensitiveInformationAgreed
                
            } 
            if let healthServiceAgreed = healthServiceAgreed {
                parameters["healthServiceAgreed"] = healthServiceAgreed
                
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .putAccount(let accessToken, let username, let profileURL, let email):
            parameters["access_token"] = accessToken
            parameters["device"] = "ios"
            if let username = username {
                parameters["nickname"] = username
            }
            if let profileURL = profileURL {
                parameters["profileUrl"] = profileURL
            }
            if let email = email {
                parameters["email"] = email
            }
             
        case .putAccountByUserModel(let params):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["device"] = "ios"
            params.forEach { (key: String, value: Any) in
                parameters[key] = value
            }
            
        case .updateFCMToken(let fcmToken):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["pushId"] = fcmToken
            
        case .deleteAccount:
            parameters["access_token"] = AccessTokenManager.accessToken
            
        case .postAccountFind(let type, let id):
            if type == .apple {
               parameters["idType"] = "apple"
            } else if type == .kakao {
                parameters["idType"] = "kakao"
            }
            parameters["id"] = id
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
