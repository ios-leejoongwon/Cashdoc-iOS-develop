//
//  ScrapingRealmManager.swift
//  Cashdoc
//
//  Created by Oh Sangho on 01/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RealmSwift

final class ScrapingV2RealmManager: RealmManageable {
    var isUseInMemory: Bool {
        return false
    }
    var schemaVersion: UInt64 {
        return 3
    }
    var fileName: String {
        return "scrapingV2"
    }
    var objectTypes: [Object.Type]? {
        return [LinkedScrapingInfo.self]
    }
}
