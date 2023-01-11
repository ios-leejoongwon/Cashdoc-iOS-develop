//
//  PropertyTotalResultType.swift
//  Cashdoc
//
//  Created by Oh Sangho on 16/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RealmSwift

enum PropertyBankInfoType {
    case 은행사명
    case 은행별총액
}

struct PropertyTotalResult {
    var totalAmount: String
    var bankInfo: [String: String]?
    let scrapingInfoList: Results<LinkedScrapingInfo>
    
    init(totalAmount: String,
         bankInfo: [String: String],
         scrapingInfoList: Results<LinkedScrapingInfo>) {
        
        self.totalAmount = totalAmount
        self.bankInfo = bankInfo
        self.scrapingInfoList = scrapingInfoList
    }
    
    init(totalAmount: String,
         scrapingInfoList: Results<LinkedScrapingInfo>) {
        self.totalAmount = totalAmount
        self.bankInfo = nil
        self.scrapingInfoList = scrapingInfoList
    }
    
}
