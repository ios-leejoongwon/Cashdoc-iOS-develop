//
//  ProfileViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class InquireViewModel {
    
    private let navigator: MoreNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: MoreNavigator) {
        self.navigator = navigator
    }
    
}

extension InquireViewModel: ViewModelType {
    
    struct Input {
        
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
}
