//
//  PropertyUseCase.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class PropertyUseCase {
    
    private let provider = CashdocProvider<PropertyService>()
    private let disposeBag = DisposeBag()
    
    func postProperty(type: PropertyCardType, value: String) -> Single<PostpropertyResult> {
        return Single<PostpropertyResult>.create { (single) -> Disposable in
            
            func postPropertyData(value: String, single: @escaping (SingleEvent<PostpropertyResult>) -> Void) {
                _ = self.provider.request(Postproperty.self, token: .postProperty(type: type, value: value))
                    .map {$0.result}
                    .subscribe(onSuccess: { (model) in
                        single(.success(model))
                    }, onFailure: { (error) in
                        single(.failure(error))
                    })
            }
            
            if let cValue = AES256CBC.encryptCashdoc(value) {
                postPropertyData(value: cValue, single: single)
            }
            
            return Disposables.create()
        }
    }
    
    func getProperty(type: PropertyCardType) -> Driver<String> {
        return provider
            .request(GetProperty.self, token: .getProperty(type: type))
            .map {$0.result}
            .asDriverOnErrorJustNever()
    }
}
