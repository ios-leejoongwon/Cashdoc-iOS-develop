//
//  CardLoanListRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct CardLoanListRealmProxy<RealmManager: CardRealmManager>: RealmProxiable {
    
    // MARK: - Properties
    
    var allListsForPropertyLoan: RealmQuery<CheckCardLoanDetailsList> {
        return query(sortProperty: "intCurAmt", ordering: .descending)
    }
    
    // MARK: - Internal methods
    
    func append(_ loan: CheckCardLoanDetailsList) {
        rm.transaction(writeHandler: { (realm) in
            realm.add(loan, update: .all)
        })
    }
    
    func appendCardLoanList(_ loanList: [CheckCardLoanDetailsList],
                            fCode: FCode? = nil,
                            clearHandler: ((Realm) -> Void)? = nil,
                            completion: (() -> Void)? = nil) {
        CardRealmManager().transaction(isSync: false, writeHandler: { (realm) in
            clearHandler?(realm)
            loanList.forEach({ (loan) in
                if let fCode = fCode {
                    loan.fCodeName = fCode.rawValue
                    loan.fCodeIndex = fCode.index
                }
                realm.add(loan, update: .all)
            })
        }, completion: { (_, _) in
            if let fCode = fCode {
                UserDefaults.standard.set(true, forKey: fCode.keys.rawValue)
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedProperty.rawValue)
                LinkedScrapingV2InfoRealmProxy().delete(fCodeName: fCode.rawValue)
            }
            completion?()
        })
    }
    
    func clear(completion: (() -> Void)? = nil) {
        rm.transaction(isSync: false, writeHandler: { (realm) in
            realm.delete(self.query(CheckCardLoanDetailsList.self).results)
        }, completion: { (_, _) in
            completion?()
        })
    }
    
    func card(identity: String) -> Results<CheckCardLoanDetailsList> {
        return query(filter: "identity == '\(identity)'").results
    }
    
}
