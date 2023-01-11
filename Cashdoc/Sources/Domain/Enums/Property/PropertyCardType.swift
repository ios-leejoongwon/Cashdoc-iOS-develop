//
//  PropertyCardType.swift
//  Cashdoc
//
//  Created by Oh Sangho on 11/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum PropertyCardType: String {
    case 계좌
    case 카드
    case 대출
    case 신용
    case 보험
    case 캐시
    case 기타자산 = "기타 자산"
    
    var image: String {
        switch self {
        case .계좌:
            return "icAccountBlue"
        case .카드:
            return "icCardBlue"
        case .대출:
            return "icLoanBlue"
        case .신용:
            return "icCreditBlue"
        case .보험:
            return "icHealthBlue"
        case .캐시:
            return "icSpendBlue"
        case .기타자산:
            return "icCashBlue"
        }
    }
    
    var description: String {
        switch self {
        case .계좌:
            return "은행 계좌 한 번에 불러오기"
        case .카드:
            return "사용 금액 한 번에 불러오기"
        case .대출:
            return "대출 내역 한 번에 불러오기"
        case .신용:
            return "무료로 내 신용상태 확인하기"
        case .보험:
            return "내 건강 상태 확인하기"
        case .캐시:
            return ""
        case .기타자산:
            return "보유한 다양한 자산 기록하기"
        }
    }
    
    // 자산 post 보낼 때, type 구분용.
    var serviceType: String {
        switch self {
        case .계좌:
            return "account"
        case .카드:
            return "card"
        case .대출:
            return "loan"
        case .신용:
            return "credit"
        case .보험:
            return "insurance"
        case .캐시:
            return "cash"
        case .기타자산:
            return "etc"
        }
    }
    
}
