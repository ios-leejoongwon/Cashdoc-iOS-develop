//
//  TutorialSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum TutorialSection {
    case section(items: [TutorialSectionItem])
}

enum TutorialSectionItem {
    case leftTextItem(item: TutorialLeftItem)
    case leftImageItem(item: [String])
    case rightItem(item: [String])
}

extension TutorialSection: SectionModelType {
    typealias Item = TutorialSectionItem
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: TutorialSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

struct TutorialLeftItem {
    let dialog: [String]
    let isStart: Bool
    let isNeedName: Bool
}
