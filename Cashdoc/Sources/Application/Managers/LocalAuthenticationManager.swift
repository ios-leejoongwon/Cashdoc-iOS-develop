//
//  LocalAuthenticationManager.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import LocalAuthentication

import RxSwift
import Then

enum LocalAuthentication {
    static func performAuthentication() -> Single<Void> {
        return Single<Void>.create(subscribe: { observer -> Disposable in
            let disposable = Disposables.create()
            
            let localAuthenticationContext = LAContext().then {
                $0.localizedFallbackTitle = ""
            }
            var authError: NSError?
            
            guard localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
                observer(.failure(authError ?? NSError()))
                return disposable
            }
            
            let reasonString = "손가락을 홈 버튼에 올려주세요."
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, evaluateError in
                guard success else {
                    observer(.failure(evaluateError ?? NSError()))
                    return
                }
                observer(.success(()))
            }
            return disposable
        })
    }
}
