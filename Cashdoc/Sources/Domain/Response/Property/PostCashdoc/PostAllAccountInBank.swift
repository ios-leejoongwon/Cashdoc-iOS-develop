//
//  PostAllAccountInBank.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PostAllAccountInBank: Codable {
    let ERRMSG: String
    let ECODE: String?
    let LIST: [PostAllAccountInBankList]
    let requestFCODE: String?
}

struct PostAllAccountInBankList: Codable {
    let NUMBER: String?
    let ACCTKIND: String?
    let ACCTSTATUS: String?
    let CURBAL: String?
    let CURRCD: String?
    let INTERASTRATE: String?
    let INTPAYDATE: String?
    let OPENDATE: String?
    let CLOSEDATE: String?
    let LOANBAL: String?
    let LOANCURBAL: String?
}
