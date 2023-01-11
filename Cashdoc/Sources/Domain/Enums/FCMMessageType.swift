//
//  FCMMessageType.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 20/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum FCMMessageType: String {
    case friendAdd
    
    func createMessage(data: [AnyHashable: Any]) -> String? {
        switch self {
        case .friendAdd:
            return ""
        }
    }
}
