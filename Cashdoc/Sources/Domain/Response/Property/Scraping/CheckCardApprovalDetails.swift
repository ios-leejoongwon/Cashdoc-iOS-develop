//
//  CheckCardApprovalDetails.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift
import Realm

// 카드_승인내역조회
@objcMembers
class CheckCardApprovalDetails: Object, Decodable {
    var result: String!
    var errMsg: String?
    var errDoc: String?
    var eCode: String?
    var eTrack: String?
    let list = List<CheckCardApprovalDetailsList>()
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
        case errMsg = "ERRMSG"
        case errDoc = "ERRDOC"
        case eCode = "ECODE"
        case eTrack = "ETRACK"
        case list = "LIST"
    }
    
    // MARK: - Con(De)structor
    
    required convenience init(from decoder: Decoder) throws {
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        result = try container.decode(String.self, forKey: .result)
        errMsg = try container.decode(String.self, forKey: .errMsg)
        errDoc = try container.decode(String.self, forKey: .errDoc)
        eCode = try? container.decode(String.self, forKey: .eCode)
        eTrack = try? container.decode(String.self, forKey: .eTrack)
        
        if let approvalDetails = try? container.decode([CheckCardApprovalDetailsList].self, forKey: .list) {
            for approvalDetail in approvalDetails {
                if let approvalData = CardApprovalRealmProxy().ApprovalFromAppNumber(approvalDetail.appNo) {
                    list.append(approvalData)
                } else {
                    list.append(approvalDetail)
                }
            }
        }
    }
    
}
