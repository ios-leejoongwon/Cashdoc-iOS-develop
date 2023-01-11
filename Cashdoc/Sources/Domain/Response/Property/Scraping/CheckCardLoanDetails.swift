//
//  CheckCardLoanDetails.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

// 카드_대출내역조회
struct CheckCardLoanDetails: Decodable {
    let result: String
    let errMsg: String?
    let errDoc: String?
    let eCode: String?
    let eTrack: String?
    let payDate: String?
    let payAmt: String?
    let list: [CheckCardLoanDetailsList]
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
        case errMsg = "ERRMSG"
        case errDoc = "ERRDOC"
        case eCode = "ECODE"
        case eTrack = "ETRACK"
        case payDate = "PAYDATE"
        case payAmt = "PAYAMT"
        case list = "LIST"
    }
}
