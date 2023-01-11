//
//  ShopGoodsListViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ShopGoodsListViewModel {
    
    private let navigator: ShopNavigator!
    private let disposeBag = DisposeBag()
    
    init(navigator: ShopNavigator) {
        self.navigator = navigator
    }
}

// MARK: - ViewModelType

extension ShopGoodsListViewModel: ViewModelType {
    struct Input {
        let showDetailItem: Driver<Void>
    }
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        return Output()
    }
    
    // MARK: - Internal methods

    func pushShopDetailVC(item: ShopItemModel) {
        Log.i(item)
        navigator.pushShopDetailVC(item)
    }
}
