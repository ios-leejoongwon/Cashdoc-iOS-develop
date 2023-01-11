//
//  LinkedScrapingInfoRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 01/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct LinkedScrapingV2InfoRealmProxy<RealmManager: ScrapingV2RealmManager>: RealmProxiable {
    
    // MARK: - Properties
    
    var allLists: RealmQuery<LinkedScrapingInfo> {
        return query(LinkedScrapingInfo.self, filter: "fCodeName != '내보험다나와' AND fCodeName != '진료내역'")
    }
    
    // MARK: - Internal methods
    
    func appendList(_ scrapingInfoList: [LinkedScrapingInfo],
                    clearHandler: ((Realm) -> Void)? = nil,
                    completion: (() -> Void)? = nil) {
        rm.transaction(writeHandler: { (realm) in
            clearHandler?(realm)
            scrapingInfoList.forEach({ (info) in
                if info.loginMethodPwdValue?.isNotEmpty ?? false {
                    realm.add(info, update: .all)
                }
            })
            
        }, completion: { (_, _) in
            completion?()
            UserNotificationManager.shared.addDailyNotification(identifier: .DailyNotification1930)
        })
    }
    
    func delete(fCodeName: String) {
        rm.transaction(writeHandler: { (realm) in
            realm.delete(self.query(LinkedScrapingInfo.self, filter: "fCodeName == '\(fCodeName)'").results)
        }, completion: { (_, _) in
            if self.query(LinkedScrapingInfo.self).results.isEmpty {
                UserNotificationManager.shared.addDailyNotification(identifier: .DailyNotification1930)
            }
        })
    }
    
    func linkedScrapingInfo(fCodeName: String) -> RealmQuery<LinkedScrapingInfo> {
        return query(filter: "fCodeName == '\(fCodeName)'")
    }
    
    func isLinked(with fCodeName: String) -> Bool {
        return !query(LinkedScrapingInfo.self, filter: "fCodeName == '\(fCodeName)'").results.isEmpty
    }
    
    func linkedScrapingInfo(fCodeNameList: [String]) -> Results<LinkedScrapingInfo> {
        return allLists.results.filter("fCodeName IN %@", fCodeNameList)
    }
    
    func isContainError() -> Bool {
        let realmData = query(LinkedScrapingInfo.self, filter: "cIsError == true")
        
        if realmData.results.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    func consumeLinkedList() -> [LinkedScrapingInfo] {
        return query(LinkedScrapingInfo.self, filter: "cLinked == true").results.toArray()
    }
}
