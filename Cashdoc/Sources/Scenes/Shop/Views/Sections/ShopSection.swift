//
//  ShopSection.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 22/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Differentiator
import RxDataSources

// MARK: - Data

enum ShopSection {
    case section(items: [ShopSectionItem])
}

enum ShopSectionItem {
    case category(item: ShopCategoryModel)
}

extension ShopSection: SectionModelType {
    typealias Item = ShopSectionItem
    
    var title: String {
        return ""
    }
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: ShopSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}
