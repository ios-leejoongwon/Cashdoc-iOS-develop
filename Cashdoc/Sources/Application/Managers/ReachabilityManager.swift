//
//  ReachabilityManager.swift
//  Cashdoc
//
//  Created by DongHeeKang on 19/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Reachability

class ReachabilityManager {
    // swiftlint:disable:next force_try
    static var reachability = try! Reachability()
}
