//
//  CpqService.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import Moya

enum CpqService {
    case getCpqList(live: Int?, lastDate: String?)
    case getCpqQuizList(id: String)
    case postAnswer(quizId: String, questionId: String, answer: String, deviceId: String)
}

// MARK: - TargetType

extension CpqService: TargetType {
    
    var baseURL: URL {
        #if CASHWALK
        return URL(string: API_URL)!
        #else
        return URL(string: API.CASHDOC_URL)!
        #endif
    }
    
    var path: String {
        switch self {
        case .getCpqList:
            #if CASHWALK
            return "quiz/list/coming"
            #else
            return "quiz/list/1"
            #endif
        case .getCpqQuizList(let id):
            return "quiz/\(id)"
        case .postAnswer:
            return "quiz/answer"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getCpqList, .getCpqQuizList:
            return .get
        case .postAnswer:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()

        #if CASHWALK
        let token = UserDefaults.standard.string(forKey: UserDefaultsKey.kAccessToken) ?? ""
        let deviceId = AppGlobalFunc.getUUIdFromKeyChain()
        #else
        let token = AccessTokenManager.accessToken
        let deviceId = GlobalFunction.getDeviceID()
        #endif
        
        switch self {
        case .getCpqList(let live, let lastDate):
//            Log.al("getCpqList = \(lastDate)")
            parameters["access_token"] = token
            if let getlive = live {
                parameters["live"] = getlive
            }
//            #if CASHWALK
            if let getlastDate = lastDate {
                parameters["lastDate"] = getlastDate
            }
//            #endif
        case .getCpqQuizList:
            parameters["access_token"] = token
            parameters["deviceId"] = deviceId
        case .postAnswer(let quizId, let questionId, let answer, let deviceId):
            parameters["access_token"] = token
            parameters["quizId"] = quizId
            parameters["questionId"] = questionId
            parameters["answer"] = answer
            parameters["deviceId"] = deviceId
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        #if CASHWALK
        return nil
        #else
        return API.CASHDOC_HEADERS
        #endif
    }
}
