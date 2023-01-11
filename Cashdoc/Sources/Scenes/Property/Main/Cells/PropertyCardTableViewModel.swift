//
//  PropertyCardTableViewModel.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RealmSwift

final class PropertyCardTableViewModel {
    
    private var navigator: PropertyNavigator!
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
    }
}

extension PropertyCardTableViewModel: ViewModelType {
    struct Input {
        
    }
    struct Output {
        
    }
    func transform(input: Input) -> Output {
        
        return Output()
    }
    
    func pushToPropertyCardDetailViewController(cardList: CheckCardPaymentDetailsList) {
        let vc = PropertyCardDetailViewController(viewModel: .init(navigator: navigator),
                                                  cardList: cardList)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func parentViewControllerForScraping() -> UIViewController {
        return navigator.getParentViewController()
    }
    
    func checkIsDoingScrapingWhenDidTapEmptyCell() {
        guard !SmartAIBManager.checkIsDoingPropertyScraping() else {
            self.navigator.getParentViewController().view
                .makeToastWithCenter("자산 데이터를 가져오고 있습니다.\n잠시만 기다려 주세요.")
            return
        }
        if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
            self.navigator.pushToLinkPropertyOneByOneViewController(propertyType: .카드)
        } else {
            self.navigator.pushToLinkPropertyViewController(isAnimated: true)
        }
    }
    
    func getNavigator() -> PropertyNavigator {
        return navigator
    }
}
