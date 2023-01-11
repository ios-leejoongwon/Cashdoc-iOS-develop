//
//  DetailConsumeViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 20/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class DetailConsumeViewModel {
    
    private let disposeBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension DetailConsumeViewModel: ViewModelType {
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
    }
    func transform(input: Input) -> Output {
        
        return Output()
    }

    func removeItem(_ item: ConsumeContentsItem) {
        self.removeItemFromRealm(item)
        self.navigator.popVC(item)
    }
    
    func pushToAddConsumeVC(item: ConsumeContentsItem) {
        self.navigator.pushToAddConsumeViewController(item)
    }
    
    private func removeItemFromRealm(_ item: ConsumeContentsItem) {
        if item.approvalNum == "0" {
            AccountTransactionRealmProxy().removeTransactionDetailList(item: item)
            ManualConsumeRealmProxy().removeManualConsumeList(item: item)
        } else {
            CardApprovalRealmProxy().removeCardDetailList(item: item)
        }
    }
}
