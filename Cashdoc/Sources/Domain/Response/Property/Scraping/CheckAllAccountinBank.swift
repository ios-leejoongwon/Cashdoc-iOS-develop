//
//  CheckAllAccountinBank.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

// 은행_전계좌조회
struct CheckAllAccountInBank: Decodable {
    let result: String
    let errMsg: String?
    let errDoc: String?
    let eCode: String?
    let eTrack: String?
    let acctKind: String?
    let number: String?
    let curBal: String?
    let enbBal: String?
    let acctNm: String?
    let openDate: String?
    let list: [CheckAllAccountInBankList]
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
        case errMsg = "ERRMSG"
        case errDoc = "ERRDOC"
        case eCode = "ECODE"
        case eTrack = "ETRACK"
        case acctKind = "ACCTKIND"
        case number = "NUMBER"
        case curBal = "CURBAL"
        case enbBal = "ENBBAL"
        case acctNm = "ACCTNM"
        case openDate = "OPENDATE"
        case list = "LIST"
    }
}
