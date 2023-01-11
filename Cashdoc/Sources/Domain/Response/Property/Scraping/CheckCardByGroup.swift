//
//  CheckCardByGroup.swift
//  Cashdoc
//
//  Created by Oh Sangho on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

// 카드_그룹조회
struct CheckCardByGroup: Decodable {
    let card6: CheckAllCards
    let card2: CheckCardApprovalDetails
    let card3: CheckCardBill?
    let card1: CheckCardPaymentDetails?

    private enum CodingKeys: String, CodingKey {
        case card6 = "CARD_6"
        case card2 = "CARD_2"
        case card3 = "CARD_3"
        case card1 = "CARD_1"
    }
}
