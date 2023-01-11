//
//  CardBillRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct CardBillRealmProxy<RealmManager: CardRealmManager>: RealmProxiable {
    
    // MARK: - Internal methods
    
    func append(_ bill: CheckCardBill) {
        rm.transaction(writeHandler: { (realm) in
            realm.add(bill, update: .all)
        })
    }
    
}
