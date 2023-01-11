//
//  ShopBuyCompleteViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

final class ShopBuyCompleteViewModel {
    
    // MARK: - Properties
    
    let model: ShopBuyItemModel
    
    // MARK: - Con(De)structor
    
    init(model: ShopBuyItemModel) {
        self.model = model
    }
    
}

extension ShopBuyCompleteViewModel: ViewModelType {
    
    struct Input {
        let trigger: Driver<Void>
    }
    struct Output {
        let affiliate: Driver<String>
        let title: Driver<String>
        let imageUrl: Driver<URL>
    }
    
    // MARK: - Internal methods
    
    func transform(input: Input) -> Output {
        let affiliate: Driver<String> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self, let affiliate = self.model.affiliate else {return Driver.just("")}
                return Driver.just(affiliate)
        }
        let title: Driver<String> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self, let title = self.model.title else {return Driver.just("")}
                return Driver.just(title)
        }
        let imageUrl: Driver<URL> = input.trigger
            .flatMapLatest { [weak self] (_) in
                guard let self = self, let imageUrl = self.model.imageUrl, let url = URL(string: imageUrl) else {return Driver.empty()}
                return Driver.just(url)
        }
        
        return Output(affiliate: affiliate, title: title, imageUrl: imageUrl)
    }
    
}
