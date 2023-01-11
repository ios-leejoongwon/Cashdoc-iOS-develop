//
//  PushService.swift
//  Cashdoc
//
//  Created by Taejune Jung on 31/03/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum PushService {
    case pushToken(code: String)
    case pushTopic(topic: String)
}

// MARK: - TargetType

extension PushService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
        case .pushToken:
            return "test/push"
        case .pushTopic:
            return "test/push/topic"
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
        case .pushToken(let code):
            parameters["code"] = code
            parameters["type"] = "QUIZ"
        case .pushTopic(let topic):
            #if DEBUG || INHOUSE
            parameters["topic"] = "cashdoc_test_quiz_topic_\(topic)"
            #else
            parameters["topic"] = "cashdoc_quiz_topic_\(topic)"
            #endif
            parameters["type"] = "QUIZ"
            parameters["deepLink"] = "cdapp://?quiz=1585644591343"
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
}
