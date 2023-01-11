//
//  CardDetailSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum CardDetailSection {
    case section(items: [CardDetailSectionItem])
}

extension CardDetailSection: SectionModelType {
    typealias Item = CardDetailSectionItem
    
    var title: String {
        return ""
    }
    
    var items: [CardDetailSectionItem] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: CardDetailSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

enum CardDetailSectionItem {
    case header(item: CardDetailHeaderItem, totalAmt: [String: Int])
    case contents(item: CardDetailContentItem)
}

struct CardDetailHeaderItem {
    let date: String
}

struct CardDetailContentItem {
    let name: String
    let installment: String
    let amount: String
}
