//
//  LottoService.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/25.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Moya

enum LottoService {
    case postCouponToday
    case putCouponApply(_ walkCnt: [Int], currentStep: Int)
    case postCouponBadge
    case getRoundBanners
    case deleteLotto
    
    // 스퀘어배너용
    case getToday
    case postApplySingle(curStep: Int, validDate: String)
    case postApply(curStep: Int, lottoTicket: Int)
    case getSquareBanner
    case getSSPList
    case postBannerLog(id: String, type: String)
}

// MARK: - TargetType

extension LottoService: TargetType {
    
    var baseURL: URL {
        switch self {
        case .getRoundBanners, .getToday, .postApply, .postApplySingle, .getSquareBanner, .deleteLotto:
            return URL(string: API.CASHDOC_V2_URL)!
        case .getSSPList:
            return URL(string: API.ADCENTER_URL)!
        default:
            return URL(string: API.CASHDOC_URL)!
        }
        
    }
    
    var path: String {
        switch self {
        case .postCouponToday:
            return "lotto/coupon/today"
        case .putCouponApply:
            return "lotto/coupon/applySingle" // <- 로또 한번씩 발급할 때 사용
        case .postCouponBadge:
            return "lotto/coupon/badge"
        case .getRoundBanners:
            return "lotto/round/banners"
            // new api
        case .getToday:
            return "lotto/coupon/today"
        case .postApplySingle:
            return "lotto/coupon/applySingle"
        case .postApply:
            return "lotto/coupon/apply"
        case .getSquareBanner:
            return "lotto/squareBanner"
        case .getSSPList:
            return "ad/squareBanner"
        case .postBannerLog:
            return "banner/log"
        case .deleteLotto:
            return "lotto/coupon/reset"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .postCouponToday, .postCouponBadge, .postApplySingle, .postApply, .postBannerLog:
            return .post
        case .putCouponApply:
            return .put
        case .getRoundBanners, .getToday, .getSquareBanner, .getSSPList:
            return .get
        case .deleteLotto:
            return .delete
        }
    }
    
    var sampleData: Data {
        return """
            {
                "result": {
                    "walkCoupon": [],
                    "todayCoupons": 0,
                    "roundCoupons": 0,
                    "badgeCoupons": 0,
                    "roundNumber": 0,
                    "raffleOpen": false,
                    "raffleDate": "",
                    "closeDate": "",
                    "todayFirst": false
                }
            }
            """.utf8Encoded
    }
    
    var task: Task {
        var parameters = [String: Any]()
        switch self {
        case .getSSPList:
            if let userGroup = UserManager.shared.userGroup {
                parameters["key"] = userGroup
            }
            
        case .postCouponBadge, .getRoundBanners, .getToday, .getSquareBanner:
            parameters["access_token"] = AccessTokenManager.accessToken
            
        case .postCouponToday:
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["autoTodayCheck"] = false
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .putCouponApply(let walkcnt, let currentStep):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["walkCount"] = walkcnt
            if walkcnt.contains(0) {
                parameters["couponType"] = 1
            } else {
                parameters["couponType"] = 2
            }
            parameters["couponCount"] = 1
            parameters["directUse"] = 1
            parameters["currentStep"] = currentStep
            
        case .postApplySingle(let curStep, let validDate):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["currentStep"] = curStep
            parameters["validDate"] = validDate
            
        case .postApply(let curStep, let lottoTicket):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["currentStep"] = curStep
            parameters["count"] = lottoTicket
            
        case .postBannerLog(let id, let type):
            parameters["access_token"] = AccessTokenManager.accessToken
            parameters["id"] = id
            parameters["type"] = type
        case .deleteLotto:
            parameters["access_token"] = AccessTokenManager.accessToken
            
        }
        return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
    }
    
    var headers: [String: String]? {
        return API.CASHDOC_HEADERS
    }
    
}
