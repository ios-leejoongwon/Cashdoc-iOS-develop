//
//  CouponViewModel.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class CouponViewModel {
    
    struct Input {
        let coupon: Observable<CouponModel>
        let shopEvent: Observable<Void>
    }
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private var navigator: CouponNavigator?
    
    // MARK: - Con(De)structor
    
    init(_ parentView: UIViewController) {
        self.navigator = CouponNavigator(parentView)
    }
    
    // MARK: - Internal methods
    
    func bind(input: Input) {
        input.shopEvent
            .bind { [weak self] (_) in
                guard let self = self else {return}
                self.navigator?.showShopping()
            }
            .disposed(by: disposeBag)
        input.coupon
            .bind { [weak self] (coupon) in
                guard let self = self else {return}
                self.navigator?.showCouponDetail(coupon: coupon)
            }
            .disposed(by: disposeBag)
    }
}
