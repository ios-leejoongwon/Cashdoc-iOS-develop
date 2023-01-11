//
//  CheckCardPaymentDetails.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

// 카드_결제예정조회
struct CheckCardPaymentDetails: Decodable {
    let result: String
    let errMsg: String?
    let errDoc: String?
    let eCode: String?
    let eTrack: String?
    let list: [CheckCardPaymentDetailsList]
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
        case errMsg = "ERRMSG"
        case errDoc = "ERRDOC"
        case eCode = "ECODE"
        case eTrack = "ETRACK"
        case list = "LIST"
    }
}
