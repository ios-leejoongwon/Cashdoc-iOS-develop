//
//  PropertyNavigator.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RealmSwift

protocol PropertyNavigator {
    func pushToLinkPropertyViewController(isAnimated: Bool)
    func pushToLinkPropertyOneByOneViewController(propertyType: LinkPropertyChildType)
    func pushToLinkPropertyLoginViewController(linkType: HowToLinkType,
                                               propertyType: LinkPropertyChildType,
                                               bankInfo: BankInfo)
    func pushToManagePropertyViewController()
    func pushToInviteFriendViewController()
    func pushToCashViewController()
    
    // 공통 사용
    func navigationControllerForLoading() -> UINavigationController
    func getParentViewController() -> UIViewController
}

final class DefaultPropertyNavigator: PropertyNavigator {
    
    // MARK: - Properties
    
    private weak var parentViewController: UIViewController?
    
    // MARK: - Con(De)structor
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    // MARK: - Internal methods
    
    func pushToLinkPropertyViewController(isAnimated: Bool) {
        let vc = LinkPropertyViewController(viewModel: LinkPropertyViewModel(navigator: self))
        parentViewController?.navigationController?.pushViewController(vc, animated: isAnimated)
    }
    
    func pushToLinkPropertyOneByOneViewController(propertyType: LinkPropertyChildType) {
        let vc = LinkPropertyOneByOneViewController(propertyType: propertyType)
        vc.viewModel = LinkPropertyOneByOneViewModel(navigator: self)
        vc.bankViewController = LinkPropertyChildViewController(propertyType: .은행, viewModel: .init(navigator: self))
        vc.cardViewController = LinkPropertyChildViewController(propertyType: .카드, viewModel: .init(navigator: self))
        
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToLinkPropertyLoginViewController(linkType: HowToLinkType,
                                               propertyType: LinkPropertyChildType,
                                               bankInfo: BankInfo) {
        
        guard let topVC = parentViewController?.navigationController?.topViewController else { return }
        let vc = LinkPropertyLoginViewController(linkType: linkType,
                                                 bankInfo: bankInfo)
        
        vc.selectCertificateVC = SelectCertificateViewController(viewModel: .init(navigator: self),
                                                                 propertyType: propertyType,
                                                                 bankName: bankInfo.bankName)
        vc.loginForCertificateVC = LoginForCertificateViewController(viewModel: .init(navigator: self),
                                                                     propertyType: propertyType,
                                                                     bankName: bankInfo.bankName)
        
        if topVC is HowToImportCertificateViewController {
            GlobalDefine.shared.curNav?.popViewController(animated: false)
            GlobalDefine.shared.curNav?.popViewController(animated: false)
        }
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToManagePropertyViewController() {
        let vc = ManagePropertyViewController(type: .자산, date: nil)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToInviteFriendViewController() {
//        guard let navigation = parentViewController?.navigationController else { return }
//        let navigator = MoreNavigator(navigationController: navigation,
//                                      parentViewController: parentViewController ?? UIViewController())
        let vc = InviteFriendViewController()
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToCashViewController() {
        guard let navigation = parentViewController?.navigationController else { return }
        let navigator = MoreNavigator(navigationController: navigation,
                                      parentViewController: parentViewController ?? UIViewController())
        let vc = CurrentCashViewController()
        vc.viewModel = CurrentCashViewModel(navigator: navigator,
                                            useCase: .init())
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func navigationControllerForLoading() -> UINavigationController {
        guard let navi = parentViewController?.navigationController else {return .init()}
        return navi
    }
    
    func getParentViewController() -> UIViewController {
        return parentViewController ?? UIViewController()
    }
}
