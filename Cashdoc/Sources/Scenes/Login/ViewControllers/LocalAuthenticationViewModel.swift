//
//  LocalAuthenticationViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class LocalAuthenticationViewModel {
    
    private var unMatched = PublishRelay<Bool>()
    private let navigator: LoginNavigator
    private let disposeBag = DisposeBag()
    private let prefs = UserDefaults.standard
    
    init(navigator: LoginNavigator) {
        self.navigator = navigator
    }
    
}

// MARK: - ViewModelType

extension LocalAuthenticationViewModel: ViewModelType {
    
    struct Input {
        let okTrigger: Driver<Void>
        let backTrigger: Driver<Void>
        let confirmLocalAuthTrigger: Driver<(Bool, PasswordType)>
        let passwordButtonTrigger: Driver<Void>
    }
    struct Output {
        let unMatchedLocalAuth: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.okTrigger
            .drive(onNext: { [weak self] (_) in
                guard let self = self else {return}
                if UserManager.shared.isNew {
                    self.navigator.pushToRecommenderViewController()
                } else {
                    self.navigator.pushToTutorialViewController()
                }
            })
            .disposed(by: disposeBag)
        input.backTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.popViewController(nil)
            })
            .disposed(by: disposeBag)
        input.confirmLocalAuthTrigger
            .drive(onNext: { [weak self] (isConfirm, type) in
                guard let self = self else { return }
                switch type {
                case .loginForStart:
                    if isConfirm {
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLocalAuth.rawValue)
                        LoginManager.replaceRootViewController()
                    } else {
                        self.navigator.pushToPasswordViewController(type: .loginForStart)
                        self.unMatched.accept(true)
                    }
                case .modify:
                    #if DEBUG
                    Log.i("modify")
                    #endif
                case .withdraw:
                    if isConfirm {
                        LoginManager.withdraw()
                    } else {
                        self.navigator.pushToPasswordViewController(type: .withdraw)
                        self.unMatched.accept(true)
                    }
                case .settingUse:
                    if isConfirm {
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLocalAuth.rawValue)
                        self.navigator.popViewController("적용되었습니다.")
                    } else {
                        self.navigator.popViewController(nil)
                        self.unMatched.accept(true)
                    }
                case .regist, .registForSetting:
                    if isConfirm {
                        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLocalAuth.rawValue)
                        if UserManager.shared.isNew {
                            self.navigator.pushToRecommenderViewController()
                        } else {
                            self.navigator.pushToTutorialViewController()
                        }
                    } else {
                        if UserManager.shared.isNew {
                            self.navigator.pushToRecommenderViewController()
                        } else {
                            self.navigator.pushToTutorialViewController()
                        }
                        self.unMatched.accept(true)
                    }
                case .loginForInApp(let nextVC):
                    GlobalDefine.shared.curNav?.popViewController(animated: true)
                    if isConfirm {
                        GlobalFunction.pushVC(nextVC, animated: true)
                    }
                }
                
            })
        .disposed(by: disposeBag)
        input.passwordButtonTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToPasswordViewController(type: .loginForStart)
            })
            .disposed(by: disposeBag)
        return Output(unMatchedLocalAuth: self.unMatched.asDriverOnErrorJustNever())
    }
    
}
