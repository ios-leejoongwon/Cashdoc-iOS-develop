//
//  PasswordViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift
import LocalAuthentication

final class PasswordViewModel {
    
    private let navigator: LoginNavigator
    private var disposeBag = DisposeBag()
    private let authContext = LAContext()
    private var type: PasswordType
    private let prefs = UserDefaults.standard
    var prevRegistedpassword = ""
    
    init(navigator: LoginNavigator) {
        self.navigator = navigator
        self.type = .regist
        self.prevRegistedpassword = ""
    }
    
}

// MARK: - ViewModelType

extension PasswordViewModel: ViewModelType {
    
    struct Input {
        let registPassWordTrigger: Driver<String>
        let subButtonTrigger: Driver<Void>
        let backButtonTrigger: Driver<Void>
        let matchedTrigger: Driver<Bool>
        let unMatchedTrigger: Driver<Bool>
        let typeTrigger: Driver<PasswordType>
    }
    struct Output {
        let subButtonClicked: Driver<Void>
        let setPasswordForModify: Driver<Void>
        let registPassWord: Driver<String>
        let unMatchedPassWord: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let setPasswordForModify = PublishRelay<Void>()
        
        let registPW: Driver<String> = input.registPassWordTrigger
            .flatMapLatest { password -> Driver<String> in
                self.prevRegistedpassword = password
                return Driver.just(password)
            }
        input.backButtonTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                switch self.type {
                case .withdraw:
                    self.navigator.popPopViewController()
                case .modify, .loginForInApp:
                    self.navigator.popViewController(nil)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        input.matchedTrigger
            .drive(onNext: { [weak self] isMatched in
                guard let self = self else { return }
                if isMatched {
                    switch self.type {
                    case .modify:
                        if self.prevRegistedpassword == "" {
                            // 재설정 시 비밀번호 맞는지
                            setPasswordForModify.accept(())
                        } else {
                            // 비밀번호 맞으면
                            self.prefs.set(0, forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                            self.presentVC()
                        }
                    default:
                        self.prefs.set(0, forKey: UserDefaultKey.kInvalidPasswordCount.rawValue)
                        self.presentVC()
                    }
                }
        })
        .disposed(by: disposeBag)
        let unMatchedPW: Driver<Bool> = input.unMatchedTrigger
            .flatMapLatest { isUnMatched -> Driver<Bool> in
                return Driver.just(isUnMatched)
        }
        input.typeTrigger
            .drive(onNext: { [weak self] type in
                guard let self = self else { return }
                self.type = type
            })
        .disposed(by: disposeBag)
        
        return Output(subButtonClicked: input.subButtonTrigger, setPasswordForModify: setPasswordForModify.asDriverOnErrorJustNever(), registPassWord: registPW, unMatchedPassWord: unMatchedPW)
    }
    
    // MARK: - Private Method
    private func presentVC() {
        switch self.type {
        case .loginForStart:
            LoginManager.replaceRootViewController()
        case .loginForInApp(let nextVC):
            GlobalDefine.shared.curNav?.popViewController(animated: false)
            GlobalFunction.pushVC(nextVC, animated: true)
        case .modify:
            self.navigator.popViewController(nil)
        case .withdraw:
            LoginManager.withdraw()
        case .registForSetting:
            UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLockApp.rawValue)
            GlobalDefine.shared.curNav?.popViewController(animated: true)
        default:
            let authContext = LAContext()
            let type = authContext.bioType()
            
            switch type {
            case .touchID:
                self.navigator.addLocalAuthPopupView(type: .touchID)
            case .faceID:
                self.navigator.addLocalAuthPopupView(type: .faceID)
            default:
                if UserManager.shared.isNew {
                    self.navigator.pushToRecommenderViewController()
                } else {
                    self.navigator.pushToTutorialViewController()
                }
            }
        }
    }
}
