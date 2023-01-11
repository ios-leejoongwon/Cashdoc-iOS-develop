//
//  JSON+Extensions.swift
//  Cashdoc
//
//  Created by bzjoowan on 2021/05/14.
//  Copyright © 2021 Cashwalk. All rights reserved.
//

import Foundation
import SwiftyJSON

extension JSON {
    public var dateValue: Date {
        get {
            let getString = self.object as? String ?? ""
            if getString == ""{
                return Date()
            }
            
            return getString.toDate(dateFormat: "yyyy-MM-dd HH:mm:ss") ?? Date()
        }
        set {
            print("set date : \(newValue)")
        }
    }
}
