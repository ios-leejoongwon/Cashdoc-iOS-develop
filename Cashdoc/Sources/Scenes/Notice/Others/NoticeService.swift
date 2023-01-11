//
//  NoticeService.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/06/15.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum NoticeType: String {
    case load, view, click
}

enum NoticeService {
    case getNotice
    case postNoticeLog(ids: [String], type: NoticeType)
    case getCashwalkNotice
}

// MARK: - TargetType

extension NoticeService: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getNotice:
            return URL(string: API.CASHDOC_URL)!
        case .postNoticeLog:
            return URL(string: API.CASHDOC_URL)!
        case .getCashwalkNotice:
            return URL(string: API.SETTING_IMAGE_URL)!
        }
    }
    
    var path: String {
        switch self {
        case .getNotice:
            return "notice"
        case .getCashwalkNotice:
            if let rawValue = UserDefaults.standard.string(forKey: DebugUserDefaultsKey.kDebugAPIServer.rawValue),
                let serverType = APIServer(rawValue: rawValue) {
                return serverType.popupCWNoticePath

            } else {
                return APIServer.production.popupCWNoticePath

            }
        case .postNoticeLog:
            return "notice/log"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getNotice, .getCashwalkNotice:
            return .get
        case .postNoticeLog:
            return .post
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var params: [String: Any] = [:]
        switch self { 
        case .getNotice, .getCashwalkNotice:
            return .requestPlain
        case let .postNoticeLog(ids, type):
            params["access_token"] = AccessTokenManager.accessToken
            params["ids"] = ids
            params["type"] = type.rawValue
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        switch self {
        case .getNotice:
            return ["version": getAppVersion(), "device": "ios", "deviceId": GlobalFunction.getDeviceID()]
        default:
            return API.CASHDOC_HEADERS
        }
    }
    
}
