//
//  LinkPropertyViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class LinkPropertyViewModel {
    
    private let navigator: PropertyNavigator!
    private let disposeBag = DisposeBag()
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

// MARK: - ViewModelType

extension LinkPropertyViewModel: ViewModelType {
    struct Input {
        let atOnceSelection: Driver<Void>
        let oneByOneSelection: Driver<Void>
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        input.atOnceSelection
            .drive(onNext: { [weak self] (_) in
                guard let self = self else { return }
                if SmartAIBManager.findCertInfoList().count > 0 {
                    self.navigator.pushToLinkPropertyLoginViewController(linkType: .한번에연결,
                                                                         propertyType: .ALL,
                                                                         bankInfo: BankInfo(bankName: "",
                                                                                            isLinked: false,
                                                                                            isCanLogin: false))
                } else {
                    self.pushToImportCertViewController()
                }
            })
            .disposed(by: disposeBag)
        
        input.oneByOneSelection
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.navigator.pushToLinkPropertyOneByOneViewController(propertyType: .은행)
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
    
    // MARK: - Internal methods
    private func pushToImportCertViewController() {
        let vc = ImportCertificateViewController(viewModel: .init(navigator: navigator))
        GlobalFunction.pushVC(vc, animated: true)
    }
}
