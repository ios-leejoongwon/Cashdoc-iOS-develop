//
//  ConsumeUseCase.swift
//  Cashdoc
//
//  Created by Taejune Jung on 08/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ConsumeUseCase {
    private let provider = CashdocProvider<ConsumeService>()
    private let disposeBag = DisposeBag()
    
    func postConsume(value: String, date: String) -> Single<PostConsumeResult> {
        return Single<PostConsumeResult>.create { (single) -> Disposable in
            
            func postConsumeData(value: String, single: @escaping (SingleEvent<PostConsumeResult>) -> Void) {
                _ = self.provider.request(PostConsume.self, token: .upload(value: value, date: date))
                                   .map {$0.result}
                                   .subscribe(onSuccess: { [weak self] (model) in
                                    guard let self = self else { return }
                                    self.saveCurrentDateTimeStamp()
                                    single(.success(model))
                                   }, onFailure: { (error) in
                                    single(.failure(error))
                                   })
            }
            
            if let cValue = AES256CBC.encryptCashdoc(value) {
                postConsumeData(value: cValue, single: single)
            }
            
            return Disposables.create()
        }
    }
    
    private func saveCurrentDateTimeStamp() {
        let currentDate = Date().timeIntervalSince1970
        UserDefaults.standard.set(currentDate, forKey: UserDefaultKey.kConsumeUploadTimestamp.rawValue)
    }
}
