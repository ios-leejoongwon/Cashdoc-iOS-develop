//
//  CheckCardPaymentDetailsPayestList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 16/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardPaymentDetailsPayestList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case aSaleDate = "ASALEDATE"
        case cardNumber = "CARDNUMBER"
        case mbrmchName = "MBRMCHNAME"
        case payOption = "PAYOPTION"
        case aSaleAmt = "ASALEAMT"
        case discAmt = "DISCAMT"
        case askNth = "ASKNTH"
        case prcpl = "PRCPL"
        case fee = "FEE"
        case lateFee = "LATEFEE"
        case savePoint = "SAVEPOINT"
        case rmainNth = "RMAINNTH"
        case rmainPrcpl = "RMAINPRCPL"
        case discContent = "DISCCONTENT"
        case cardIssue = "CARDISSUE"
    }
    
    // MARK: - Properties
    
    dynamic var identity: String?
    dynamic var fCodeName: String?
    dynamic var aSaleDate: String?
    dynamic var cardNumber: String?
    dynamic var mbrmchName: String?
    dynamic var payOption: String?
    dynamic var intAmount: Int = 0
    dynamic var aSaleAmt: String?
    dynamic var discAmt: String?
    dynamic var askNth: String?
    dynamic var prcpl: String?
    dynamic var fee: String?
    dynamic var lateFee: String?
    dynamic var savePoint: String?
    dynamic var rmainNth: String?
    dynamic var rmainPrcpl: String?
    dynamic var discContent: String?
    dynamic var cardIssue: String?
    let details = LinkingObjects(fromType: CheckCardPaymentDetailsList.self, property: "payestList")
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        aSaleDate = try? container.decode(String.self, forKey: .aSaleDate)
        cardNumber = try? container.decode(String.self, forKey: .cardNumber)
        mbrmchName = try? container.decode(String.self, forKey: .mbrmchName)
        payOption = try? container.decode(String.self, forKey: .mbrmchName)
        aSaleAmt = try? container.decode(String.self, forKey: .aSaleAmt)
        discAmt = try? container.decode(String.self, forKey: .discAmt)
        askNth = try? container.decode(String.self, forKey: .askNth)
        prcpl = try? container.decode(String.self, forKey: .prcpl)
        fee = try? container.decode(String.self, forKey: .fee)
        lateFee = try? container.decode(String.self, forKey: .lateFee)
        savePoint = try? container.decode(String.self, forKey: .savePoint)
        rmainNth = try? container.decode(String.self, forKey: .rmainNth)
        rmainPrcpl = try? container.decode(String.self, forKey: .rmainPrcpl)
        discContent = try? container.decode(String.self, forKey: .discContent)
        cardIssue = try? container.decode(String.self, forKey: .cardIssue)
        
        if let aSaleDate = aSaleDate, let mbrmchName = mbrmchName {
            identity = String(format: "%@_%@_%@", aSaleDate, mbrmchName, calculatedAmount())
        }
        if let intAmount = Int(calculatedAmount()) {
            self.intAmount = intAmount
        }
    }
    
    convenience required init(postPayestList: PostCardPaymentDetailsPayestList) throws {
        self.init()
        
        aSaleDate = postPayestList.ASALEDATE
        cardNumber = postPayestList.CARDNUMBER
        mbrmchName = postPayestList.MBRMCHNAME
        payOption = postPayestList.PAYOPTION
        aSaleAmt = postPayestList.ASALEAMT
        discAmt = postPayestList.DISCAMT
        askNth = postPayestList.ASKNTH
        prcpl = postPayestList.PRCPL
        fee = postPayestList.FEE
        lateFee = postPayestList.LATEFEE
        savePoint = postPayestList.SAVEPOINT
        rmainNth = postPayestList.RMAINNTH
        rmainPrcpl = postPayestList.RMAINPRCPL
        discContent = postPayestList.DISCCONTENT
        cardIssue = postPayestList.CARDISSUE
        
        if let aSaleDate = aSaleDate, let mbrmchName = mbrmchName {
            identity = String(format: "%@_%@_%@", aSaleDate, mbrmchName, calculatedAmount())
        }
        if let intAmount = Int(calculatedAmount()) {
            self.intAmount = intAmount
        }
    }
    
    // MARK: - EmptyList init
    
    convenience required init(fCode: String, empty: String) {
        self.init()
        
        identity = empty
        fCodeName = fCode
        aSaleDate = empty
        cardNumber = empty
        mbrmchName = empty
        payOption = empty
        aSaleAmt = empty
        discAmt = empty
        askNth = empty
        prcpl = empty
        fee = empty
        lateFee = empty
        savePoint = empty
        rmainNth = empty
        rmainPrcpl = empty
        discContent = empty
        cardIssue = empty
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
    // MARK: - Internal methods
    
    func calculatedAmount() -> String {
        var intAmount: Int = 0
        var amount = prcpl ?? ""
        
        if amount.isEmpty ||
            amount == "0" {
            amount = aSaleAmt ?? ""
        }
        
        // 간혹 String "123,456" 형식으로 들어오는 경우가 있음...
        if let tempIntAmount = Int(amount) {
            intAmount = tempIntAmount
        } else if let tempIntAmount = Int(amount.replace(target: ",", withString: "")) {
            intAmount = tempIntAmount
        }
        
        if let fee = fee,
        !fee.isEmpty,
            let intFee = Int(fee) {
            intAmount -= intFee
        }
        
        if let lateFee = lateFee,
            !lateFee.isEmpty,
            let intLateFee = Int(lateFee) {
            intAmount += intLateFee
        }
        
        return String(intAmount)
    }
}
