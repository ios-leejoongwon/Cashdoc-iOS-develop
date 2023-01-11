//
//  ShopCategoryViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class ShopCategoryViewModel {
    
    private var useCase: ShopUseCase!
    private let navigator: ShopNavigator!
    private let disposeBag = DisposeBag()
    
    init(navigator: ShopNavigator) {
//        self.useCase = useCase
        self.navigator = navigator
    }
}

extension ShopCategoryViewModel: ViewModelType {
    struct Input {
//        let pushShopGoodsListVC: Driver<[ShopCategoryModel]>
    }
    struct Output {
    }
    func transform(input: Input) -> Output {
//        input.pushShopGoodsListVC
//            .drive(onNext: { [weak self] _ in
//                guard let weakSelf = self else { return }
//                weakSelf.navigator.pushShopGoodsListVC()
//            })
//            .disposed(by: disposeBag)
        
        return Output()
    }
    
    // MARK: - Internal methods
    
    private func sectionItem(results: [ShopCategoryModel]) -> ShopSection {
        var items = [ShopSectionItem]()
        results.forEach { (result) in
            items.append(.category(item: result))
        }
        return .section(items: items)
    }
    
    func pushShopGoodsListVC(category: ShopCategoryModel) {
        Log.i(category)
        if category.id == 7 {
            GlobalFunction.pushToWebViewController(title: category.title ?? "", url: API.CASH_SHOP_URL)
        } else if category.id == 8 {
            GlobalFunction.pushToWebViewController(title: category.title ?? "", url: API.CASH_EXCHANGE_URL)
        } else {
            navigator.pushShopGoodsListVC(category)
        }
    }
}
