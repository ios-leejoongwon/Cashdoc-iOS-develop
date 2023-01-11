//
//  MoyaCacheable.swift
//  Cashdoc
//
//  Created by DongHeeKang on 21/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

protocol MoyaCacheable {
    typealias MoyaCacheablePolicy = URLRequest.CachePolicy
    var cachePolicy: MoyaCacheablePolicy { get }
}
