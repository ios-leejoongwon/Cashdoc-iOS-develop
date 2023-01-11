//
//  MedicHistoryRealmProxy.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

struct MedicHistoryRealmProxy<RealmManager: MedicHistoryRealmManager>: RealmProxiable {
    func append(_ transaction: [SwiftyJSONRealmObject]) {
        rm.transaction(writeHandler: { (realm) in
            realm.deleteAll()
            for getObject in transaction {
                realm.add(getObject, update: .all)
            }
        })
    }
    
    func changePriceQuery() {
        let getJoinLists = query(MedicJoinListModel.self, filter: nil).results.toArray()
        rm.transaction(writeHandler: { (realm) in
            for getJoin in getJoinLists {
                if let getModel = self.query(MedicIneListModel.self, filter: "IDENTYTY == '\(getJoin.IDENTYTY)'").results.first {
                    getModel.PRICE = (Int(getJoin.JINDSAMT) ?? 0)
                    realm.add(getModel, update: .modified)
                }
            }
        })
    }
    
    func getIneList(_ name: String?) -> [MedicIneListModel] {
        if let getName = name {
            return query(MedicIneListModel.self, filter: "TREATDSNM == '\(getName)'", sortProperty: "TREATDATE", ordering: .descending).results.toArray()
        } else {
            return query(MedicIneListModel.self, filter: nil, sortProperty: "TREATDATE", ordering: .descending).results.toArray()
        }
    }
    
    func getIne1YearList(_ name: String, type: Bool) -> [MedicIneListModel] {
        if type {
            return query(MedicIneListModel.self, filter: "TREATDSNM == '\(name)' AND TREATTYPE != '처방조제'", sortProperty: "TREATDATE", ordering: .descending).results.toArray()
        } else {
            return query(MedicIneListModel.self, filter: "TREATDSNM == '\(name)' AND TREATTYPE == '처방조제'", sortProperty: "TREATDATE", ordering: .descending).results.toArray()
        }
    }
    
    // swiftlint:disable:next large_tuple
    func getTotalAndPrice(_ name: String) -> (jinCount: Int, drugCount: Int, jinTotalWon: Int, drugTotalWon: Int) {
        let ineArray = query(MedicIneListModel.self, filter: "TREATDSNM == '\(name)'").results.toArray()

        var jinCount = 0
        var drugCount = 0
        var jinTotalWon = 0
        var drugTotalWon = 0

        for ineModel in ineArray {
            if ineModel.TREATTYPE != "처방조제" {
                jinTotalWon += ineModel.PRICE
                jinCount += 1
            } else {
                drugTotalWon += ineModel.PRICE
                drugCount += 1
            }
        }
        
        return (jinCount, drugCount, jinTotalWon, drugTotalWon)
    }
    
    func getPersonArray() -> [String] {
        let ineArray = query(MedicIneListModel.self, sortProperty: "TREATDSGB", ordering: .ascending).results.toArray()
        
        var personArray: [String] = []
        for ineModel in ineArray where !personArray.contains(ineModel.TREATDSNM) {
            personArray.append(ineModel.TREATDSNM)
        }
        return personArray
    }
    
    func findJinAmts(_ identity: String) -> (JINDSAMT: String, JINGDAMT: String) {
        guard let data = query(MedicJoinListModel.self, filter: "IDENTYTY == '\(identity)'").results.first else { return ("", "") }
        return (data.JINDSAMT, data.JINGDAMT)
    }
}
