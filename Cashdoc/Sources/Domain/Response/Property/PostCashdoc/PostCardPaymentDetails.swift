//
//  PostCardPaymentDetails.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PostCardPaymentDetails: Codable {
    let ERRMSG: String
    let ECODE: String?
    let LIST: [PostCardPaymentDetailsList]
    let requestFCODE: String?
}

struct PostCardPaymentDetailsList: Codable {
    let ESTDATE: String?
    let ESTAMT: String?
    let PAYESTLIST: [PostCardPaymentDetailsPayestList]
}

struct PostCardPaymentDetailsPayestList: Codable {
    let ASALEDATE: String?
    let CARDNUMBER: String?
    let MBRMCHNAME: String?
    let PAYOPTION: String?
    let ASALEAMT: String?
    let DISCAMT: String?
    let ASKNTH: String?
    let PRCPL: String?
    let FEE: String?
    let LATEFEE: String?
    let SAVEPOINT: String?
    let RMAINNTH: String?
    let RMAINPRCPL: String?
    let DISCCONTENT: String?
    let CARDISSUE: String?
}
