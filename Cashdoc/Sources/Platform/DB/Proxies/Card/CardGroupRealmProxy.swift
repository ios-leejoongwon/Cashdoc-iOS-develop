//
//  CardGroupRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct CardGroupRealmProxy<RealmManager: CardRealmManager>: RealmProxiable {
    
    // MARK: - Internal methods
    
    func append(_ cardGroup: CheckCardByGroup, clearHandler: ((Realm) -> Void)? = nil, completion: (() -> Void)? = nil) {
        rm.transaction(isSync: false, writeHandler: { (realm) in
            
            if !cardGroup.card6.result.isEmpty, cardGroup.card6.result.uppercased() != "FAIL" {
                cardGroup.card6.list.forEach {realm.add($0, update: .all)}
            }
            if !cardGroup.card2.result.isEmpty, cardGroup.card2.result.uppercased() != "FAIL" {
                cardGroup.card2.list.forEach {realm.add($0, update: .all)}
            }
            if let card3Data = cardGroup.card3, let payDate = card3Data.payDate, payDate.count > 0 {
                realm.add(card3Data, update: .all)
            }
            if let card1Data = cardGroup.card1 {
                if !card1Data.result.isEmpty, card1Data.result.uppercased() != "FAIL" {
                    card1Data.list.forEach {realm.add($0, update: .all)}
                }
            }
        }, completion: { (_, _) in
            completion?()
        })
    }
    
}
