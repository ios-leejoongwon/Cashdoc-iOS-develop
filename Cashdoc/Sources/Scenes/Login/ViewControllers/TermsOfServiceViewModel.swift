//
//  TermsOfServiceViewModel.swift
//  Cashdoc
//
//  Created by DongHeeKang on 25/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class TermsOfServiceViewModel {    
    var currentTerm: TermType = .cashDoc
    
    private let navigator: LoginNavigator
    private let disposeBag = DisposeBag()
    private var accountInfo: LoginInput?
    
    init(navigator: LoginNavigator, _ accountInfo: LoginInput? = nil) {
        self.navigator = navigator
        self.accountInfo = accountInfo
    }
}

// MARK: - ViewModelType

extension TermsOfServiceViewModel: ViewModelType {
    struct Input {
        let okTrigger: Driver<Void>
        let menuTapTrigger: Driver<Int>
    }
    struct Output {
        let okClicked: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
         
        input.menuTapTrigger
            .drive(onNext: { [weak self] index in
                guard let self = self else { return }
                var urlString = ""
                var title = ""
                
                switch index {
                case 1:
                    switch self.currentTerm {
                    case .insurance:
                        urlString = API.INSURANCE_TERMS_URL
                    case .cashDoc:
                        urlString = API.CASHDOC_TERMS_URL
                    }
                    title = "이용약관 동의"
                case 2:
                    switch self.currentTerm {
                    case .insurance:
                        urlString = API.INSURANCE_PRIVACY_URL
                        title = "개인정보 수집 및 이용 동의"
                    case .cashDoc:
                        urlString = API.MORE_TERMS_ESSENTIAL_URL
                        title = "개인정보 수집 및 이용(필수)"
                    }
                case 3:
                    if self.currentTerm == .cashDoc {
                        urlString = API.MORE_TERMS_SELECT_URL
                        title = "개인정보 수집 및 이용 동의(선택)"
                    }
                default:
                    break
                } 
                GlobalFunction.pushToWebViewController(title: title, url: urlString, webType: .terms)
            })
            .disposed(by: disposeBag)
        
        return Output(okClicked: input.okTrigger)
    }
}
