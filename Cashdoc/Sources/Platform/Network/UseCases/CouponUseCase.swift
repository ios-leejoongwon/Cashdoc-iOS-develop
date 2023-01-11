//
//  CouponUseCase.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 18/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

class CouponUseCase {
    
    private let provider = CashdocProvider<CouponService>()
    
    func getCouponList(_ page: Int) -> Driver<[CouponModel]> {
        return provider.request(DefaultApiResponse<[CouponModel]>.self, token: .getCouponList(page))
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
    
    func getUsedCouponList(_ page: Int) -> Driver<[CouponModel]> {
        return provider.request(DefaultApiResponse<[CouponModel]>.self, token: .getUsedCouponList(page))
            .asDriverOnErrorJustNever()
            .map {$0.result}
    }
}
