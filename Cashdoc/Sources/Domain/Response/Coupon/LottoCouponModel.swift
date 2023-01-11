//
//  LottoCouponModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/09/25.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

struct LottoCouponModel {
    var roundCoupons = 0
    var badgeCoupons = 0
    var roundNumber = 0
    var todayCoupons = 0
    var raffleOpen = false
    var todayFirst = false
    var walkCoupon = [Int]()
    var raffleDate = Date()
    var closeDate = Date()
    
    init(_ json: JSON) {
        let resultJson = json["result"]
        
        roundCoupons = resultJson["roundCoupons"].intValue
        badgeCoupons = resultJson["badgeCoupons"].intValue
        roundNumber = resultJson["roundNumber"].intValue
        todayCoupons = resultJson["todayCoupons"].intValue
        raffleOpen = resultJson["raffleOpen"].boolValue
        todayFirst = resultJson["todayFirst"].boolValue
        if let getRaffle = resultJson["raffleDate"].string {
            let makeDate = getRaffle.simpleDateFormat("yyyy-MM-dd HH:mm:ss")
            raffleDate = makeDate
        }
        if let getClose = resultJson["closeDate"].string {
            let makeDate = getClose.simpleDateFormat("yyyy-MM-dd HH:mm:ss")
            closeDate = makeDate
        }
        walkCoupon = resultJson["walkCoupon"].arrayValue.map { $0.intValue }
    }
}

struct TodayModel {
    var todayCoupons = 0 // 오늘 몇장 받아갔는지
    var leftCoupons = 0 // 오늘 몇장 더 받을 수 있는지
    var clickCount = [Int]() // 몇번째 클릭에 스퀘어 배너를 보여줘야 하는지
    var roundNumber = 0
    var raffleDate = Date()
    var closeDate = Date()
    var roundCoupons = 0 // 해당 회차에서 얼마자 줬는지
    var badgeCoupons = 0
    var todayAttendance = false // 출설 로또 받았는지
    var validDate = ""
    
    init(_ resultJson: JSON) {
        let json = resultJson["result"]
        todayCoupons = json["todayCoupons"].intValue
        leftCoupons = json["leftCoupons"].intValue
        clickCount = json["clickCount"].arrayValue.map { $0.intValue }
        roundNumber = json["roundNumber"].intValue
        if let getRaffle = json["raffleDate"].string {
            let makeDate = getRaffle.simpleDateFormat("yyyy-MM-dd HH:mm:ss")
            raffleDate = makeDate
        }
        if let getClose = json["closeDate"].string {
            let makeDate = getClose.simpleDateFormat("yyyy-MM-dd HH:mm:ss")
            closeDate = makeDate
        }
        roundCoupons = json["roundCoupons"].intValue
        badgeCoupons = json["badgeCoupons"].intValue
        todayAttendance = json["todayAttendance"].boolValue
        validDate = json["validDate"].stringValue
    }
}

struct TodayApplyModel {
    let todayApplyCount: Int? // 오늘 총 몇장 발급 받았는지
    
    init(_ resultJson: JSON) {
        let json = resultJson["result"]
        todayApplyCount = json["todayApplyCount"].int
    }
}
