//
//  AuthViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 10/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class AuthViewModel {
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private let useCase: AuthUseCase
    
    // MARK: - Con(De)structor
    
    init(useCase: AuthUseCase) {
        self.useCase = useCase
    }
    
}

extension AuthViewModel: ViewModelType {
    
    struct Input {
    }
    struct Output {
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    func sendAuthSms(toPhone phoneNumber: String, onError: @escaping ((Error) throws -> Void)) -> Driver<(String, ErrorModel?)> {
        let result = self.useCase.getAuthSms(by: phoneNumber, onError: onError)
        
        return result
    }
    
    func validateSms(by code: String, onError: @escaping ((Error) throws -> Void)) -> Driver<String> {
        return self.useCase.postAuthSms(by: code, onError: onError)
    }
    
}
