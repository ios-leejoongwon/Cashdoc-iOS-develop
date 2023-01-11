//
//  ManualConsumeRealmProxy.swift
//  Cashdoc
//
//  Created by Taejune Jung on 13/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

import SwiftyJSON

struct ManualConsumeRealmProxy<RealmManager: ManualConsumeRealmManager>: RealmProxiable {

    // MARK: - Properties
    
    var allLists: RealmQuery<ManualConsumeList> {
        return query(sortProperty: "date", ordering: .descending)
    }
    
    // MARK: - Internal methods
    func ApprovalFromAppNumber(_ identity: String) -> ManualConsumeList? {
        return query(filter: "identity == '\(identity)'").results.first
    }
    
    func updatePointManualDetailList(identity: String, point: Int) {
        guard let transaction = ApprovalFromAppNumber(identity) else { return }
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
    
    func append(_ transaction: ManualConsumeList) {
        rm.transaction(writeHandler: { (realm) in
            realm.add(transaction, update: .all)
        })
    }
    
    func appendManualConsumeList(_ transactionDetailList: List<ManualConsumeList>, clearHandler: ((Realm) -> Void)? = nil, completion: (() -> Void)? = nil) {
        rm.transaction(writeHandler: { (realm) in
            transactionDetailList.forEach({ (transaction) in
                if let transact = ManualConsumeRealmProxy().transactionFromIdentity(transaction.identity) {
                    realm.add(transact, update: .all)
                } else {
                    realm.add(transaction, update: .all)
                }
            })
        }, completion: { (_, _) in
            completion?()
        })
    }
    
    func updateCategoryApprovalDetailList(item: ConsumeContentsItem, changeCategory: String, changeSubCategory: String) {
        guard let transaction = transactionFromIdentity(item.identity) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.category = changeCategory
            transaction.subCategory = changeSubCategory
            if changeCategory == "지출" || changeCategory == "기타" {
                if item.outgoing == 0 {
                    transaction.outgoing = item.income
                    transaction.income = 0
                } else {
                    transaction.outgoing = item.outgoing
                    transaction.income = 0
                }
            } else if changeCategory == "수입" {
                if item.outgoing == 0 {
                    transaction.income = item.income
                    transaction.outgoing = 0
                } else {
                    transaction.income = item.outgoing
                    transaction.outgoing = 0
                }
            }
            realm.add(transaction, update: .all)
        })
    }
    
    func updateManualConsumeList(id: String?, json: JSON?) {
        guard let id = id, let json = json, let transaction = transactionFromIdentity(id) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.category = json["category"].stringValue
            transaction.subCategory = json["subCategory"].stringValue
            transaction.contents = json["contents"].stringValue
            transaction.expedient = json["expedient"].stringValue
            transaction.income = json["income"].stringValue.toInt
            transaction.outgoing = json["outgoing"].stringValue.toInt
            if let dateString = json["date"].string {
                transaction.date = dateString.simpleDateFormat("yyyyMMdd")
            }
            transaction.time = json["time"].stringValue
            transaction.memo = json["memo"].stringValue
            transaction.gb = json["gb"].stringValue
            
            realm.add(transaction, update: .all)
        })
    }
    
    func transactionFromName(_ name: String) -> ManualConsumeList? {
        return query(filter: "title == '\(name)'").results.first
    }
    
    func transactionFromIdentity(_ identity: String) -> ManualConsumeList? {
            return query(filter: "identity == '\(identity)'").results.first
    }
    
    func containsFromId(_ id: String?) -> Bool {
        guard let id = id, transactionFromIdentity(id) != nil else { return false }
        return true
    }
    
    func removeManualConsumeList(item: ConsumeContentsItem) {
        guard let transaction = transactionFromIdentity(item.identity) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.isDeleted = true
            realm.add(transaction, update: .all)
        })
    }
    
    func findRealmDate(_ item: ConsumeContentsItem) -> ManualConsumeList? {
        return query(filter: "identity == '\(item.identity)'").results.first
    }
}
