//
//  PropertyCheckAccountViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/18.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RealmSwift

final class PropertyCheckAccountViewModel {
    let performScpSubject: PublishSubject<PropertyCheckAccountViewController.ScpMapModel> = .init()
    let checkScpTrigger: PublishSubject<PropertyCheckAccountViewController.ScpMapModel> = .init()
    let filterSubject: PublishSubject<PropertyCheckAccountViewController.FilterType> = .init()
}

extension PropertyCheckAccountViewModel: ViewModelType {
    struct Input {
        let trigger: Observable<PropertyCheckAccountViewController.DataModel>
    }
    struct Output {
        let sections: Observable<[CheckAccountSection]>
    }
    func transform(input: Input) -> Output {
        let sections: Observable<[CheckAccountSection]> = input.trigger
            .flatMapLatest { (model) -> Observable<[CheckAccountSection]> in
                guard let number = model.number else { return .empty() }
                return Observable.collection(from: AccountTransactionRealmProxy().findOriginList(number: number))
                    .distinctUntilChanged()
                    .map { ($0, model) }
                    .do(onNext: self.checkPrev30DaysData(_:))
                    .map { $0.0 }
                    .map { $0.filter("tranDate >= %@", model.monthAgo.simpleDateFormat("yyyyMMdd")) }
                    .map { model.type != .전체 ? $0.filter("tranGb == %@", model.type.tranGb) : $0 }
                    .map { $0.sorted { $0.tranDate > $1.tranDate } }
                    .map { [weak self] (list) in
                        guard let self = self else { return .init() }
                        guard !list.isEmpty else { return .init() }
                        return self.setupCheckAccountSection(with: list)
                }
        }
        
        return Output(sections: sections)
    }
    
    private func checkPrev30DaysData(_ m: (results: Results<CheckAccountTransactionDetailsListOrigin>,
        model: PropertyCheckAccountViewController.DataModel)) {
        if m.results.filter("tranDate >= %@", GlobalFunction.firstDay(date: Date()).simpleDateFormat("yyyyMMdd")).isEmpty {
            let agoDate = m.model.monthAgo.simpleDateFormat("yyyyMMdd")
            if agoDate.month == Date().month {
                if let prevMonth = Date().getPreviousMonth() {
                    let dates: (String, String) = GlobalFunction.rangeOfCurrentMonth(prevMonth)
                    let mapModel: PropertyCheckAccountViewController.ScpMapModel = .init(dates: dates,
                                                                                         number: m.model.number)
                    self.checkScpTrigger.onNext(mapModel)
                }
            }
        }
    }
    
    private func setupCheckAccountSection(with lists: [CheckAccountTransactionDetailsListOrigin]) -> [CheckAccountSection] {
        var sections: [CheckAccountSection] = []
        var items: [CheckAccountSectionItem] = []
        var tranDate = String()
        items.append(.filterBtn)
        lists.forEach { (list) in
            let _tranDate = list.tranDate.simpleDateFormat("yyyyMMdd")
            if _tranDate != tranDate {
                if tranDate.isNotEmpty {
                    sections.append(.section(items: items))
                    items = []
                }
                
                tranDate = _tranDate
                let dateFormat = list.tranDate.year == Date().year ? "MM.dd" : "yyyy.MM.dd"
                let dateValue: (String, String) = GlobalFunction.convertToDate(date: tranDate, dateFormat: dateFormat)
                items.append(.header(date: dateValue))
            }
            let inoutBal: Int = list.tranGb == "출금" ? list.outBal : list.inBal
            items.append(.contents(item: .init(tranGb: list.tranGb,
                                               name: list.jukyo,
                                               time: list.tranDt,
                                               inoutBal: inoutBal,
                                               tranBal: list.tranBal)))
        }
        if tranDate.isNotEmpty, items.isNotEmpty {
            sections.append(.section(items: items))
            items = []
        }
        return sections
    }
    
    func makeDetilsItems(_ data: CheckAllAccountInBankList) -> ([String], [String]) {
        var leftItems: [String] = []
        var rightItems: [String] = []
        if let status = data.acctStatus {
            if let type = AccountType.init(rawValue: status)?.name, type.isNotEmpty {
                leftItems.append("계좌 종류")
                rightItems.append(type)
            }
        }
        if let open = data.openDate, open.isNotEmpty {
            leftItems.append("신규일")
            rightItems.append(open.toDateFormatted.isOrEmptyCD)
        }
        if let close = data.closeDate, close.isNotEmpty {
            leftItems.append("만기일")
            rightItems.append(close.toDateFormatted.isOrEmptyCD)
        }
        return (leftItems, rightItems)
    }
    
    func makeDates(_ monthAgo: String?) -> (String, String)? {
        guard let prevMonth = monthAgo?.simpleDateFormat("yyyyMMdd").getPreviousMonth() else { return nil }
        return GlobalFunction.rangeOfCurrentMonth(prevMonth)
    }
    
}
