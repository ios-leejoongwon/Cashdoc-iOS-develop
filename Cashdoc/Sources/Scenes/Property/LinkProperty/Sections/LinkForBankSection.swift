//
//  LinkForBankSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources
import RxSwift

enum LinkForBankSection {
    case section(items: [LinkForBankSectionItem])
}

enum LinkForBankSectionItem {
    case bank(bankInfo: BankInfo)
}

extension LinkForBankSection: SectionModelType {
    typealias Item = LinkForBankSectionItem
    
    var title: String {
        return ""
    }
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: LinkForBankSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

struct BankInfo {
    let bankName: String
    let isLinked: Bool
    let isCanLogin: Bool
}
