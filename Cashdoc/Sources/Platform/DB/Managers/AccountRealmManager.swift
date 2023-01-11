//
//  AccountRealmManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 13/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

final class AccountRealmManager: RealmManageable {
    
    var isUseInMemory: Bool {
        return false
    }
    
    var schemaVersion: UInt64 {
        return 8
    }
    
    var fileName: String {
        return "account"
    }
    
    var objectTypes: [Object.Type]? {
        return [CheckAllAccountInBankList.self,
                CheckAccountTransactionDetails.self,
                CheckAccountTransactionDetailsList.self,
                CheckAccountTransactionDetailsListOrigin.self]
    }
    
}
