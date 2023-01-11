//
//  HowToImportCertificateViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class HowToImportCertificateViewModel {
    
    private let navigator: PropertyNavigator!
    private let useCase: LinkPropertyUseCase!
    private let disposeBag = DisposeBag()
    
    init(navigator: PropertyNavigator, useCase: LinkPropertyUseCase) {
        self.navigator = navigator
        self.useCase = useCase
    }
}

// MARK: - ViewModelType

extension HowToImportCertificateViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
        let selection: Driver<String?>
    }
    struct Output {
        let authKey: Driver<String>
        let certFetching: Driver<Int>
        let fetching: Driver<Void>
        let networkErrorFetching: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let fetching = PublishRelay<Void>()
        let certFetching = PublishRelay<Int>()
        let networkErrorFetching = PublishRelay<Void>()
        
        let authKey: Driver<String> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard ReachabilityManager.reachability.connection != .unavailable,
                    let self = self else {
                        networkErrorFetching.accept(())
                        return Driver.empty()
                }
                
                return self.useCase.getAuthKey()
        }
        
        let importCert = input.selection
            .flatMapLatest { (authKey) in
                return self.useCase.importCertification(authKey: authKey,
                                                        fetching: certFetching,
                                                        networkError: networkErrorFetching)
                    .asDriverOnErrorJustNever()
        }
        
        importCert
            .drive(onNext: { (_) in
                fetching.accept(())
            })
            .disposed(by: disposeBag)
        
        return Output(authKey: authKey,
                      certFetching: certFetching.asDriverOnErrorJustNever(),
                      fetching: fetching.asDriverOnErrorJustNever(),
                      networkErrorFetching: networkErrorFetching.asDriverOnErrorJustNever())
    }
    
    // MARK: - Internal methods
    
    func pushToLinkPropertyLoginViewController(linkType: HowToLinkType,
                                               fCodeName: String?,
                                               completion: SimpleCompletion? = nil) {
        var bankInfo = BankInfo(bankName: "",
                                isLinked: false,
                                isCanLogin: false)
        var propertyType: LinkPropertyChildType = .ALL
        
        if linkType == .하나씩연결,
            let fCodeName = fCodeName,
            let type = FCode(rawValue: fCodeName)?.type {
            let isLinked: Bool = LinkedScrapingV2InfoRealmProxy().isLinked(with: fCodeName)
            if let isCanLogin = FCode(rawValue: fCodeName)?.isCanLogin {
                bankInfo = BankInfo(bankName: fCodeName,
                isLinked: isLinked,
                isCanLogin: isCanLogin)
            }
            propertyType = type
        }
        
        navigator.pushToLinkPropertyLoginViewController(linkType: linkType,
                                                        propertyType: propertyType,
                                                        bankInfo: bankInfo)
        completion?()
    }
    
    func parentViewControllerForScraping() -> UIViewController {
        return navigator.getParentViewController()
    }
}
