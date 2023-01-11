//
//  CouponService.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 18/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Moya

enum CouponService {
    case getCouponList(_ page: Int)
    case getUsedCouponList(_ page: Int)
}

// MARK: - TargetType

extension CouponService: TargetType {
    
    var baseURL: URL {
        return URL(string: API.CASHDOC_URL)!
    }
    
    var path: String {
        switch self {
            case .getCouponList, .getUsedCouponList:
                return "coupon/list"
        }
    }
    
    var method: Moya.Method {
        switch self {
            case .getCouponList, .getUsedCouponList:
                return .get
        }
    }
    
    var sampleData: Data {
        return "".utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        
        switch self {
            case .getCouponList(let page):
                parameters["access_token"] = AccessTokenManager.accessToken
                parameters["page"] = page
                parameters["couponState"] = 0
            case .getUsedCouponList(let page):
                parameters["access_token"] = AccessTokenManager.accessToken
                parameters["page"] = page
                parameters["couponState"] = 1
        }
        
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
}
