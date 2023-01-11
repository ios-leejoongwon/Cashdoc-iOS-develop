//
//  PropertyLoanTableViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class PropertyLoanTableViewModel {
    
    private var navigator: PropertyNavigator!
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

extension PropertyLoanTableViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        
    }
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    func pushToPropertyLoanDetailViewController(aModel: CheckAllAccountInBankList? = nil,
                                                cModel: CheckCardLoanDetailsList? = nil) {
        let vc = PropertyLoanDetailViewController()
        if aModel != nil {
            vc.aModel = aModel
        } else {
            vc.cModel = cModel
        }
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToPropertyLoadAddViewController(aModel: CheckAllAccountInBankList) {
        let vc = LoanAddViewController()
        vc.getModel = aModel
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func getNavigator() -> PropertyNavigator {
        return navigator
    }
    
    func checkIsDoingScrapingWhenDidTapEmptyCell() {
        guard !SmartAIBManager.checkIsDoingPropertyScraping() else {
            self.navigator.getParentViewController().view
                .makeToastWithCenter("자산 데이터를 가져오고 있습니다.\n잠시만 기다려 주세요.")
            return
        }
        if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
            self.navigator.pushToLinkPropertyOneByOneViewController(propertyType: .은행)
        } else {
            self.navigator.pushToLinkPropertyViewController(isAnimated: true)
        }
    }
}
