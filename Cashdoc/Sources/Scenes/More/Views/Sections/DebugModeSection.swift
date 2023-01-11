//
//  DebugModeSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum DebugModeSection {
    case section(items: [DebugModeSectionItem])
}

enum DebugModeSectionItem {
    case item(item: DebugModeType)
}

extension DebugModeSection: SectionModelType {
    typealias Item = DebugModeSectionItem
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: DebugModeSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
    
}
