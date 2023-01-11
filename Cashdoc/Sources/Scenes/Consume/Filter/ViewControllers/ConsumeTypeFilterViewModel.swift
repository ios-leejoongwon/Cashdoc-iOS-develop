//
//  ConsumeTypeFilterViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 22/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import Realm
import RealmSwift

final class ConsumeTypeFilterViewModel {
    
    // MARK: - Properties
    private var navigator: ConsumeNavigator!
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
        
    }
}

extension ConsumeTypeFilterViewModel: ViewModelType {
    struct Input {
    }
    
    struct Output {
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    func navigationControllerForLoading() -> UINavigationController {
        return navigator.navigationControllerForLoading()
    }

}
