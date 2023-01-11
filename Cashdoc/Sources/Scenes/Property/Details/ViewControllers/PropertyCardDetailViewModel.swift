//
//  PropertyCardDetailViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

final class PropertyCardDetailViewModel {
    
    private var navigator: PropertyNavigator!
    private let disposeBag = DisposeBag()
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

extension PropertyCardDetailViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<String>
    }
    struct Output {
        let sections: Driver<[CardDetailSection]>
    }
    func transform(input: Input) -> Output {
        
        let sections: Driver<[CardDetailSection]> = input.trigger
            .flatMapLatest { (identity) in
                guard let list = CardPaymentRealmProxy().card(identity: identity).results.first?.payestList else {return Driver.empty()}
                return Observable.just(list)
                    .map({ (list) in
                        var sections = [CardDetailSection]()
                        sections.append(self.setupCardDetailSection(with: list))
                        return sections
                    })
                    .asDriverOnErrorJustNever()
        }
        
        return Output(sections: sections)
    }
    // MARK: - Private methods
    
    private func setupCardDetailSection(with list: List<CheckCardPaymentDetailsPayestList>) -> CardDetailSection {
        let amtSorted = list.sorted(byKeyPath: "intAmount", ascending: false)
        let sortedCardDatas = amtSorted.sorted(byKeyPath: "aSaleDate", ascending: false)
        
        var items: [CardDetailSectionItem] = []

        var aSaleDate = String()
        var amountDic = [String: Int]()
        
        sortedCardDatas.forEach { (card) in
            if let currentASaleDate = card.aSaleDate {
                
                if currentASaleDate != aSaleDate {
                    aSaleDate = currentASaleDate
                    
                    let totalAmt = calculateTotalAmountByDate(with: sortedCardDatas, by: aSaleDate)
                    
                    let convertToDate = GlobalFunction.convertToDate(date: aSaleDate, dateFormat: "MM.dd")
                    let _aSaleDate = "\(convertToDate.0) \(convertToDate.1)"
                    amountDic.updateValue(totalAmt, forKey: _aSaleDate)
                    
                    items.append(.header(item: CardDetailHeaderItem(date: _aSaleDate),
                                         totalAmt: amountDic))
                }
            }
            
            guard let name = card.mbrmchName,
                let askNth = card.askNth else { return }
            let installment = setInstallment(with: askNth)
            
            items.append(.contents(item: CardDetailContentItem(name: name,
                                                               installment: installment,
                                                               amount: card.calculatedAmount())))
        }
        
        return .section(items: items)
    }
    
    private func setInstallment(with askNth: String) -> String {
        // 일단 일시불 or 할부로 보여주기로 함..
//        return askNth.isEmpty || askNth == "0" ? "일시불" : String(format: "할부개월/회차 %@/%@", rmainNth, askNth)
        return askNth.isEmpty || askNth == "0" ? "일시불" : "할부"
    }
    
    private func calculateTotalAmountByDate(with list: Results<CheckCardPaymentDetailsPayestList>,
                                            by aSaleDate: String) -> Int {
        let filteredList = list.filter("aSaleDate == '\(aSaleDate)'")
        
        var total: Int = 0
        filteredList.forEach { (value) in
            let amt = value.calculatedAmount()
            guard let intAmt = Int(amt) else { return }
            total += intAmt
        }
        return total
    }
    
}
