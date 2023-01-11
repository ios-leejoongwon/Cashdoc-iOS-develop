//
//  AdBannerViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 19/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class AdBannerViewModel {

    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private let useCase: AdBannerUseCase
    
    // MARK: - Con(De)structor
    
    init(useCase: AdBannerUseCase) {
        self.useCase = useCase
    }
    
    // MARK: - Internal methods
    
    func getShopBannerList(by position: String) -> Driver<[AdBannerModel]> {
        return self.useCase.getBannerList(position: position)
    }
     
    func getConsumeBannerList() -> Driver<[AdBannerModel]> {
        return self.useCase.getConsumeBannerList()
    }
    
    func getHealthBannerList(by position: String) -> Driver<[HealthBannerModel]> {
        return self.useCase.getHealthBannerList(position: position)
    }
}
