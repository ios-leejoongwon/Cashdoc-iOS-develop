//
//  MobileType.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/16.
//  Copyright © 2022 Cashwalk. All rights reserved.
//
 
enum MobileType: String, Equatable {
    case SKT
    case KT
    case LGU
    case none
    
    func number() -> String {
        switch self {
        case .SKT:
            return "1"
        case .KT:
            return "2"
        case .LGU:
            return "3"
        case .none:
            return ""
        }
    }
    
    func changeType(type: String) -> MobileType {
        switch type {
        case MobileType.SKT.rawValue:
            return .SKT
        case MobileType.KT.rawValue:
            return .KT
        case MobileType.LGU.rawValue:
            return .LGU
        default:
            return .none
        }
    }
}
