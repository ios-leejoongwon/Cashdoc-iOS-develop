//
//  PropertySection.swift
//  Cashdoc
//
//  Created by Oh Sangho on 10/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Differentiator
import RxDataSources

// MARK: - Data

struct PropertySection {
    var header: String
    var propertyItems: [PropertySectionItem]
    var updated: Date
    
    init(header: String, propertyItems: [PropertySectionItem], updated: Date) {
        self.header = header
        self.propertyItems = propertyItems
        self.updated = updated
    }
}

enum PropertySectionItem {
    case CashItem(identity: Int, item: PropertyExpandCommon, date: Date)
    case AccountItem(identity: Int, totalResult: PropertyTotalResult, item: [PropertyExpandAccount], date: Date)
    case CardItem(identity: Int, totalResult: PropertyTotalResult, item: [PropertyExpandCard], date: Date)
    case LoanItem(identity: Int, totalResult: PropertyTotalResult, item: [PropertyExpandLoan], date: Date)
    case CreditItem(identity: Int, item: PropertyExpandCommon, date: Date)
    case InsuranceItem(identity: Int, item: PropertyExpandCommon, date: Date)
    case EtcItem(identity: Int, totalAmt: String, item: [EtcPropertyList], date: Date)
    case AddItem(identity: Int, date: Date)
}

extension PropertySection: AnimatableSectionModelType {
    typealias Item = PropertySectionItem
    
    var identity: String {
        return header
    }
    
    var items: [PropertySectionItem] {
        return propertyItems
    }
    
    init(original: PropertySection, items: [Item]) {
        self = original
        self.propertyItems = items
    }
}

extension PropertySection: CustomDebugStringConvertible {
    
    var debugDescription: String {
        let interval = updated.timeIntervalSince1970
        let propertyDescription = propertyItems.map {"\n\($0.debugDescription)"}.joined(separator: "")
        return "PropertySection(header: \(header), propertyItems: \(propertyDescription), updated: \(interval)"
    }
    
}

extension PropertySectionItem: IdentifiableType, Equatable {
    typealias Identity = Int
    
    var identity: Int {
        switch self {
        case .CashItem(let identity, _, _),
             .AccountItem(let identity, _, _, _),
             .CardItem(let identity, _, _, _),
             .LoanItem(let identity, _, _, _),
             .CreditItem(let identity, _, _),
             .InsuranceItem(let identity, _, _),
             .EtcItem(let identity, _, _, _),
             .AddItem(let identity, _):
            return identity
        }
    }
}

func == (lhs: PropertySectionItem, rhs: PropertySectionItem) -> Bool {
    switch lhs {
    case .CashItem(let lIdentity, _, let lDate),
         .AccountItem(let lIdentity, _, _, let lDate),
         .CardItem(let lIdentity, _, _, let lDate),
         .LoanItem(let lIdentity, _, _, let lDate),
         .CreditItem(let lIdentity, _, let lDate),
         .InsuranceItem(let lIdentity, _, let lDate),
         .EtcItem(let lIdentity, _, _, let lDate),
         .AddItem(let lIdentity, let lDate):
        switch rhs {
        case .CashItem(let rIdentity, _, let rDate),
             .AccountItem(let rIdentity, _, _, let rDate),
             .CardItem(let rIdentity, _, _, let rDate),
             .LoanItem(let rIdentity, _, _, let rDate),
             .CreditItem(let rIdentity, _, let rDate),
             .InsuranceItem(let rIdentity, _, let rDate),
             .EtcItem(let rIdentity, _, _, let rDate),
             .AddItem(let rIdentity, let rDate):
            return lIdentity == rIdentity && lDate == rDate
        }
    }
}

extension PropertySectionItem: CustomDebugStringConvertible {
    
    var debugDescription: String {
        switch self {
        case .CashItem(_, let point, let date):
            return "CashItem(point: \(point) date: \(date.timeIntervalSince1970))"
        case .AccountItem(_, let totalResult, let item, let date):
            return "AccountItem(totalResult: \(totalResult), item: \(item) date: \(date.timeIntervalSince1970))"
        case .CardItem(_, let totalResult, let item, let date):
            return "CardItem(totalResult: \(totalResult), item: \(item) date: \(date.timeIntervalSince1970))"
        case .LoanItem(_, let totalResult, let item, let date):
            return "LoanItem(totalResult: \(totalResult), item: \(item) date: \(date.timeIntervalSince1970))"
        case .CreditItem(_, let item, let date):
            return "CreditItem(item: \(item) date: \(date.timeIntervalSince1970))"
        case .InsuranceItem(_, let item, let date):
            return "InsuranceItem(item: \(item) date: \(date.timeIntervalSince1970))"
        case .EtcItem(_, let totalResult, let item, let date):
            return "EtcItem(totalResult: \(totalResult), item: \(item) date: \(date.timeIntervalSince1970))"
        case .AddItem(_, let date):
            return "CashItem(date: \(date.timeIntervalSince1970))"
        }
    }
    
}

extension PropertySectionItem {
    var totalAmount: String {
        switch self {
        case .AccountItem(_, let totalResult, _, _),
             .CardItem(_, let totalResult, _, _),
             .LoanItem(_, let totalResult, _, _):
            return totalResult.totalAmount
        case .EtcItem(_, let totalAmt, _, _):
            return totalAmt
        default:
            return ""
        }
    }
}

func == (lhs: PropertySection, rhs: PropertySection) -> Bool {
    return lhs.header == rhs.header && lhs.items == rhs.items && lhs.updated == rhs.updated
}
