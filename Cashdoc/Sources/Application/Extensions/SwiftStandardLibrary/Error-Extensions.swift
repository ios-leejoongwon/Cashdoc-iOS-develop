//
//  Error-Extensions.swift
//  Cashdoc
//
//  Created by Taejune Jung on 02/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension Error {
    var code: Int { return (self as NSError).code }
    var domain: String { return (self as NSError).domain }
}
