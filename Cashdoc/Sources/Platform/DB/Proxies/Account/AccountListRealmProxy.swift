//
//  AccountListRealmProxy.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

struct AccountListRealmProxy<RealmManager: AccountRealmManager>: RealmProxiable {
    
    // MARK: - Properties
    
    var allLists: RealmQuery<CheckAllAccountInBankList> {
        return query(sortProperty: "identity", ordering: .ascending)
    }
    
    var allListsForPropertyAccount: RealmQuery<CheckAllAccountInBankList> {
        return query(filter: "acctStatus != '6'", sortProperty: "intCurBal", ordering: .descending)
    }
    
    var allListsForPropertyLoan: RealmQuery<CheckAllAccountInBankList> {
        return query(filter: "acctStatus == '6'", sortProperty: "intLoanCurBal", ordering: .descending)
    }
    
    // MARK: - Internal methods
    
    func appendAccountList(_ accountList: [CheckAllAccountInBankList],
                           fCode: FCode? = nil,
                           clearHandler: ((Realm) -> Void)? = nil,
                           completion: (() -> Void)? = nil) {
        rm.transaction(isSync: false, writeHandler: { (realm) in
            clearHandler?(realm)
            accountList.forEach({ account in
                if let fCode = fCode {
                    account.fCodeName = fCode.rawValue
                    account.fCodeIndex = fCode.index
                }
                realm.add(account, update: .all)
            })
        }, completion: { (_, _) in
            if let fCode = fCode {
                UserDefaults.standard.set(true, forKey: fCode.keys.rawValue)
                UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedProperty.rawValue)
            }
            completion?()
        })
    }
    
    func appendForPost(_ accountList: [PostAllAccountInBank],
                       clearHandler: ((Realm) -> Void)? = nil,
                       completion: (() -> Void)? = nil) {
        rm.transaction(isSync: false, writeHandler: { (realm) in
            clearHandler?(realm)
            accountList.forEach { (postAccountList) in
                postAccountList.LIST.forEach { (postAccount) in
                    if let fCode = postAccountList.requestFCODE,
                        let fCodeName = FCode.getFCodeName(with: fCode) {
                        let bankList = try? CheckAllAccountInBankList(postAccountList: postAccount)
                        bankList?.fCodeName = fCodeName
                        bankList?.fCodeIndex = FCode(rawValue: fCodeName)?.index ?? 100
                        realm.add(bankList ?? CheckAllAccountInBankList(), update: .all)
                    }
                }
            }
        }, completion: { (_, _) in
            completion?()
        })
    }
    
    func append(_ object: CheckAllAccountInBankList, completion: (() -> Void)? = nil) {
        rm.transaction(writeHandler: { (realm) in
            realm.create(CheckAllAccountInBankList.self, value: object, update: .all)
        }, completion: { (_, _) in
            completion?()
        })
    }
    
    func delete(fCodeName: String, completion: (() -> Void)? = nil) {
        rm.transaction(writeHandler: { (realm) in
            realm.delete(self.query(CheckAllAccountInBankList.self, filter: "fCodeName == '\(fCodeName)'").results)
        }, completion: { (_, _) in
            if let key = FCode(rawValue: fCodeName)?.keys {
                UserDefaults.standard.set(false, forKey: key.rawValue)
                UserDefaultsManager.checkIsPropertyUnLinked()
            }
            LinkedScrapingV2InfoRealmProxy().delete(fCodeName: fCodeName)
            completion?()
        })
    }
    
    func delete(identity: String) {
        guard let object = self.account(identity: identity).first else { return }
        rm.transaction(writeHandler: { (realm) in
            realm.delete(object)
        })
    }
    
    func account(identity: String) -> Results<CheckAllAccountInBankList> {
        return query(filter: "identity == '\(identity)'").results
    }
    
    func allAccounts(bank: String) -> RealmQuery<CheckAllAccountInBankList> {
        return query(filter: "fCodeName == '\(bank)' AND isHandWrite == false")
    }
    
    func findListWith(number: String) -> CheckAllAccountInBankList? {
        guard let result = query(CheckAllAccountInBankList.self, filter: "number == '\(number)'").results.first else { return nil }
        return result
    }
    
}
