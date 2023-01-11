//
//  Data+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension Data {
    var hexString: String {
        return map {String(format: "%02hhx", $0)}.joined()
    }
}
