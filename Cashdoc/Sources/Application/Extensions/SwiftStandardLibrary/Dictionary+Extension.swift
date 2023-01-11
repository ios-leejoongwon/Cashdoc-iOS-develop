//
//  Dictionary+Extension.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/09.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

// 딕셔너리+딕셔너리 편하게 append하기 위해서
extension Dictionary where Key == String, Value == String {
    mutating func append(anotherDict: [String: String]) {
        for (key, value) in anotherDict {
            self.updateValue(value, forKey: key)
        }
    }
}
