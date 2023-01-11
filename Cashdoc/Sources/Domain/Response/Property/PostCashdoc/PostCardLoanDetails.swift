//
//  PostCardLoanDetails.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PostCardLoanDetails: Codable {
    let ERRMSG: String
    let ECODE: String?
    let LIST: [PostCardLoanDetailsList]
    let requestFCODE: String?
}

struct PostCardLoanDetailsList: Codable {
    let OPENDATE: String?
    let CLOSEDATE: String?
    let INTERASTRATE: String?
    let LOANAMT: String?
    let CURAMT: String?
    let PAYAMT: String?
    let INTPAYDATE: String?
    let CARDNUM: String?
    let LOANNUM: String?
    let LOANGUBUN: String?
    let LOANTITLE: String?
    let CARDISSUE: String?
}
