//
//  InviteFriendSection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 25/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum InviteFriendSection {
    case section(items: [InviteFriendSectionItem])
}

enum InviteFriendSectionItem {
    case item(isInvited: Bool)
}

extension InviteFriendSection: SectionModelType {
    typealias Item = InviteFriendSectionItem
    
    var items: [Item] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: InviteFriendSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}
