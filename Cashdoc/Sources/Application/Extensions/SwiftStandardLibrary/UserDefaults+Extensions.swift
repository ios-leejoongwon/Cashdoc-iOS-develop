//
//  UserDefaults+Extensions.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 15/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UserDefaults {
    func incrementIntegerForKey(key: String, by: Int) {
        let int = integer(forKey: key)
        set(int + by, forKey: key)
    }
}
