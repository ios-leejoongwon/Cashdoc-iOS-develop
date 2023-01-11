//
//  EtcPropertyRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift

struct EtcPropertyRealmProxy<RealmManager: EtcPropertyRealmManager>: RealmProxiable {
    
    func append(_ object: EtcPropertyList, completion: (() -> Void)? = nil) {
        rm.transaction(writeHandler: { (realm) in
            realm.create(EtcPropertyList.self, value: object, update: .all)
        }, completion: { (_, _) in
            completion?()
            UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedEtc기타자산.rawValue)
            UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedProperty.rawValue)
        })
    }
    
    func delete(id: String) {
        guard let object = getObject(with: id) else { return }
        rm.transaction(writeHandler: { (realm) in
            realm.delete(object)
        }, completion: { (_, _) in
            UserDefaultsManager.checkIsPropertyUnLinked()
        })
    }
    
    func getObject(with id: String) -> EtcPropertyList? {
        guard let item = query(EtcPropertyList.self, filter: "id == '\(id)'").results.first else { return nil }
        return item
    }
}
