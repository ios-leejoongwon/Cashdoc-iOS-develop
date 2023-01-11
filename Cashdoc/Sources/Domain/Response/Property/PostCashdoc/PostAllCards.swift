//
//  PostAllCards.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

struct PostAllCards: Codable {
    let ERRMSG: String?
    let ECODE: String?
    let LIST: [PostAllCardsList]
    let requestFCODE: String?
}

struct PostAllCardsList: Codable {
    let CARDNAME: String?
    let CARDNUM: String?
    let CARDISSUE: String?
}
