//
//  CardRealmManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

final class CardRealmManager: RealmManageable {
    
    var isUseInMemory: Bool {
        return false
    }
    
    var schemaVersion: UInt64 {
        return 4
    }
    
    var fileName: String {
        return "card"
    }
    
    var objectTypes: [Object.Type]? {
        return [CheckAllCardsList.self,
                CheckCardApprovalDetailsList.self,
                CheckCardBill.self,
                CheckCardBillSumaryList.self,
                CheckCardBillDetailList.self,
                CheckCardPaymentDetailsList.self,
                CheckCardPaymentDetailsPayestList.self,
                CheckCardLoanDetailsList.self]
    }
    
}
