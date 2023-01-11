//
//  ImportCertificateViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 07/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ImportCertificateViewModel {
    
    private let navigator: PropertyNavigator!
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

// MARK: - ViewModelType

extension ImportCertificateViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    // MARK: - Internal methods
    
    func pushToHowToImportCertViewController() {
        let vc = HowToImportCertificateViewController(viewModel: .init(navigator: navigator,
                                                                       useCase: .init()),
                                                      linkType: .한번에연결,
                                                      fCodeName: "")
        GlobalFunction.pushVC(vc, animated: true)
    }
    
}
