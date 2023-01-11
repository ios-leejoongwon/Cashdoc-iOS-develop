//
//  AdBannerUseCase.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 19/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

class AdBannerUseCase {
    
    private let provider = CashdocProvider<AdBannerService>()
    
    func getBannerList(position: String) -> Driver<[AdBannerModel]> {
        return provider.request(DefaultApiResponse<[AdBannerModel]>.self, token: .getShopBanner(position: position))
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func getConsumeBannerList() -> Driver<[AdBannerModel]> {
        return provider.request(DefaultApiResponse<[AdBannerModel]>.self, token: .getConsumeBanner)
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func postBanner(type: String, id: String) -> Driver<[AdBannerModel]> {
        return provider.request(DefaultApiResponse<[AdBannerModel]>.self, token: .postBanner(type: type, id: id))
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func getHealthBannerList(position: String) -> Driver<[HealthBannerModel]> {
        return provider.request(DefaultApiResponse<[HealthBannerModel]>.self, token: .getShopBanner(position: position))
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
}
