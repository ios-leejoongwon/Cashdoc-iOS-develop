//
//  CheckAccountSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxDataSources

enum CheckAccountSection {
    case section(items: [CheckAccountSectionItem])
}

extension CheckAccountSection: SectionModelType {
    typealias Item = CheckAccountSectionItem
    
    var items: [CheckAccountSectionItem] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: CheckAccountSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

enum CheckAccountSectionItem {
    case filterBtn
    case header(date: (String, String))
    case contents(item: CheckAccountContentItem)
}

struct CheckAccountContentItem {
    let tranGb: String
    let name: String
    let time: String
    let inoutBal: Int
    let tranBal: Int
}
