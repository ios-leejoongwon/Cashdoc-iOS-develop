//
//  InsuranListRealmProxy.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct InsuranListRealmProxy<RealmManager: InsuranRealmManager>: RealmProxiable {
    func append(_ transaction: [SwiftyJSONRealmObject]) {
        rm.transaction(writeHandler: { (realm) in
            realm.deleteAll()
            for getObject in transaction {
                realm.add(getObject, update: .all)
            }
        })
    }
    
    func deleteAll() {
        rm.transaction(writeHandler: { (realm) in
            realm.deleteAll()
        })
    }
    
    func getList(piName: String) -> [SwiftyJSONRealmObject] {
        var makeArray = [SwiftyJSONRealmObject]()
        let jArray = query(InsuranceJListModel.self, filter: "PIBOHUMJA == '\(piName)'").results.toArray()
        let sArray = query(InsuranceSListModel.self, filter: "PIBOHUMJA == '\(piName)'").results.toArray()
        makeArray.append(contentsOf: jArray)
        makeArray.append(contentsOf: sArray)
        
        return makeArray
    }
    
    // swiftlint:disable:next large_tuple
    func getTotalAndPerson() -> (count: Int, total: Int, personArray: [String]) {
        let jArray = query(InsuranceJListModel.self).results.toArray()
        let sArray = query(InsuranceSListModel.self).results.toArray()
        
        let count = jArray.count + sArray.count
        var totalWon = 0
        var personArray: [String] = []
        
        for jModel in jArray {
            totalWon += Int(jModel.ILHOIBOHUMRYO) ?? 0
            if !personArray.contains(jModel.PIBOHUMJA) {
                personArray.append(jModel.PIBOHUMJA)
            }
        }
        for sModel in sArray where !personArray.contains(sModel.PIBOHUMJA) {
            personArray.append(sModel.PIBOHUMJA)
        }
        
        return (count, totalWon, personArray)
    }
}
