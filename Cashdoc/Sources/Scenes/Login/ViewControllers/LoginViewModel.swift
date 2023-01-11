//
//  LoginViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class LoginViewModel {
    
    private let navigator: LoginNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: LoginNavigator) {
        self.navigator = navigator
    }
    
}

// MARK: - ViewModelType

extension LoginViewModel: ViewModelType {
    
    struct Input {
    }
    struct Output {
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    // MARK: - Internal methods
    
    func pushToTermOfService(loginInput: LoginInput) {
        navigator.pushToTermOfService(loginInput: loginInput)
    }
    
    func pushToPasswordViewController(type: PasswordType) {
        navigator.pushToPasswordViewController(type: type)
    }
}
