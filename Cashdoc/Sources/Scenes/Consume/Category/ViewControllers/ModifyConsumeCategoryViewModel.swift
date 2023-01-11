//
//  ModifyConsumeCategoryViewModel.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class ModifyConsumeCategoryViewModel {
    
    private let disposeBag = DisposeBag()
    private var navigator: ConsumeNavigator!
    
    init(navigator: ConsumeNavigator) {
        self.navigator = navigator
    }
}

extension ModifyConsumeCategoryViewModel: ViewModelType {
    struct Input {
        let selectTrigger: Driver<ModifyConsumeCategoryResult>
    }
    struct Output {
    }
    
    func transform(input: Input) -> Output {
        input.selectTrigger
            .drive(onNext: { [weak self] (result) in
                guard let self = self else { return }
                switch result.index {
                case 0:
                    AccountTransactionRealmProxy().updateCategoryTransactionDetailList(item: result.item, changeCategory: "지출", changeSubCategory: result.subCategory)
                    CardApprovalRealmProxy().updateCategoryApprovalDetailList(item: result.item, changeCategory: "지출", changeSubCategory: result.subCategory)
                    ManualConsumeRealmProxy().updateCategoryApprovalDetailList(item: result.item, changeCategory: "지출", changeSubCategory: result.subCategory)
                case 1:
                    AccountTransactionRealmProxy().updateCategoryTransactionDetailList(item: result.item, changeCategory: "수입", changeSubCategory: result.subCategory)
                    CardApprovalRealmProxy().updateCategoryApprovalDetailList(item: result.item, changeCategory: "수입", changeSubCategory: result.subCategory)
                    ManualConsumeRealmProxy().updateCategoryApprovalDetailList(item: result.item, changeCategory: "수입", changeSubCategory: result.subCategory)
                case 2:
                    AccountTransactionRealmProxy().updateCategoryTransactionDetailList(item: result.item, changeCategory: "기타", changeSubCategory: result.subCategory)
                    CardApprovalRealmProxy().updateCategoryApprovalDetailList(item: result.item, changeCategory: "기타", changeSubCategory: result.subCategory)
                    ManualConsumeRealmProxy().updateCategoryApprovalDetailList(item: result.item, changeCategory: "기타", changeSubCategory: result.subCategory)
                default:
                    break
                }
//                self.navigator.presentViewControllerForScraping().view.makeToastWithCenter("변경되었습니다.")
                self.navigator.linkAfterReloadAndPoptoVC()
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
