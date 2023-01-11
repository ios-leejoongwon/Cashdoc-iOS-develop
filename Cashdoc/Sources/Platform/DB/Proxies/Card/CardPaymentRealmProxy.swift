//
//  CardPaymentRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct CardPaymentRealmProxy<RealmManager: CardRealmManager>: RealmProxiable {
    
    // MARK: - Internal methods
    var allList: RealmQuery<CheckCardPaymentDetailsPayestList> {
        return query(sortProperty: "aSaleDate", ordering: .descending)
    }
    
    var allLists: RealmQuery<CheckCardPaymentDetailsList> {
        return query(sortProperty: "fCodeName", ordering: .ascending)
    }
    
    var allListsForPropertyCard: RealmQuery<CheckCardPaymentDetailsList> {
        return query(sortProperty: "intEstAmt", ordering: .descending)
    }
    
    func appendEmpty(fCode: FCode? = nil,
                     clearHandler: ((Realm) -> Void)? = nil) {
        rm.transaction(isSync: false,
                       writeHandler: { (realm) in
                        clearHandler?(realm)
                        if let fCode = fCode {
                            realm.add(CheckCardPaymentDetailsList(fCode: fCode, empty: "0"), update: .all)
                        }
        }, completion: { (_, _) in
            if let fCode = fCode {
                UserDefaults.standard.set(true, forKey: fCode.keys.rawValue)
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedProperty.rawValue)
            }
        })
    }
    
    func appendList(_ paymentList: [CheckCardPaymentDetailsList],
                    fCode: FCode? = nil,
                    clearHandler: ((Realm) -> Void)? = nil,
                    completion: (() -> Void)? = nil) {
        
        rm.transaction(isSync: false, writeHandler: { (realm) in
            clearHandler?(realm)
            paymentList.forEach { (payment) in
                if let fCode = fCode {
                    payment.fCodeName = fCode.rawValue
                    payment.setListFCode(fCode.rawValue)
                    payment.fCodeIndex = fCode.index
                    if let estDate = payment.estDate {
                        payment.identity = payment.setIdentity(with: estDate, fCodeName: fCode.rawValue)
                    }
                }
                
                realm.add(payment, update: .all)
            }
        }, completion: { (_, _) in
            if let fCode = fCode {
                UserDefaults.standard.set(true, forKey: fCode.keys.rawValue)
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedProperty.rawValue)
            }
            completion?()
        })
    }
    
    func appendForPost(_ cardList: [PostCardPaymentDetails],
                       clearHandler: ((Realm) -> Void)? = nil,
                       completion: (() -> Void)? = nil) {
        rm.transaction(isSync: false, writeHandler: { (realm) in
            clearHandler?(realm)
            cardList.forEach { (postCardList) in
                postCardList.LIST.forEach { (postCard) in
                    if let reqFCode = postCardList.requestFCODE,
                        let fCode = FCode.getFCode(with: reqFCode),
                        let cardList = try? CheckCardPaymentDetailsList(postCardList: postCard) {
                        
                        cardList.fCodeName = fCode.rawValue
                        cardList.setListFCode(fCode.rawValue)
                        cardList.fCodeIndex = fCode.index
                        if let estDate = cardList.estDate {
                            cardList.identity = cardList.setIdentity(with: estDate, fCodeName: fCode.rawValue)
                        }
                        
                        realm.add(cardList, update: .all)
                    }
                }
            }
        }, completion: { (_, _) in
            completion?()
        })
    }
    
    // 자산 연결 해제 시, 해당 카드 자산 정보 한번에 제거 및 UserDefaults 상태 변경 위한 delete
    func deleteForUnLinked(fCodeName: String, completion: SimpleCompletion? = nil) {
        rm.transaction(writeHandler: { (realm) in
            realm.delete(self.query(CheckCardPaymentDetailsList.self, filter: "fCodeName == '\(fCodeName)'").results)
            realm.delete(self.query(CheckCardPaymentDetailsPayestList.self, filter: "fCodeName == '\(fCodeName)'").results)
            realm.delete(self.query(CheckCardLoanDetailsList.self, filter: "fCodeName == '\(fCodeName)'").results)
        }, completion: { (_, _) in
            if let key = FCode(rawValue: fCodeName)?.keys {
                UserDefaults.standard.set(false, forKey: key.rawValue)
                UserDefaultsManager.checkIsPropertyUnLinked()
            }
            LinkedScrapingV2InfoRealmProxy().delete(fCodeName: fCodeName)
            completion?()
        })
    }
    
    func card(identity: String) -> RealmQuery<CheckCardPaymentDetailsList> {
        return query(filter: "identity == '\(identity)'")
    }
    
    func cardListForDetail(identity: String) -> RealmQuery<CheckCardPaymentDetailsPayestList> {
        return query(filter: "identity == '\(identity)'")
    }
    
    func getPaymentDetails() -> RealmQuery<CheckCardPaymentDetailsList> {
        return query()
    }
    
}
