//
//  ConsumeLinkBeforeViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 05/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class ConsumeLinkBeforeViewModel {
    
    private let disposeBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension ConsumeLinkBeforeViewModel: ViewModelType {
    struct Input {
        let clickedGetListButton: Driver<Void>
    }
    struct Output {
        let isScrapingTotalCert: Driver<Void>
    }
    func transform(input: Input) -> Output {
        let isScraping = PublishRelay<Void>()
        
        input.clickedGetListButton
            .drive(onNext: { [weak self] (_) in
                guard let self = self else {return}
                if !SmartAIBManager.checkIsDoingPropertyScraping() {
                    GlobalFunction.FirLog(string: "가계부_미연동_연결하고편해지기_클릭")
                    self.navigator.pushToLinkPropertyViewController(isAnimated: true)
                } else {
                    isScraping.accept(())
                }
            })
            .disposed(by: disposeBag)
        
        return Output(isScrapingTotalCert: isScraping.asDriverOnErrorJustNever())
    }
}
