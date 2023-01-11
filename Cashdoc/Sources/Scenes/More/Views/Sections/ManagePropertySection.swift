//
//  ManagePropertySection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum ManagePropertySection {
    case section(items: [ManagePropertySectionItem])
}

enum ManagePropertySectionItem {
    case header(item: String)
    case bank(item: LinkedScrapingInfo)
    case card(item: LinkedScrapingInfo)
}

extension ManagePropertySection: SectionModelType {
    typealias Item = ManagePropertySectionItem
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: ManagePropertySection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}
