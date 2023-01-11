//
//  PropertyTableViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift
import RxRealm
import RxOptional
import LocalAuthentication

final class PropertyTableViewModel {
    
    private let navigator: PropertyNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

// MARK: - ViewModelType

extension PropertyTableViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let totalAmountFetching: Observable<Int>
        let sections: Driver<[PropertySection]>
    }
    
    func transform(input: Input) -> Output {
        let cashFetching = PublishRelay<Void>()
        let accountFetching = PublishRelay<Void>()
        let cardFetching = PublishRelay<Void>()
        let loanFetching = PublishRelay<Void>()
        let creditFetching = PublishRelay<Void>()
        let insuranceFetching = PublishRelay<Void>()
        let etcPropertyFetching = PublishRelay<Void>()
        
        let totalAmountFetching = BehaviorRelay<Int>(value: 0)
        
        let scrapingInfoList = LinkedScrapingV2InfoRealmProxy().allLists.results
        
        let cashItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard self != nil else {return Driver.empty()}
                return UserManager.shared.user
                    .map { (user) in
                        return PropertySectionItem.CashItem(identity: 0,
                                                            item: PropertyExpandCash(type: .캐시, point: user.point ?? 0),
                                                            date: Date())
                }
                .asDriverOnErrorJustNever()
        }
        
        let accountItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                return self.getAccountsRealmData()
                    .map({ (accountList) in
                        let sectionItem = self.setAccountSectionItem(with: accountList,
                                                                     scrapingInfoList: scrapingInfoList)
                        return sectionItem
                    })
        }
        
        let cardItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { [weak self] _ in
                guard let self = self else {return Driver.empty()}
                return self.getCardsRealmData()
                    .map({ (paymentList) in
                        let sectionItem = self.setCardSectionItem(paymentList: paymentList,
                                                                  scrapingInfoList: scrapingInfoList)
                        return sectionItem
                    })
        }
        
        let loanItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { [weak self] _ in
                guard let self = self else {return Driver.empty()}
                return self.getLoansRealmData()
                    .map({ (accountLoanList, cardLoanList) in
                        let sectionItem = self.setLoanSectionItem(accountLoanList: accountLoanList,
                                                                  cardLoanList: cardLoanList,
                                                                  scrapingInfoList: scrapingInfoList)
                        return sectionItem
                    })
        }
        
        let creditItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { (_) in
                let section = PropertySectionItem.CreditItem(identity: 4,
                                   item: PropertyExpandCredit(type: .신용, rating: "", score: ""),
                                   date: Date())
                return Driver.just(section)
        }

        let insItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { [weak self] (_) -> Driver<PropertySectionItem> in
                guard let self = self else { return .empty()}
                return self.getInsuranceRealmData()
                    .map { (jResults, sResults) in
                        let jArray = jResults.toArray()
                        let sArray = sResults.toArray()
                        
                        let count = jArray.count + sArray.count
                        var totalWon = 0
                        
                        for jModel in jArray {
                            totalWon += Int(jModel.ILHOIBOHUMRYO) ?? 0
                        }
                        let sectionItem: PropertySectionItem = .InsuranceItem(identity: 5,
                                                                              item: PropertyExpandInsurance(type: .보험, count: count, total: totalWon),
                                                                              date: Date())
                        return sectionItem
                }
        }
        
        let etcItems: Driver<PropertySectionItem> = input.trigger
            .flatMapLatest { [weak self] (_) -> Driver<PropertySectionItem> in
                guard let self = self else { return .empty()}
                return self.getEtcPropertyRealmData()
                    .map { (results) -> PropertySectionItem in
                        let sectionItem: PropertySectionItem = self.setEtcPropertySectionItem(with: results)
                        return sectionItem
                }
        }
        
        cashItems
            .drive(onNext: { (_) in
                cashFetching.accept(())
            }).disposed(by: disposeBag)
        
        accountItems
            .drive(onNext: { (_) in
                accountFetching.accept(())
            }).disposed(by: disposeBag)
        
        cardItems
            .drive(onNext: { (_) in
                cardFetching.accept(())
            }).disposed(by: disposeBag)
        
        loanItems
            .drive(onNext: { (_) in
                loanFetching.accept(())
            }).disposed(by: disposeBag)
        
        creditItems
            .drive(onNext: { (_) in
                creditFetching.accept(())
            }).disposed(by: disposeBag)
                
        insItems
            .drive(onNext: { (_) in
                insuranceFetching.accept(())
            }).disposed(by: disposeBag)
        
        etcItems
            .drive(onNext: { (_) in
                etcPropertyFetching.accept(())
            }).disposed(by: disposeBag)
        
        let mergeSectionsFetching: Driver<Void> = Observable.of(cashFetching,
                                                                accountFetching,
                                                                cardFetching,
                                                                loanFetching,
                                                                creditFetching,
                                                                insuranceFetching,
                                                                etcPropertyFetching)
            .merge()
            .asDriverOnErrorJustNever()
        
        let sectionsTrigger: Driver<Void> = Observable.just(mergeSectionsFetching)
            .startWith(input.trigger)
            .merge()
            .asDriverOnErrorJustNever()
        
        let sections: Driver<[PropertySection]> = sectionsTrigger
            .flatMapLatest { _ in
                
                return Observable.zip(cashItems.asObservable(),
                                      accountItems.asObservable(),
                                      cardItems.asObservable(),
                                      loanItems.asObservable(),
                                      creditItems.asObservable(),
                                      insItems.asObservable(),
                                      etcItems.asObservable())
                    
                    .asDriverOnErrorJustNever()
                    .map({ (cash, account, card, loan, credit, insurance, etc) in
                        var sections = [PropertySection]()
                        sections.append(.init(header: "cash", propertyItems: [cash], updated: Date()))
                        sections.append(.init(header: "account", propertyItems: [account], updated: Date()))
                        sections.append(.init(header: "card", propertyItems: [card], updated: Date()))
                        sections.append(.init(header: "credit", propertyItems: [credit], updated: Date()))
                        sections.append(.init(header: "loan", propertyItems: [loan], updated: Date()))
//                        sections.append(.init(header: "credit", propertyItems: [credit], updated: Date()))
                        sections.append(.init(header: "insurance", propertyItems: [insurance], updated: Date()))
                        sections.append(.init(header: "etc", propertyItems: [etc], updated: Date()))
                        sections.append(.init(header: "add", propertyItems: [.AddItem(identity: 7, date: Date())], updated: Date()))
                        
                        var total: Int = 0
                        if let cash = Int(cash.totalAmount) {
                            total += cash
                        }
                        if let account = Int(account.totalAmount) {
                            total += account
                        }
                        if let card = Int(card.totalAmount) {
                            total += card
                        }
                        if let loan = Int(loan.totalAmount) {
                            total += loan
                        }
                        if let etc = Int(etc.totalAmount) {
                            total += etc
                        }
                        
                        totalAmountFetching.accept(total)
                        
                        return sections
                    })
        }
        
        return Output(totalAmountFetching: totalAmountFetching.asObservable(),
                      sections: sections)
    }
    
    // MARK: - Internal methods
    
    func pushToLinkPropertyViewController(isAnimated: Bool) {
        navigator.pushToLinkPropertyViewController(isAnimated: isAnimated)
    }
    
    func pushToLinkPropertyOneByOneViewController() {
        navigator.pushToLinkPropertyOneByOneViewController(propertyType: .은행)
    }
    
    func pushToCashViewController() {
        navigator.pushToCashViewController()
    }
    
    func setNavigator() -> PropertyNavigator {
        return self.navigator
    }
    
    // MARK: - DB UseCase Private methods
    
    private func getAccountsRealmData() -> Driver<Results<CheckAllAccountInBankList>> {
        let filtedList = AccountListRealmProxy().allListsForPropertyAccount.results
        let acctStatusSortedList = filtedList.sorted(byKeyPath: "acctStatus", ascending: true)
        let accountList = acctStatusSortedList.sorted(byKeyPath: "fCodeIndex", ascending: true)

        return Observable.collection(from: accountList)
            .asDriverOnErrorJustNever()
    }
    
    private func getCardsRealmData() -> Driver<Results<CheckCardPaymentDetailsList>> {
        let filtedList = CardPaymentRealmProxy().allListsForPropertyCard.results
        let paymentList = filtedList.sorted(byKeyPath: "fCodeIndex", ascending: true)
        
        return Observable.collection(from: paymentList)
            .asDriverOnErrorJustNever()
    }
    
    private func getLoansRealmData() -> Driver<(Results<CheckAllAccountInBankList>, Results<CheckCardLoanDetailsList>)> {
        let aFiltedList = AccountListRealmProxy().allListsForPropertyLoan.results
        let accountList = aFiltedList.sorted(byKeyPath: "fCodeIndex", ascending: true)
        
        let lFiltedList = CardLoanListRealmProxy().allListsForPropertyLoan.results
        let loanList = lFiltedList.sorted(byKeyPath: "fCodeIndex", ascending: true)
        
        return Observable.combineLatest(Observable.collection(from: accountList),
                                        Observable.collection(from: loanList))
            .asDriverOnErrorJustNever()
    }
    
    private func getInsuranceRealmData() -> Driver<(Results<InsuranceJListModel>, Results<InsuranceSListModel>)> {
        let jResults = InsuranListRealmProxy().query(InsuranceJListModel.self).results
        let sResults = InsuranListRealmProxy().query(InsuranceSListModel.self).results
        
        return Observable.combineLatest(Observable.collection(from: jResults),
                                        Observable.collection(from: sResults))
            .asDriverOnErrorJustNever()
    }
    
    private func getEtcPropertyRealmData() -> Driver<Results<EtcPropertyList>> {
        let list = EtcPropertyRealmProxy().query(EtcPropertyList.self, sortProperty: "balance", ordering: .descending).results
        
        return Observable.collection(from: list)
            .asDriverOnErrorJustNever()
    }
    
    // MARK: - Private methods
    
    private func setAccountSectionItem(with accountList: Results<CheckAllAccountInBankList>,
                                       scrapingInfoList: Results<LinkedScrapingInfo>) -> PropertySectionItem {
        var bankName = String()
        
        var bankTotalAmount: Int = 0
        var totalAmount: Int = 0
        var bankInfoDic = [String: String]()
        
        var items = [PropertyExpandAccount]()
        
        for account in accountList {
            if let currentBankName: String = account.fCodeName,
                let amount: String = account.curBal,
                let intAmount: Int = Int(amount) {
                if currentBankName != bankName {
                    bankName = currentBankName
                    bankTotalAmount = intAmount
                } else {
                    bankTotalAmount += intAmount
                }
            }
            if let identity = account.identity {
                let item: PropertyExpandAccount = PropertyExpandAccount(identity: identity,
                                                                        bankName: bankName,
                                                                        type: account.acctStatus ?? "-",
                                                                        title: account.acctKind ?? "-",
                                                                        number: account.number,
                                                                        amount: account.curBal ?? "0",
                                                                        isHandWrite: account.isHandWrite)
                items.append(item)
                totalAmount += Int(account.curBal ?? "0") ?? 0
                bankInfoDic.updateValue(String(bankTotalAmount), forKey: bankName)
            }
        }
        
        let resultTotalItem: PropertyTotalResult = PropertyTotalResult(totalAmount: String(totalAmount),
                                                  bankInfo: bankInfoDic,
                                                  scrapingInfoList: scrapingInfoList)
        
        return .AccountItem(identity: 1,
                            totalResult: resultTotalItem,
                            item: items,
                            date: Date())
    }
    
    private func setCardSectionItem(paymentList: Results<CheckCardPaymentDetailsList>,
                                    scrapingInfoList: Results<LinkedScrapingInfo>) -> PropertySectionItem {
        var items = [PropertyExpandCard]()
        var totalAmount: Int = 0
        
        for payment in paymentList {
            
            if let identity: String = payment.identity {
                let item: PropertyExpandCard = PropertyExpandCard(name: payment.fCodeName ?? "-",
                                                                  paymentDate: payment.estDate ?? "-",
                                                                  amount: String(format: "-%@", payment.estAmt ?? "0"),
                                                                  identity: identity)
                items.append(item)
                totalAmount += Int(payment.estAmt ?? "0") ?? 0
            }
        }
        let resultTotalItem: PropertyTotalResult = PropertyTotalResult(totalAmount: String(format: "-%ld", totalAmount),
                                                  scrapingInfoList: scrapingInfoList)
        
        return .CardItem(identity: 2, totalResult: resultTotalItem, item: items, date: Date())
    }
    
    private func setLoanSectionItem(accountLoanList: Results<CheckAllAccountInBankList>,
                                    cardLoanList: Results<CheckCardLoanDetailsList>,
                                    scrapingInfoList: Results<LinkedScrapingInfo>) -> PropertySectionItem {
        var bankName: String = String()
        var cardName: String = String()
        
        var bankTotalAmount: Int = 0
        var cardTotalAmount: Int = 0
        
        var totalAmount: Int = 0
        var loanInfoDic: [String: String] = [:]
        
        var items = [PropertyExpandLoan]()
        
        if !accountLoanList.isEmpty {
            for loan in accountLoanList {
                if let currentBankName: String = loan.fCodeName,
                    let amount: String = loan.loanCurBal,
                    let intAmount: Int = Int(amount) {
                    if currentBankName != bankName {
                        bankName = currentBankName
                        bankTotalAmount = intAmount
                    } else {
                        bankTotalAmount += intAmount
                    }
                }
                
                if let identity: String = loan.identity {
                    let item: PropertyExpandLoan = PropertyExpandLoan(fCodeName: bankName,
                                                                      name: loan.acctKind ?? "-",
                                                                      number: loan.number ?? "-",
                                                                      amount: String(format: "-%@", loan.loanCurBal ?? "0"),
                                                                      identity: identity,
                                                                      isHandWrite: loan.isHandWrite)
                    items.append(item)
                    totalAmount += Int(loan.loanCurBal ?? "0") ?? 0
                    loanInfoDic.updateValue(String(bankTotalAmount * -1), forKey: bankName)
                }
            }
        }
        
        if !cardLoanList.isEmpty {
            for loan in cardLoanList {
                if let currentCardName: String = loan.fCodeName,
                    let amount: String = loan.loanAmt,
                    let intAmount: Int = Int(amount) {
                    if currentCardName != cardName {
                        cardName = currentCardName
                        cardTotalAmount = intAmount
                    } else {
                        cardTotalAmount += intAmount
                    }
                }
                
                if let identity: String = loan.identity {
                    let name: String = loan.loanTitle != nil ? loan.loanTitle ?? "-" : setLoanName(with: loan.loanGubun ?? "1")
                    let item: PropertyExpandLoan = PropertyExpandLoan(fCodeName: cardName,
                                                                      name: name,
                                                                      number: cardName,
                                                                      amount: String(format: "-%@", loan.loanAmt ?? "0"),
                                                                      identity: identity,
                                                                      isHandWrite: false)
                    items.append(item)
                    totalAmount += Int(loan.loanAmt ?? "0") ?? 0
                    loanInfoDic.updateValue(String(cardTotalAmount * -1), forKey: cardName)
                }
            }
        }
        
        let resultTotalItem: PropertyTotalResult = PropertyTotalResult(totalAmount: String(totalAmount * -1),
                                                  bankInfo: loanInfoDic,
                                                  scrapingInfoList: scrapingInfoList)
        
        return .LoanItem(identity: 3, totalResult: resultTotalItem, item: items, date: Date())
    }
    
    private func setLoanName(with gubun: String) -> String {
        return gubun == "1" ? "단기카드대출" : "장기카드대출"
    }
    
    private func setEtcPropertySectionItem(with list: Results<EtcPropertyList>) -> PropertySectionItem {
        var items: [EtcPropertyList] = .init()
        var totalAmount: Int = 0
        for item in list {
            totalAmount += item.balance
            items.append(item)
        }
        return .EtcItem(identity: 6, totalAmt: String(totalAmount), item: items, date: Date())
    }
    
}
