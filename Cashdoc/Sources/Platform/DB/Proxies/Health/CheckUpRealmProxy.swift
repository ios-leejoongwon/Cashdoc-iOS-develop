//
//  CheckUpRealmProxy.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

struct CheckUpRealmProxy<RealmManager: CheckUpRealmManager>: RealmProxiable {
    func append(_ transaction: [SwiftyJSONRealmObject]) {
        rm.transaction(writeHandler: { (realm) in
            realm.deleteAll()
            for getObject in transaction {
                realm.add(getObject, update: .all)
            }
            
            Log.al("CheckUpRealmProxy = \(realm)")
        })
    }
    
    func mergeToIncome(_ jumin: String) {
        let getLists = query(CheckupListModel.self, filter: nil).results.toArray()
        let makeGender = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpGender.rawValue) ?? "1"
        let makeBirth =  UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpBirth.rawValue) ?? "19900101"
//
//        if let getJuminNum = Int(jumin[6...6]) {
//            makeGender = getJuminNum % 2 == 1 ? "1" : "2"
//            let getYear = jumin[0...1]
//            if getJuminNum == 1 || getJuminNum == 2 || getJuminNum == 5 || getJuminNum == 6 {
//                makeBirth = "19\(getYear)"
//            } else {
//                makeBirth = "20\(getYear)"
//            }
//        }
//        
//        UserDefaults.standard.set(makeGender, forKey: UserDefaultKey.kCheckUpGender.rawValue)
//        UserDefaults.standard.set(makeBirth, forKey: UserDefaultKey.kCheckUpBirth.rawValue)
        
        rm.transaction(writeHandler: { (realm) in
            for getList in getLists {
                // 구강건진은 제외라서 무시함
                if getList.CHECKUPKIND == "구강" {
                    continue
                }
                
                let value = getList.CHECKUPDATE
                var makeDate = ""
                
                if value.count > 4 {
                    let start = value.index(value.endIndex, offsetBy: -4)
                    let end = value.index(value.endIndex, offsetBy: 0)
                    var last4String = String(value[start..<end])
                    last4String.insert(string: "/", ind: 2)
                    makeDate = last4String
                }
                
                if let getModel = self.query(CheckupIncomeModel.self, filter: "GUNYEAR == '\(getList.CHECKUPYEAR)' && GUNDATE == '\(makeDate)'").results.first {
                    getModel.CHECKUPORGAN = getList.CHECKUPORGAN
                    getModel.CHECKUPOPINION = getList.CHECKUPOPINION
                    getModel.CHECKUPDATE = getList.CHECKUPDATE

                    getModel.SEX = makeGender
                    getModel.BIRTH = makeBirth

                    realm.add(getModel, update: .modified)
                }
            }
            
            // 위에서 매칭이 안된 건강검진결과 데이터들은 삭제하도록 한다
            let incomeLists = self.query(CheckupIncomeModel.self, filter: nil).results.toArray()
            for getIncome in incomeLists where getIncome.CHECKUPDATE.isEmpty {
                realm.delete(getIncome)
            }
        })
    }
    
    func getIncomeModel(_ dateString: String?) -> CheckupIncomeModel {
        if let getString = dateString {
            GlobalDefine.shared.checkDateString = getString
            return query(CheckupIncomeModel.self, filter: "CHECKUPDATE == '\(getString)'").results.last ?? CheckupIncomeModel()
        } else {
            let model = query(CheckupIncomeModel.self, filter: nil, sortProperty: "CHECKUPDATE", ordering: .ascending).results.last ?? CheckupIncomeModel()
            GlobalDefine.shared.checkDateString = model.CHECKUPDATE
            return model
        }
    }
    
    func getIncomeModelList() -> [CheckupIncomeModel] {
        return query(CheckupIncomeModel.self, filter: nil, sortProperty: "CHECKUPDATE", ordering: .ascending).results.toArray()
    }
}
