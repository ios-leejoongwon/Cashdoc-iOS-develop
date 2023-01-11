//
//  CardListRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct CardListRealmProxy<RealmManager: CardRealmManager>: RealmProxiable {
    
    // MARK: - Internal methods
    
    var allLists: RealmQuery<CheckAllCardsList> {
        return query()
    }
    
    func append(_ card: CheckAllCardsList) {
        rm.transaction(writeHandler: { (realm) in
            realm.add(card, update: .all)
        })
    }
    
    func appendCardList(_ cardList: [CheckAllCardsList], fCode: String?, clearHandler: ((Realm) -> Void)? = nil, completion: (() -> Void)? = nil) {
        rm.transaction(isSync: false, writeHandler: { (realm) in
            clearHandler?(realm)
            cardList.forEach({ (card) in
                card.fCode = fCode
                realm.add(card, update: .all)
            })
        }, completion: { (_, _) in
            completion?()
        })
    }
    
}
