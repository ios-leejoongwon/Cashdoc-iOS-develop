//
//  InsuranceLoginViewModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

class InsuranceLoginViewModel {
    let validatedUsername: Driver<CDValidationResult>
    let validatedPassword: Driver<CDValidationResult>
    let signupEnabled: Driver<Bool>
    
    init (username: Driver<String>, password: Driver<String>) {
        validatedUsername = username
            .flatMapLatest { username in
                return validateUsername(username)
                    .asDriver(onErrorJustReturn: .failed)
        }
        
        validatedPassword = password
            .flatMapLatest { password in
                return InsuranceJoin03VC.setPWValid(password)
                    .asDriver(onErrorJustReturn: .failed)
        }
        
        signupEnabled = Driver.combineLatest(
            validatedUsername,
            validatedPassword
        ) { username, password in
            username.isValid &&
                password.isValid
        }
        .distinctUntilChanged()
            
        func validateUsername(_ username: String) -> Driver<CDValidationResult> {
            let userDefaultText = "영문자, 숫자 조합 6~12자리"
            
            if username.isEmpty {
                return .just(.empty(message: userDefaultText))
            }
            
            if username.count < 6 {
                return .just(.validating(message: userDefaultText))
            }

            var haveNotMatch = 0
            // 한글이 포함
            if GlobalFunction.matches(for: "[ㄱ-힣]", in: username) != 0 {
                haveNotMatch += 1
            }
            
            if haveNotMatch == 0 {
                return .just(.ok(message: userDefaultText))
            } else {
                return .just(.failed)
            }
        }
    }
}
