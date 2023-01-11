//
//  PropertyViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import Moya
import SwiftyJSON

final class PropertyViewModel {
    
    private let navigator: PropertyNavigator
    private let useCase: PropertyUseCase
    private let disposeBag = DisposeBag()
    
    init(navigator: PropertyNavigator,
         useCase: PropertyUseCase) {
        self.navigator = navigator
        self.useCase = useCase
    }
}

// MARK: - ViewModelType

extension PropertyViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        let viewWillAppearTakeOne: Driver<Void>
        let refreshTrigger: Driver<Void>
    }
    struct Output {
        let eventItemFetching: Driver<EventItem>
        let linkStatusFetching: Driver<LinkStatus>
        let refreshFetching: Driver<Void>
        let getPropertyFromAPIFetching: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let eventItemFetching = PublishRelay<EventItem>()
        let linkStatusFetching = PublishRelay<LinkStatus>()
        let refreshFetching = PublishRelay<Void>()
        
        let isHaveDataAccountForApi = PublishRelay<Bool>()
        let isHaveDataCardForApi = PublishRelay<Bool>()
        let isHaveDataLoanForApi = PublishRelay<Bool>()
        
        let getPropertyFromAPITrigger = PublishRelay<Void>()
        let getPropertyFromAPIFetching = PublishRelay<Bool>()
        
        input.refreshTrigger
            .drive(onNext: { (_) in
                refreshFetching.accept(())
            })
            .disposed(by: disposeBag)
        
        let eventCard: Driver<EventItem> = input.trigger
            .flatMapLatest {(_) in
                return UserManager.shared.eventItem
                    .asDriverOnErrorJustNever()
        }
        
        eventCard
            .drive(onNext: { (eventItem) in
                eventItemFetching.accept(eventItem)
            })
            .disposed(by: disposeBag)
        
        let isLinked: Driver<Bool> = input.trigger
            .flatMapLatest { (_) -> Driver<Bool> in
                return UserDefaults.standard.rx.observe(Bool.self, UserDefaultKey.kIsLinkedProperty.rawValue)
                    .filterNil()
                    .distinctUntilChanged()
                    .asDriverOnErrorJustNever()
        }
        
        isLinked
            .drive(onNext: { (isLinked) in
                if isLinked {
                    linkStatusFetching.accept(.연동후)
                } else {
                    linkStatusFetching.accept(.연동전)
                }
            })
            .disposed(by: disposeBag)
        
        input.viewWillAppearTakeOne
            .drive(onNext: { (_) in
                guard !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinkedProperty.rawValue),
                    LinkedScrapingV2InfoRealmProxy().allLists.results.isEmpty else { return }
                getPropertyFromAPITrigger.accept(())
            })
            .disposed(by: disposeBag)
        
        let getAccount: Driver<String> = getPropertyFromAPITrigger.asDriverOnErrorJustNever()
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                return self.useCase.getProperty(type: .계좌)
                    .map { (account) in
                        guard let decAccount = AES256CBC.decryptCashdoc(account) else { return "" }
                        return decAccount
                }
        }

        let getCard: Driver<String> = getPropertyFromAPITrigger.asDriverOnErrorJustNever()
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                // "[{\"ECODE\":\"\",\"ERRMSG\":\"\",\"LIST\":[],\"requestFCODE\":\"\"}]"
                return self.useCase.getProperty(type: .카드)
                    .map { (card) in
                        guard let decAccount = AES256CBC.decryptCashdoc(card) else { return "" }
                        return decAccount
                }
        }

        let getLoan: Driver<String> = getPropertyFromAPITrigger.asDriverOnErrorJustNever()
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                return self.useCase.getProperty(type: .대출)
                    .map { (loan) in
                        guard let decAccount = AES256CBC.decryptCashdoc(loan) else { return "" }
                        return decAccount
                }
        }
        
        getAccount
            .drive(onNext: { [weak self] (account) in
                guard let self = self else { return }
                guard let data = account.data(using: .utf8),
                    let accountData = try? self.parse([PostAllAccountInBank].self, data: data) else { return }
                AccountListRealmProxy().appendForPost(accountData, completion: {
                    isHaveDataAccountForApi.accept(!AccountListRealmProxy().allListsForPropertyAccount.results.isEmpty)
                })
            })
            .disposed(by: disposeBag)
        
        getCard
            .drive(onNext: { [weak self] (card) in
                guard let self = self else { return }
                guard let data = card.data(using: .utf8),
                    let cardData = try? self.parse([PostCardPaymentDetails].self, data: data) else { return }
                CardPaymentRealmProxy().appendForPost(cardData, completion: {
                    isHaveDataCardForApi.accept(!CardPaymentRealmProxy().allListsForPropertyCard.results.isEmpty)
                })
            })
            .disposed(by: disposeBag)

        getLoan
            .drive(onNext: { [weak self] (loan) in
                guard let self = self else { return }
                guard let data = loan.data(using: .utf8) else { return }
                guard let loanAccountData = try? self.parse([PostAllAccountInBank].self, data: data) else {
                    guard let loanData = try? self.parse([PostCardLoanDetails].self, data: data) else {
                        Log.osh("loan parse error")
                        return
                    }
                    Log.osh("loan : \(loanData)")
                    return
                }
                AccountListRealmProxy().appendForPost(loanAccountData, completion: {
                    isHaveDataLoanForApi.accept(!AccountListRealmProxy().allListsForPropertyLoan.results.isEmpty)
                })
            })
            .disposed(by: disposeBag)
                
        Observable.merge(isHaveDataAccountForApi.asObservable(),
                                 isHaveDataCardForApi.asObservable(),
                                 isHaveDataLoanForApi.asObservable())
            .filter {$0}
            .bind { (_) in
                getPropertyFromAPIFetching.accept(true)
        }
        .disposed(by: disposeBag)

        return Output.init(eventItemFetching: eventItemFetching.asDriverOnErrorJustNever(),
                           linkStatusFetching: linkStatusFetching.asDriverOnErrorJustNever(),
                           refreshFetching: refreshFetching.asDriverOnErrorJustNever(),
                           getPropertyFromAPIFetching: getPropertyFromAPIFetching.asDriverOnErrorJustNever())
    }
    
    // MARK: - Internal methods
    
    func pushToLinkPropertyOneByOneViewController() {
        navigator.pushToLinkPropertyOneByOneViewController(propertyType: .은행)
    }
    
    func pushToInviteFriendViewController() {
        navigator.pushToInviteFriendViewController()
    }
    
    func pushToLinkPropertyViewController(isAnimated: Bool) {
        navigator.pushToLinkPropertyViewController(isAnimated: isAnimated)
    }
    
    func getNavigator() -> DefaultPropertyNavigator {
        return DefaultPropertyNavigator(parentViewController: self.navigator.getParentViewController())
    }
    
    // MARK: - Private methods
    
    private func parse<T>(_ modelType: T.Type, data: Data) throws -> T where T: Decodable {
        return try JSONDecoder().decode(modelType, from: data)
    }
    
}
