//
//  ProfileViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class CurrentCashViewModel {
    
    private let useCase: PointUseCase
    private let navigator: MoreNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: MoreNavigator, useCase: PointUseCase) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
}

extension CurrentCashViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
        
    }
    struct Output {
        let point: Driver<CurrentPoint>
        let error: Driver<Error>
    }
    
    func transform(input: Input) -> Output {
        let getError = PublishRelay<Error>()
        let point: Driver<CurrentPoint> = input.trigger
            .flatMap { [weak self] _ in
                guard let self = self else { return Driver.empty() }
                return self.useCase.getCurrentPoint(getError: getError)
        }
        
        return Output(point: point, error: getError.asDriverOnErrorJustNever())
    }
}
