//
//  ConsumeCategorySection.swift
//  Cashdoc
//
//  Created by Taejune Jung on 24/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources
import RxSwift

enum ConsumeCategorySection {
    case section(items: [ConsumeCategorySectionItem])
}

enum ConsumeCategorySectionItem {
    case category(category: CategoryInfo)
    case test(item: FCode)
}

extension ConsumeCategorySection: SectionModelType {
    typealias Item = ConsumeCategorySectionItem
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: ConsumeCategorySection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

struct CategoryInfo {
    let categoryTitle: String
    let categoryName: String
}
