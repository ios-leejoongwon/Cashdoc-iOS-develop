//
//  AccountType.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum AccountType: String {
    case 입출금 = "1"
    case 예금 = "2"
    case 적금 = "3"
    
    var name: String {
        switch self {
        case .예금: return "예금"
        case .입출금: return "입출금"
        case .적금: return "적금"
        }
    }
}
