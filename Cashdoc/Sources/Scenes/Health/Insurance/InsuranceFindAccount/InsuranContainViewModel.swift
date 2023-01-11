//
//  InsuranContainViewModel.swift
//  Cashdoc
//
//  Created by bzjoowan on 2019/12/18.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

class InsuranContainViewModel {
    let validatedUsername: Driver<CDValidationResult>
    let validatedJumin: Driver<CDValidationResult>
    let validatedPhone: Driver<CDValidationResult>
    let validatedEmail: Driver<CDValidationResult>
    let validatedID: Driver<CDValidationResult>
    let validatedPassword: Driver<CDValidationResult>
    let nextEnabled: Driver<Bool>
    
    init (usernameD: Driver<String>,
          jumin01D: Driver<String>,
          jumin02D: Driver<String>,
          phone01D: Driver<Int>,
          phone02D: Driver<String>,
          emailD: Driver<String>?,
          loginIDD: Driver<String>,
          passWordD: Driver<String>?
    ) {
        validatedUsername = usernameD
            .flatMapLatest { checkString in
                return InsuranContainViewModel.setUsernameValid(checkString)
                    .asDriver(onErrorJustReturn: .failed)
        }
        
        validatedJumin = Driver.combineLatest(jumin01D, jumin02D, resultSelector: InsuranContainViewModel.setJuminValid)
        
        validatedPhone = Driver.combineLatest(phone01D, phone02D, resultSelector: InsuranContainViewModel.setPhoneValid)
                
        if let getEmail = emailD {
            validatedEmail = getEmail
                .flatMapLatest { checkString in
                    return InsuranContainViewModel.setEmailValid(checkString)
                        .asDriver(onErrorJustReturn: .failed)
            }
        } else {
            validatedEmail = Driver.just(.ok(message: ""))
        }
        
        validatedID = loginIDD
            .flatMapLatest { checkString in
                return InsuranContainViewModel.setIDValid(checkString)
                    .asDriver(onErrorJustReturn: .failed)
        }
        
        if let getPassWordD = passWordD {
            validatedPassword = getPassWordD
                .flatMapLatest { checkString in
                    return InsuranceJoin03VC.setPWValid(checkString)
                        .asDriver(onErrorJustReturn: .failed)
            }
        } else {
            validatedPassword = Driver.just(.ok(message: ""))
        }
        
        nextEnabled = Driver.combineLatest(
        validatedUsername, validatedJumin, validatedPhone, validatedEmail, validatedID, validatedPassword) { val01, val02, val03, val04, val05, val06 in
            val01.isValid && val02.isValid && val03.isValid && val04.isValid && val05.isValid && val06.isValid
        }
        .distinctUntilChanged()
    }
}

extension InsuranContainViewModel {
    class func setUsernameValid(_ validString: String) -> Driver<CDValidationResult> {
        let defaultText = ""
        
        if validString.isEmpty {
            return .just(.empty(message: defaultText))
        } else {
            return .just(.ok(message: defaultText))
        }
    }
    
    class func setJuminValid(_ validString01: String, validString02: String) -> CDValidationResult {
        let defaultText = ""
        
        if validString01.isEmpty || validString02.isEmpty {
            return .empty(message: defaultText)
        }
            
        let numbers = validString01 + validString02
        
        if numbers.count < 13 {
            return .failed
        }

        if numbers.count == 13 {
            if GlobalFunction.isJumin(numbers: numbers) {
                return .ok(message: defaultText)
            } else {
                return .failed
            }
        }
        return .failed
    }
    
    class func setPhoneValid(_ selIndex: Int, validString: String) -> CDValidationResult {
        let defaultText = ""
                
        if validString.isEmpty {
            return .empty(message: defaultText)
        }
        
        if validString.count > 10 {
            if GlobalFunction.isPhone(candidate: validString), selIndex != 0 {
                return .ok(message: defaultText)
            } else {
                return .failed
            }
        } else {
            return .failed
        }
    }
    
    class func setEmailValid(_ validString: String) -> Driver<CDValidationResult> {
        let defaultText = ""
        
        if validString.isEmpty {
            return .just(.empty(message: defaultText))
        }
        
        if GlobalFunction.isEmail(email: validString) {
            return .just(.ok(message: defaultText))
        } else {
            return .just(.failed)
        }
    }
    
    class func setIDValid(_ validString: String) -> Driver<CDValidationResult> {
        let defaultText = ""
        
        if validString.isEmpty {
            return .just(.empty(message: defaultText))
        }
        
        if validString.count < 6 {
            return .just(.validating(message: validString))
        }
        
        var haveNotMatch = 0
        // 한글이 포함
        if GlobalFunction.matches(for: "[ㄱ-힣]", in: validString) != 0 {
            haveNotMatch += 1
        }
        
        if haveNotMatch == 0 {
            return .just(.ok(message: validString))
        } else {
            return .just(.failed)
        }
    }
}
