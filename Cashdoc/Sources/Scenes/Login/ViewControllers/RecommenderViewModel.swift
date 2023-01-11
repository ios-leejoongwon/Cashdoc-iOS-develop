//
//  RecommenderViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class RecommenderViewModel {
    
    private let useCase: InviteUseCase
    private let navigator: LoginNavigator
    private let disposeBag = DisposeBag()
    
    init(navigator: LoginNavigator, useCase: InviteUseCase) {
        self.navigator = navigator
        self.useCase = useCase
    }
    
}

// MARK: - ViewModelType

extension RecommenderViewModel: ViewModelType {
    
    struct Input {
        let okTrigger: Driver<String>
        let skipTrigger: Driver<Void>
        let keyboardShowTrigger: Observable<Notification>
        let keyboardHideTrigger: Observable<Notification>
        let textTrigger: Driver<String>
        let nextTrigger: Driver<Void>
    }
    struct Output {
        let showKeyboard: Driver<CGFloat>
        let hideKeyboard: Driver<CGFloat>
        let isActiceButton: Driver<Bool>
        let fetching: Driver<RegistInvite>
        let putError: Driver<Int> 
    }
    
    func transform(input: Input) -> Output {
        let putError = PublishRelay<Int>()
        
        let registInvite: Driver<RegistInvite> = input.okTrigger
            .flatMapLatest { [weak self] code in
                guard let self = self else { return  Driver.empty() }
                return self.useCase.registInviteCode(code: code, putError: putError)
            }
        input.skipTrigger
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                GlobalFunction.FirLog(string: "회원가입_추천코드_건너뛰기_클릭_iOS")
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: { 
                    self.navigator.pushToTutorialViewController()
                })
            })
            .disposed(by: disposeBag)
        let showTrigger: Driver<CGFloat> = input.keyboardShowTrigger
            .flatMapLatest { [weak self] (noti) -> Driver<CGFloat> in
                guard let self = self else { return Driver.just(0)}
                return Driver.just(self.keyboardHeight(noti: noti))
            }.asDriverOnErrorJustNever()
        let hideTrigger: Driver<CGFloat> = input.keyboardHideTrigger
            .flatMapLatest { [weak self] (noti) -> Driver<CGFloat> in
                guard let self = self else { return Driver.just(0)}
                return Driver.just(self.keyboardHeight(noti: noti))
            }.asDriverOnErrorJustNever()
        let isActive: Driver<Bool> = input.textTrigger
            .flatMapLatest({ (string) in
                if string.count >= 5 {
                    return Driver.just(true)
                } else {
                    return Driver.just(false)
                }
            }).asDriver()
        input.nextTrigger
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                UserManager.shared.getUser()
                self.navigator.pushToTutorialViewController()
            })
            .disposed(by: disposeBag)
        
        return Output(showKeyboard: showTrigger,
                      hideKeyboard: hideTrigger,
                      isActiceButton: isActive,
                      fetching: registInvite,
                      putError: putError.asDriverOnErrorJustNever())
    }
    
    private func keyboardHeight(noti: Notification) -> CGFloat {
        guard let userInfo = noti.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return 0 }
        return keyboardFrame.cgRectValue.height
    }
    
}
