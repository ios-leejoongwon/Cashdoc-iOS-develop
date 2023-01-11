//
//  InitialViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class InitialViewModel {
    
    private let navigator: LoginNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: LoginNavigator) {
        self.navigator = navigator
    }
    
}

// MARK: - ViewModelType

extension InitialViewModel: ViewModelType {
    
    struct Input {
        let okTrigger: Driver<Void>
    }
    struct Output {
    }
    
    func transform(input: Input) -> Output {
        input.okTrigger
            .drive(onNext: { (_) in
                LoginManager.replaceRootViewController()
            })
            .disposed(by: disposeBag)
        return Output()
    }
    
}
