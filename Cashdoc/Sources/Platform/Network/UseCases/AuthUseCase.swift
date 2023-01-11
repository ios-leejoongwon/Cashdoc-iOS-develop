//
//  AuthUseCase.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 10/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

class AuthUseCase {
    
    private let provider = CashdocProvider<AuthService>()
    
    func postAuthSms(by code: String, onError: @escaping ((Error) throws -> Void)) -> Driver<String> {
        return provider.request(DefaultApiResponse<String>.self, token: .postAuthSms(code: code))
            .do(onError: onError)
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func getAuthSms(by phoneNumber: String, onError: @escaping ((Error) throws -> Void)) -> Driver<(String, ErrorModel?)> {
        return provider.request(DefaultApiResponse<String>.self, token: .getAuthSms(phone: phoneNumber))
            .do(onError: onError)
            .asDriverOnErrorJustNever()
            .map {($0.result, $0.error)}
    }
}
