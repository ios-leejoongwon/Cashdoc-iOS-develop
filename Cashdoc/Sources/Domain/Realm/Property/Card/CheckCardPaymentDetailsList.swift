//
//  CheckCardPaymentDetailsList.swift
//  Cashdoc
//
//  Created by Oh Sangho on 15/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Realm
import RealmSwift

@objcMembers
class CheckCardPaymentDetailsList: Object, Decodable {
    
    // MARK: - Constants
    
    private enum CodingKeys: String, CodingKey {
        case estDate = "ESTDATE"
        case estAmt = "ESTAMT"
        case payestList = "PAYESTLIST"
    }
    
    // MARK: - Properties
    
    dynamic var identity: String?
    dynamic var fCodeName: String?
    dynamic var fCodeIndex: Int = 0
    dynamic var intEstAmt: Int = 0
    dynamic var estDate: String?
    dynamic var estAmt: String?
    let payestList = List<CheckCardPaymentDetailsPayestList>()
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        estDate = try container.decode(String.self, forKey: .estDate)
        estAmt = try container.decode(String.self, forKey: .estAmt)
        
        if let paymentsArray = try? container.decode([CheckCardPaymentDetailsPayestList].self, forKey: .payestList) {
            paymentsArray.forEach {payestList.append($0)}
        }
        
        if let estAmt = estAmt,
            let intEstAmt = Int(estAmt) {
            self.intEstAmt = intEstAmt
        }
        
    }
    
    convenience required init(postCardList: PostCardPaymentDetailsList) throws {
        self.init()
        
        estDate = postCardList.ESTDATE
        estAmt = postCardList.ESTAMT
        postCardList.PAYESTLIST.forEach { [weak self] (list) in
            guard let self = self else { return }
            guard let _payestList = try? CheckCardPaymentDetailsPayestList(postPayestList: list) else { return }
            self.payestList.append(_payestList)
        }
    }
    
    // MARK: - EmptyList init
    
    convenience required init(fCode: FCode, empty: String) {
        self.init()
        
        fCodeName = fCode.rawValue
        fCodeIndex = fCode.index
        estDate = empty
        estAmt = empty
        if let estDate = estDate {
            identity = setIdentity(with: estDate, fCodeName: fCode.rawValue)
        }
        payestList.append(CheckCardPaymentDetailsPayestList(fCode: fCode.rawValue, empty: empty))
    }
    
    // MARK: - Overridden: Object
    
    override static func primaryKey() -> String? {
        return "identity"
    }
    
    func setListFCode(_ fCodeName: String) {
        payestList.forEach {$0.fCodeName = fCodeName}
    }
    
    func setIdentity(with estDate: String, fCodeName: String) -> String {
       return String(format: "%@_%@", estDate, fCodeName)
    }
    
}
