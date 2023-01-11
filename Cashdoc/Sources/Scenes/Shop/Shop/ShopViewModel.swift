//
//  ShopViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 29/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

struct ShopResultViewModel {
    let categoryListVM: [ShopResultCategoryViewModel]
}

extension ShopResultViewModel {
    init(categoryList: [ShopCategoryModel]) {
        self.categoryListVM = categoryList.compactMap(ShopResultCategoryViewModel.init)
    }
}

struct ShopResultCategoryViewModel {
    let category: ShopCategoryModel
    
    init(_ category: ShopCategoryModel) {
        self.category = category
    }
}

extension ShopResultCategoryViewModel {
    var title: Observable<String> {
        return Observable<String>.just(category.title ?? "")
    }
    
    var imageUrl: Observable<String> {
        return Observable<String>.just(category.imageUrl ?? "")
    }
}
