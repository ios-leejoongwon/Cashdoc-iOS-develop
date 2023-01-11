//
//  AccountTransactionRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

import SwiftyJSON

struct AccountTransactionRealmProxy<RealmManager: AccountRealmManager>: RealmProxiable {

    // MARK: - Properties
    
    var allLists: RealmQuery<CheckAccountTransactionDetails> {
        return query(sortProperty: "openDate", ordering: .descending)
    }
    
    var allDetailLists: RealmQuery<CheckAccountTransactionDetailsList> {
        return query(sortProperty: "tranDate", ordering: .descending)
    }
    
    // MARK: - Internal methods
    
    func append(_ transaction: CheckAccountTransactionDetails) {
        rm.transaction(writeHandler: { (realm) in
            realm.add(transaction, update: .all)
        }, completion: { (_, _) in
        })
    }
    
    func updateTransactionDetailList(id: String?, json: JSON?) {
        guard let id = id, let json = json, let transaction = transactionFromIdentity(id) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.category = json["category"].stringValue
            transaction.subCategory = json["subCategory"].stringValue
            transaction.jukyo = json["contents"].stringValue
            transaction.expedient = json["expedient"].stringValue
            transaction.inBal = json["income"].stringValue.toInt
            transaction.outBal = json["outgoing"].stringValue.toInt
            if let dateString = json["date"].string {
                transaction.tranDate = dateString.simpleDateFormat("yyyyMMdd")
            }
            transaction.tranDt = json["time"].stringValue
            transaction.memo = json["memo"].stringValue
            realm.add(transaction, update: .all)
        })
    }
    
    func updateTransactionDetail(_ transactionDetail: CheckAccountTransactionDetails, fCodeName: String) {
        let lists = List<CheckAccountTransactionDetailsList>()
        for list in transactionDetail.list {
            list.acctKind = transactionDetail.acctKind
            if let transact = AccountTransactionRealmProxy().transactionFromIdentity(list.identity) {
                if !transact.tranDate.simpleDateFormat("yyyyMMdd").isEmpty, !transact.tranDt.isEmpty {
                    lists.append(transact)
                }
            } else {
                if !list.tranDate.simpleDateFormat("yyyyMMdd").isEmpty, !list.tranDt.isEmpty {
                    lists.append(list)
                }
            }
        }
        transactionDetail.fCodeName = fCodeName
        transactionDetail.list = lists
        transactionDetail.originList.forEach { $0.number = transactionDetail.number }
        AccountTransactionRealmProxy().append(transactionDetail)
    }
    
    func updateCategoryTransactionDetailList(item: ConsumeContentsItem, changeCategory: String, changeSubCategory: String) {
        guard let transaction = transactionFromIdentity(item.identity) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.category = changeCategory
            transaction.subCategory = changeSubCategory
            if changeCategory == "지출" && (item.category == "지출" || item.category == "기타") {
                if item.outgoing == 0 {
                    transaction.outBal = item.income
                } else {
                    transaction.outBal = item.outgoing
                }
                transaction.inBal = 0
            } else if changeCategory == "지출" && (item.category == "수입") {
                transaction.outBal = item.income
                transaction.inBal = 0
            } else {
                if item.outgoing == 0 {
                    transaction.inBal = item.income
                } else {
                    transaction.inBal = item.outgoing
                }
                transaction.outBal = 0
            }
            realm.add(transaction, update: .all)
        })
    }
    
    func updatePointTransactionDetailList(id: String, point: Int) {
        guard let transaction = transactionFromIdentity(id) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.touchCount = point
            if point >= 20 {
                transaction.isTouchEnabled = false
            } else {
                transaction.isTouchEnabled = true
            }
            realm.add(transaction, update: .all)
        })
    }
    
    func transactionFromName(_ name: String) -> CheckAccountTransactionDetailsList? {
        return query(filter: "jukyo == '\(name)'").results.first
    }
    
    func transactionFromIdentity(_ identity: String) -> CheckAccountTransactionDetailsList? {
        return query(filter: "identity == '\(identity)'").results.first
    }
    
    func containsFromId(_ id: String?) -> Bool {
        guard let id = id, transactionFromIdentity(id) != nil else { return false }
        return true
    }
    
    func removeTransactionDetailList(item: ConsumeContentsItem) {
        guard let transaction = findRealmDate(item) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.isDeleted = true
            realm.add(transaction, update: .all)
        })
    }
    
    func findRealmDate(_ item: ConsumeContentsItem) -> CheckAccountTransactionDetailsList? {
        return query(filter: "identity == '\(item.identity)'").results.first
    }
    
    func removeTransactionDetailList(item: ConsumeDataModel) {
        guard let transaction = transactionFromIdentity(item.identity) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.isDeleted = true
            realm.add(transaction, update: .all)
        })
    }
    
    func findRealmDate(_ item: ConsumeDataModel) -> CheckAccountTransactionDetailsList? {
        return query(filter: "identity == '\(item.identity)'").results.first
    }
    
    func findOriginList(number: String) -> Results<CheckAccountTransactionDetailsListOrigin> {
        return query(CheckAccountTransactionDetailsListOrigin.self,
                     filter: "number == '\(number)'", sortProperty: "tranDt", ordering: .descending).results
    }
    
    func findDetailsWith(number: String) -> CheckAccountTransactionDetails? {
        guard let result = query(CheckAccountTransactionDetails.self, filter: "number == '\(number)'").results.first else { return nil }
        return result
    }
    
}
