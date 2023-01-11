//
//  ConsumeScrapingRealmManager.swift
//  Cashdoc
//
//  Created by Taejune Jung on 31/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift
import RealmWrapper

final class ConsumeScrapingRealmManager: RealmManageable {
    var isUseInMemory: Bool {
        return false
    }
    var schemaVersion: UInt64 {
        return 1
    }
    var fileName: String {
        return "consumeScraping"
    }
    var objectTypes: [Object.Type]? {
        return [ConsumeLinkedScrapingInfo.self]
    }
}
