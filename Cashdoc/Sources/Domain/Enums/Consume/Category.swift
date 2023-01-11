//
//  Category.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum CategoryType: String {
    case 지출
    case 수입
    case 기타
}

enum CategoryConverter {
    case 지출(_ outgoing: CategoryOutgoings)
    case 수입(_ income: CategoryIncomes)
    case 기타(_ etc: CategoryEtc)
    
    var image: String {
        switch self {
        case .지출(let outgoint):
            return outgoint.image
        case .수입(let income):
            return income.image
        case .기타(let etc):
            return etc.image
        }
    }
}

enum CategoryOutgoings: String {
    case 식비
    case 교통비
    case 병원약국 = "병원/약국"
    case 문화생활
    case 교육비
    case 생필품
    case 카페간식 = "카페/간식"
    case 자동차
    case 온라인쇼핑
    case 주거통신 = "주거/통신"
    case 여행숙박 = "여행/숙박"
    case 미분류
    
    var image: String {
        switch self {
        case .교육비: return "icEducationBlack"
        case .교통비: return "icBusBlack"
        case .문화생활: return "icCouponBlack"
        case .미분류: return "icQuestionMarkBlack"
        case .병원약국: return "icHealthBlack"
        case .생필품: return "icNecessariesBlack"
        case .식비: return "icMealBlack"
        case .여행숙박: return "icAirplaneBlack"
        case .온라인쇼핑: return "icShopBlack"
        case .자동차: return "icCarBlack"
        case .주거통신: return "icPropertyBlack"
        case .카페간식: return "icCafeBlack"
        }
    }
}

enum CategoryIncomes: String {
    case 월급
    case 용돈
    case 입금
    case 미분류
    
    var image: String {
        switch self {
        case .미분류: return "icQuestionMarkBlack"
        case .용돈: return "icPocketBlack"
        case .월급: return "icSalaryBlack"
        case .입금: return "icMoneyInBlack"
        }
    }
}

enum CategoryEtc: String {
    case 카드대금
    case 미분류
    
    var image: String {
        switch self {
        case .카드대금: return "icCardBlack"
        case .미분류: return "icQuestionMarkBlack"
        }
    }
}
