//
//  ShopBestViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 19/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ShopBestViewModel {
    
    private let navigator: ShopNavigator!
    private let disposeBag = DisposeBag()
    
    init(navigator: ShopNavigator) {
        self.navigator = navigator
    }
}

// MARK: - ViewModelType

extension ShopBestViewModel {
    // MARK: - Internal methods
    
    func pushShopDetailVC(item: ShopItemModel) {
        Log.i(item)
        navigator.pushShopDetailVC(item)
    }
}
