//
//  ConsumeSection.swift
//  Cashdoc
//
//  Created by Taejune Jung on 10/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxDataSources

enum ConsumeSection {
    case section(items: [ConsumeSectionItem])
}

extension ConsumeSection: SectionModelType {
    typealias Item = ConsumeSectionItem
    
    var items: [ConsumeSectionItem] {
        switch self {
        case .section(let items):
            return items
        }
    }
    
    init(original: ConsumeSection, items: [Item]) {
        switch original {
        case .section(let items):
            self = .section(items: items)
        }
    }
}

enum ConsumeSectionItem {
    case date(item: ConsumeDateItem)
    case contents(item: ConsumeContentsItem)
}

struct ConsumeContentsItem {
    let identity: String
    var category: String
    let consumeType: String
    var subCategory: String
    var touchCount: Int
    var isTouchEnabled: Bool
    var isDeleted: Bool
    var categoryImageName: String
    var title: String
    var subTitle: String
    var income: Int
    var outgoing: Int
    let originalPrice: Int
    var date: String
    var time: String
    var cardName: String
    let isLast: Bool
    var memo: String
    
    let cardPaymentType: String
    let cardApprovalGuBun: String
    let cardPaymentTerm: String
    let approvalNum: String
    
    let tranBal: Int
    let tranGb: String
    
    init(item: ConsumeDataModel, isLast: Bool) {
        self.identity = item.identity
        self.category = item.category
        self.consumeType = item.consumeType
        self.subCategory = item.subCategory
        self.touchCount = item.touchCount
        self.isTouchEnabled = item.isTouchEnabled
        self.isDeleted = item.isDeleted
        self.categoryImageName = item.categoryImageName
        self.title = item.title
        self.subTitle = item.subTitle
        self.income = item.income
        self.outgoing = item.outgoing
        self.originalPrice = item.originalPrice
        self.date = item.date
        self.time = item.time
        self.cardName = item.cardName
        self.isLast = isLast
        self.memo = item.memo
        self.cardPaymentType = item.cardPaymentType
        self.cardApprovalGuBun = item.cardApprovalGuBun
        self.cardPaymentTerm = item.cardPaymentTerm
        self.approvalNum = item.approvalNum
        self.tranBal = item.tranBal
        self.tranGb = item.tranGb
    }
}

struct ConsumeDateItem {
    let date: String
    let day: String
    let income: Int
    let outgoing: Int
}
