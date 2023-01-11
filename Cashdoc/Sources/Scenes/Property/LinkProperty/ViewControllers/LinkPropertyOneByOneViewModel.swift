//
//  LinkPropertyOneByOneViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 28/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class LinkPropertyOneByOneViewModel {
    
    private let navigator: PropertyNavigator!
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

extension LinkPropertyOneByOneViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        
    }
    func transform(input: Input) -> Output {
        
        return Output()
    }
}
