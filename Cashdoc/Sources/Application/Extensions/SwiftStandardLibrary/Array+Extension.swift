//
//  Array+Extension.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/12/05.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension Array {
    subscript (safe index: Int) -> Element? {
        return index < count ? self[index] : nil
    }
}

extension Array where Iterator.Element == URLQueryItem {
    subscript(_ key: String) -> String? {
        return first(where: { $0.name == key })?.value
    }
}
