//
//  EventCardViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 29/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class EventCardViewModel {
    
    private let disposeBag = DisposeBag()
    private let useCase = EventCardUseCase()
    
}

extension EventCardViewModel: ViewModelType {
    struct Input {
        let putEventCardTrigger: Driver<Void>
    }
    struct Output {
        let closeButtonFetching: Driver<PutEventInitFront>
        let hiddenFetchingWithClose: Driver<Void>
    }
    func transform(input: Input) -> Output {
        let closeButtonFetching = PublishRelay<PutEventInitFront>()
        
        let putInitFront: Driver<PutEventInitFront> = input.putEventCardTrigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self else {return Driver.empty()}
                
                return self.useCase.putFlagToHideEventCard()
        }
        
        putInitFront
            .drive(onNext: { (initFront) in
                UserManager.shared.getUser { error in
                    if error == nil {
                        closeButtonFetching.accept(initFront)
                    }
                }
        })
        .disposed(by: disposeBag)
        
        let hiddenFetching = closeButtonFetching.filter {$0.eventShow == 0}.mapToVoid()
        
        return Output(closeButtonFetching: closeButtonFetching.asDriverOnErrorJustNever(),
                      hiddenFetchingWithClose: hiddenFetching.asDriverOnErrorJustNever())
    }
}
