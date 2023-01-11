//
//  CheckAllAccountInBankList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 13/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckAllAccountInBankList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case number = "NUMBER"
        case lossAccount = "LOSSACCOUNT"
        case acctKind = "ACCTKIND"
        case acctStatus = "ACCTSTATUS"
        case curBal = "CURBAL"
        case enbBal = "ENBBAL"
        case openDate = "OPENDATE"
        case closeDate = "CLOSEDATE"
        case currCd = "CURRCD"
        case interastRate = "INTERASTRATE"
        case intPayDate = "INTPAYDATE"
        case imAmt = "IMAMT"
        case evalAmt = "EVALAMT"
        case appLimit = "APPLIMIT"
        case loanBal = "LOANBAL"
        case loanCurBal = "LOANCURBAL"
        case loanDate = "LOANDATE"
        case lastDate = "LASTDATE"
        case avgPurAmt = "AVGPURAMT"
    }
    
    // MARK: - Properties
    
    dynamic var identity: String?
    dynamic var fCodeName: String?
    dynamic var fCodeIndex: Int = 0
    dynamic var intCurBal: Int = 0
    dynamic var intLoanCurBal: Int = 0
    dynamic var number: String?
    dynamic var lossAccount: String?
    dynamic var acctKind: String?
    dynamic var acctStatus: String?
    dynamic var curBal: String?
    dynamic var enbBal: String?
    dynamic var openDate: String?
    dynamic var closeDate: String?
    dynamic var isHandWrite: Bool = false
    dynamic var memo: String = ""
    dynamic var currCd: String?
    dynamic var interastRate: String?
    dynamic var intPayDate: String?
    dynamic var imAmt: String?
    dynamic var evalAmt: String?
    dynamic var appLimit: String?
    dynamic var loanBal: String?
    dynamic var loanCurBal: String?
    dynamic var loanDate: String?
    dynamic var lastDate: String?
    dynamic var avgPurAmt: String?
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        number = try? container.decode(String.self, forKey: .number)
        lossAccount = try? container.decode(String.self, forKey: .lossAccount)
        acctKind = try? container.decode(String.self, forKey: .acctKind)
        acctStatus = try? container.decode(String.self, forKey: .acctStatus)
        curBal = try? container.decode(String.self, forKey: .curBal)
        enbBal = try? container.decode(String.self, forKey: .enbBal)
        openDate = try? container.decode(String.self, forKey: .openDate)
        closeDate = try? container.decode(String.self, forKey: .closeDate)
        currCd = try? container.decode(String.self, forKey: .currCd)
        interastRate = try? container.decode(String.self, forKey: .interastRate)
        intPayDate = try? container.decode(String.self, forKey: .intPayDate)
        imAmt = try? container.decode(String.self, forKey: .imAmt)
        evalAmt = try? container.decode(String.self, forKey: .evalAmt)
        appLimit = try? container.decode(String.self, forKey: .appLimit)
        loanBal = try? container.decode(String.self, forKey: .loanBal)
        loanCurBal = try? container.decode(String.self, forKey: .loanCurBal)
        loanDate = try? container.decode(String.self, forKey: .loanDate)
        lastDate = try? container.decode(String.self, forKey: .lastDate)
        avgPurAmt = try? container.decode(String.self, forKey: .avgPurAmt)
        
        if let curBal = curBal,
            let intCurBal = Int(curBal) {
            self.intCurBal = intCurBal
        }
        if let loanCurBal = loanCurBal,
            let intLoanCurBal = Int(loanCurBal) {
            self.intLoanCurBal = intLoanCurBal
        }
        if let id = setPrimaryKey() {
            identity = id
        }
        
    }
    
    convenience required init(postAccountList: PostAllAccountInBankList) throws {
        self.init()
        
        number = postAccountList.NUMBER
        acctKind = postAccountList.ACCTKIND
        acctStatus = postAccountList.ACCTSTATUS
        curBal = postAccountList.CURBAL
        currCd = postAccountList.CURRCD
        interastRate = postAccountList.INTERASTRATE
        intPayDate = postAccountList.INTPAYDATE
        openDate = postAccountList.OPENDATE
        closeDate = postAccountList.CLOSEDATE
        loanBal = postAccountList.LOANBAL
        loanCurBal = postAccountList.LOANCURBAL
        
        if let curBal = curBal,
            let intCurBal = Int(curBal) {
            self.intCurBal = intCurBal
        }
        if let loanCurBal = loanCurBal,
            let intLoanCurBal = Int(loanCurBal) {
            self.intLoanCurBal = intLoanCurBal
        }
        if let id = setPrimaryKey() {
            identity = id
        }
        
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
    // MARK: - Private methods
    
    private func setPrimaryKey() -> String? {
        guard let acctStatus = acctStatus,
            let number = number else {return nil}
        
        switch acctStatus {
        case "6":
            guard let loanCurBal = loanCurBal else {return nil}
            return String(format: "%@_-%@", number, loanCurBal)
        default:
            guard let curBal = curBal else {return nil}
            return String(format: "%@_%@", number, curBal)
        }
    }
    
}
