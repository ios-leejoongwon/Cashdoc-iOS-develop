//
//  ManageConsumeSection.swift
//  Cashdoc
//
//  Created by Taejune Jung on 31/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxDataSources

enum ManageConsumeSection {
    case section(items: [ManageConsumeSectionItem])
}

enum ManageConsumeSectionItem {
    case header(item: String)
    case bank(item: LinkedScrapingInfo)
    case card(item: LinkedScrapingInfo)
}

extension ManageConsumeSection: SectionModelType {
    typealias Item = ManageConsumeSectionItem
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: ManageConsumeSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}
