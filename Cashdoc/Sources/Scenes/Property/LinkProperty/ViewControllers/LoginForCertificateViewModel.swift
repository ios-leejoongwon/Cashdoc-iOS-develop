//
//  LoginForCertificateViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 22/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxOptional

final class LoginForCertificateViewModel {
    
    private var navigator: PropertyNavigator!
    private let disposeBag = DisposeBag()
    
    // Input
    let idText = BehaviorSubject(value: "")
    let pwdText = BehaviorSubject(value: "")
    
    // Output
    let isIdValid = BehaviorSubject(value: false)
    let isPwdValid = BehaviorSubject(value: false)
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
        
        _ = idText.distinctUntilChanged()
        .map(checkIdValid(_:))
        .bind(to: isIdValid)
        
        _ = pwdText.distinctUntilChanged()
        .map(checkPassworddValid(_:))
        .bind(to: isPwdValid)
    }
}

extension LoginForCertificateViewModel: ViewModelType {
    struct Input {
        let keyboardShowTrigger: Observable<Notification>
        let keyboardHideTrigger: Observable<Notification>
        let clickedLoginButton: Observable<LoginForCertInputModel>
    }
    struct Output {
        let showKeyboard: Driver<CGFloat>
        let hideKeyboard: Driver<CGFloat>
        let fetching: Driver<Void>
    }
    func transform(input: Input) -> Output {
        let fetching = PublishRelay<Void>()
        
        let showTrigger: Driver<CGFloat> = input.keyboardShowTrigger
            .flatMapLatest { [weak self] (noti) -> Driver<CGFloat> in
                guard let self = self else {return Driver.just(0)}
                return Driver.just(self.keyboardHeight(noti: noti))
        }.asDriverOnErrorJustNever()
        
        let hideTrigger: Driver<CGFloat> = input.keyboardHideTrigger
            .flatMapLatest { [weak self] (noti) -> Driver<CGFloat> in
                guard let self = self else {return Driver.just(0)}
                return Driver.just(self.keyboardHeight(noti: noti))
        }.asDriverOnErrorJustNever()
        
        input.clickedLoginButton
            .subscribe(onNext: { [weak self] (model) in
                guard let self = self,
                    !model.id.isEmpty,
                    !model.pwd.isEmpty,
                    let fCode = FCode(rawValue: model.bankName) else { return }
                
                if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
                    
                } else {
                    DBManager.clear(isAll: false)
                }
                
                var inputDatas = [ScrapingInput]()
                let login: ScrapingInput.LoginMethod = .아이디(id: model.id, pwd: model.pwd)
                
                switch model.propertyType {
                case .은행:
                    inputDatas.append(ScrapingInput.은행_전계좌조회(fCode: fCode, loginMethod: login))
                case .카드:
                    inputDatas.append(ScrapingInput.카드_결제예정조회(fCode: fCode, loginMethod: login))
//                    inputDatas.append(ScrapingInput.카드_대출내역조회(fCode: fCode, loginMethod: login))
//                    inputDatas.append(ScrapingInput.카드_전카드조회(fCode: fCode, loginMethod: login))
                default:
                    return
                }
                
                fetching.accept(())
                SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas,
                                                       vc: self.navigator.getParentViewController(),
                                                       scrapingType: .하나씩연결)
            })
            .disposed(by: disposeBag)
        
        return Output(showKeyboard: showTrigger,
                      hideKeyboard: hideTrigger,
                      fetching: fetching.asDriverOnErrorJustNever())
    }
    
    // MARK: - Internal methods
    
    func navigationControllerForLoading() -> UINavigationController {
        return navigator.navigationControllerForLoading()
    }
    
    // MARK: - Private methods
    
    private func checkIdValid(_ id: String) -> Bool {
        return id.count > 0
    }
    
    private func checkPassworddValid(_ pwd: String) -> Bool {
        return pwd.count > 0
    }
    
    private func keyboardHeight(noti: Notification) -> CGFloat {
        guard let userInfo = noti.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return 0 }
        return keyboardFrame.cgRectValue.height
    }
    
}
