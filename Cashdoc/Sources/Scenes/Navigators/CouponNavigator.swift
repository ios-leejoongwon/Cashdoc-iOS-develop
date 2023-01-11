//
//  CouponNavigator.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class CouponNavigator {
    
    // MARK: - Properties
    
    private weak var parentViewController: UIViewController?
    
    // MARK: - Con(De)structor
    
    init(_ parentViewController: UIViewController?) {
        self.parentViewController = parentViewController
    }
    
    // MARK: - Internal methods
    
    func showCouponDetail(coupon: CouponModel) {
        let controller = CouponDetailViewController(viewModel: .init(), coupon: coupon)
        GlobalFunction.pushVC(controller, animated: true)
    }
    
    func showShopping() {
        let vc = ShopViewController()
        GlobalFunction.pushVC(vc, animated: true)
    }
}
