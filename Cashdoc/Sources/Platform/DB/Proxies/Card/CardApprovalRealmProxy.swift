//
//  CardApprovalRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

import SwiftyJSON

struct CardApprovalRealmProxy<RealmManager: CardRealmManager>: RealmProxiable {
    
    var allLists: RealmQuery<CheckCardApprovalDetails> {
        return query(sortProperty: "appDate", ordering: .descending)
    }
    
    var allDetailLists: RealmQuery<CheckCardApprovalDetailsList> {
        return query(sortProperty: "appDate", ordering: .descending)
    }
    
    // MARK: - Internal methods
    
    func append(_ approval: CheckCardApprovalDetailsList) {
        rm.transaction(writeHandler: { (realm) in
            realm.add(approval, update: .all)
        })
    }
    
    func appendApprovalList(_ approvalList: List<CheckCardApprovalDetailsList>, clearHandler: ((Realm) -> Void)? = nil, completion: (() -> Void)? = nil) {
        rm.transaction(writeHandler: { (realm) in
            approvalList.forEach({ (approval) in
                if let approvalData = self.ApprovalFromAppNumber(approval.appNo) {
                    if approvalData.category.isEmpty {
                        approvalData.category = "지출"
                    }
                    if approvalData.subCategory.isEmpty {
                        approvalData.subCategory = CategoryManager.findOutgoingSubCategory(with: approval.appFranName)
                    }
                    realm.add(approvalData, update: .all)
                } else {
                    if approval.category.isEmpty {
                        approval.category = "지출"
                    }
                    if approval.subCategory.isEmpty {
                        approval.subCategory = CategoryManager.findOutgoingSubCategory(with: approval.appFranName)
                    }
                    realm.add(approval, update: .all)
                }
            })
        }, completion: { (_, _) in
            completion?()
        })
    }
    
    func updateCategoryApprovalDetailList(item: ConsumeContentsItem, changeCategory: String, changeSubCategory: String) {
        guard let transaction = ApprovalFromAppNumber(item.approvalNum) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.category = changeCategory
            transaction.subCategory = changeSubCategory
            if changeCategory == "지출" && (item.category == "지출" || item.category == "기타") {
                if item.outgoing == 0 {
                    transaction.appAmt = item.income
                } else {
                    transaction.appAmt = item.outgoing
                }
            } else if changeCategory == "지출" && (item.category == "수입") {
                transaction.appAmt = item.income
            } else {
                if item.outgoing == 0 {
                    transaction.appAmt = item.income
                } else {
                    transaction.appAmt = item.outgoing
                }
            }
            realm.add(transaction, update: .all)
        })
    }
    
    func updatePointCardDetailList(appNo: String, point: Int) {
        guard let transaction = ApprovalFromAppNumber(appNo) else { return }
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
    
    func updateCardDetailList(id: String?, json: JSON?) {
        guard let id = id, let json = json, let transaction = ApprovalFromAppNumber(id) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.category = json["category"].stringValue
            transaction.subCategory = json["subCategory"].stringValue
            transaction.appFranName = json["contents"].stringValue
            transaction.appNickname = json["expedient"].stringValue
            if json["category"].string == "수입" {
                transaction.appAmt = json["income"].stringValue.toInt
            } else {
                transaction.appAmt = json["outgoing"].stringValue.toInt
            }
            if let dateString = json["date"].string {
                transaction.appDate = dateString.simpleDateFormat("yyyyMMdd")
            }
            transaction.appTime = json["time"].stringValue
            transaction.memo = json["memo"].stringValue
            
            realm.add(transaction, update: .all)
        })
    }
    
    func ApprovalFromName(_ name: String) -> CheckCardApprovalDetailsList? {
        return query(filter: "appFranName == '\(name)'").results.first
    }
    
    func ApprovalFromAppNumber(_ appNo: String) -> CheckCardApprovalDetailsList? {
        return query(filter: "appNo == '\(appNo)'").results.first
    }
    
    func containsFromId(_ appNo: String?) -> Bool {
        guard let appNo = appNo, ApprovalFromAppNumber(appNo) != nil else { return false }
        return true
    }
    
    func findRealmDate(_ item: ConsumeContentsItem) -> CheckCardApprovalDetailsList? {
        return query(filter: "appDate == '\(item.date)' AND appAmt == '\(item.outgoing)' AND appTime == '\(item.time)'").results.first
    }
    
    func removeCardDetailList(item: ConsumeContentsItem) {
        guard let transaction = ApprovalFromAppNumber(item.approvalNum) else { return }
        rm.transaction(writeHandler: { realm in
            transaction.isDeleted = true
            realm.add(transaction, update: .all)
        })
    }
}
