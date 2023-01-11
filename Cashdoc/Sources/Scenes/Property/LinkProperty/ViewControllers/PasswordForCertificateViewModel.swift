//
//  PasswordForCertificateViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 12/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class PasswordForCertificateViewModel {
    
    private let navigator: PropertyNavigator!
    private let disposeBag = DisposeBag()
    
    // Input
    let pwdText = BehaviorSubject(value: "")
    
    // Output
    let isPwdValid = BehaviorSubject(value: false)
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
        
        _ = pwdText.distinctUntilChanged()
        .map(checkPassworddValid(_:))
        .bind(to: isPwdValid)
    }
}

// MARK: - ViewModelType

extension PasswordForCertificateViewModel: ViewModelType {
    struct Input {
        let keyboardShowTrigger: Observable<Notification>
        let keyboardHideTrigger: Observable<Notification>
        let clickedCompleteButton: Observable<(String?, InputPasswordForCert?)>
    }
    struct Output {
        let showKeyboard: Driver<CGFloat>
        let hideKeyboard: Driver<CGFloat>
        let checkInvalidPassword: Driver<ErrorResult>
    }
    func transform(input: Input) -> Output {
        let checkInValidPassword = PublishRelay<ErrorResult>()
        
        let showTrigger: Driver<CGFloat> = input.keyboardShowTrigger
            .flatMapLatest { [weak self] (noti) -> Driver<CGFloat> in
                guard let self = self else { return Driver.just(0) }
                return Driver.just(self.keyboardHeight(noti: noti))
        }.asDriverOnErrorJustNever()
        
        let hideTrigger: Driver<CGFloat> = input.keyboardHideTrigger
            .flatMapLatest { [weak self] (noti) -> Driver<CGFloat> in
                guard let self = self else { return Driver.just(0) }
                return Driver.just(self.keyboardHeight(noti: noti))
        }.asDriverOnErrorJustNever()
        
        input.clickedCompleteButton
            .subscribe(onNext: { [weak self] (password, input) in
                guard let self = self else { return }
                guard let password = password, !password.isEmpty else { return }
                guard let cPassword = AES256CBC.encryptCashdoc(password) else { return }
                guard let input = input else { return }
                let cert = SmartAIBManager.findCertInfo(certPath: input.certDirectory)
                            
                if let getCloser = GlobalDefine.shared.exitClosure {
                    let makeParam: [String: String] = ["CERTDIRECTORY": cert.certDirectory, "CERTPWD": cPassword]
                    GlobalDefine.shared.saveCertParam.append(anotherDict: makeParam)
                    getCloser()
                    return
                }
                
                guard SmartAIBManager.checkValidCertPassword(certPath: cert.certDirectory,
                                                             password: password).errorMsg.isEmpty else {
                    let errorResult = SmartAIBManager.checkValidCertPassword(certPath: cert.certDirectory, password: password)
                    checkInValidPassword.accept(errorResult)
                    return
                }
                
                if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
                    
                } else {
                    DBManager.clear(isAll: false)
                }
                
                var inputDatas = [ScrapingInput]()

                switch input.propertyType {
                case .은행:
                    guard let fCode = FCode(rawValue: input.bankName) else { return }
                    inputDatas.append(ScrapingInput.은행_전계좌조회(fCode: fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: cPassword)))
                    SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas,
                                                           vc: self.navigator.getParentViewController(),
                                                           scrapingType: .하나씩연결)
                case .카드:
                    guard let fCode = FCode(rawValue: input.bankName) else { return }
                    inputDatas.append(ScrapingInput.카드_결제예정조회(fCode: fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: cPassword)))
//                    inputDatas.append(ScrapingInput.카드_대출내역조회(fCode: fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: password)))
//                    inputDatas.append(ScrapingInput.카드_전카드조회(fCode: fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: password)))
                    SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas,
                                                           vc: self.navigator.getParentViewController(),
                                                           scrapingType: .하나씩연결)
                case .ALL:
                    FCode.allCases.forEach({ (_fCode) in
                        inputDatas.append(ScrapingInput.은행_전계좌조회(fCode: _fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: cPassword)))
                        inputDatas.append(ScrapingInput.카드_결제예정조회(fCode: _fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: cPassword)))
//                        inputDatas.append(ScrapingInput.카드_대출내역조회(fCode: _fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: password)))
//                        inputDatas.append(ScrapingInput.카드_전카드조회(fCode: _fCode, loginMethod: .인증서(certDirectory: cert.certDirectory, pwd: password)))
                    })
                    SmartAIBManager.getMultiScrapingResult(inputDatas: inputDatas,
                                                           vc: self.navigator.getParentViewController(),
                                                           scrapingType: .한번에연결)
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
        
        return Output(showKeyboard: showTrigger,
                      hideKeyboard: hideTrigger,
                      checkInvalidPassword: checkInValidPassword.asDriverOnErrorJustNever())
    }
    
    func getAlertController(vc: UIViewController, errorResult: ErrorResult) -> Observable<Bool> {
        var actions = [RxAlertAction<Bool>]()
        actions.append(RxAlertAction<Bool>.init(title: "확인", style: .default, result: true))
        
        return UIAlertController.rx_presentAlert(viewController: vc,
                                                 title: errorResult.errorMsg,
                                                 message: errorResult.errorCode,
                                                 preferredStyle: .alert,
                                                 animated: true,
                                                 actions: actions)
    }
    
    // MARK: - Private methods
    
    private func checkPassworddValid(_ pwd: String) -> Bool {
        return pwd.count > 0
    }
    
    private func keyboardHeight(noti: Notification) -> CGFloat {
        guard let userInfo = noti.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return 0 }
        return keyboardFrame.cgRectValue.height
    }
    
}
