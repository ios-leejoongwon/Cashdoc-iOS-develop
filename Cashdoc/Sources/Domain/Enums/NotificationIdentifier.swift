//
//  NotificationIdentifier.swift
//  Cashdoc
//
//  Created by Taejune Jung on 09/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum NotificationIdentifier: String, CaseIterable {
    case DailyRetention1200
    case DailyNotification1930
    case CardPaymentDate1200
    case Property
    case PointUpdated
    case Oquiz
    case none
    
    var contentTitle: String {
        switch self {
        case .DailyRetention1200:
            return "선물 도착"
        case .DailyNotification1930:
            return "오늘은 얼마나 썼나?"
        case .CardPaymentDate1200:
            return "카드 결제일 미리 알림"
        case .Oquiz:
            return ""
        default:
            return ""
        }
    }
    
    var contentBody: String {
        switch self {
        case .DailyRetention1200:
            return "100% 당첨되는 캐시 선물 받아가세요."
        case .DailyNotification1930:
            return "소비내역 확인하고 캐시적립해요!😄"
        case .Property:
            return "자산이 업데이트 되었어요."
        case .PointUpdated:
            return "가계부가 업데이트 되었어요."
        default:
            return ""
        }
    }
    
    var defaultsKey: String {
        switch self {
        case .DailyNotification1930:
            return UserDefaultKey.kIsConsumeReportAlarmOn.rawValue
        case .DailyRetention1200:
            return UserDefaultKey.kIsRetentionAlarmOn.rawValue
        case .CardPaymentDate1200:
            return UserDefaultKey.kIsCardPaymentDateAlarmOn.rawValue
        default:
            return ""
        }
    }
}
