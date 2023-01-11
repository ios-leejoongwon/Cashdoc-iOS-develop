//
//  LoginNavigator.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import LocalAuthentication

final class LoginNavigator {
    
    // MARK: - Properties
    
    private var disposeBag = DisposeBag()
    private weak var parentViewController: UIViewController?
    
    // MARK: - Con(De)structor
    
    init(parentViewController: UIViewController) {
        self.parentViewController = parentViewController
    }
    
    // MARK: - Internal methods
    
    func presentViewControllerForScraping() -> UIViewController {
        return parentViewController ?? UIViewController()
    }
    
    // MARK: - Internal methods
    
    func pushToTermOfService(loginInput: LoginInput) {
        let controller = TermsOfServiceViewController(loginInput: loginInput)
        GlobalFunction.pushVC(controller, animated: true)
    }
    
    func pushToAppPermission() {
        let controller = AppPermissionViewController()
        GlobalFunction.pushVC(controller, animated: true)
    }
    
    func pushToPasswordViewController(type: PasswordType) {
        let controller = PasswordViewController(type: type)
        GlobalFunction.pushVC(controller, animated: true)
    }
    
    func pushToLocalAuthenticationViewController(bioType: LABiometryType, passwordType: PasswordType) {
        let controller = LocalAuthenticationViewController(bioType: bioType, passwordType: passwordType)
        GlobalFunction.pushVC(controller, animated: true)
    }
    
    func pushToRecommenderViewController() {
        if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsShowRecommend.rawValue) {
            let controller = RecommenderViewController()
            GlobalFunction.pushVC(controller, animated: true)
        } else {
            pushToTutorialViewController()
        }
    }
    
    func pushToTutorialViewController() {
        LoginManager.replaceRootViewController()
    }
    
//    func pushToTermsWebViewController(index: Int, type: TermType) {
//        let controller = TermsWebViewController()
//        controller.index = index
//        //controller.type = type
//        GlobalFunction.pushVC(controller, animated: true)
//        
//        let vc = CashdocWebViewController(tempIndex: index, type: .credit)
//        GlobalFunction.pushVC(vc, animated: true)
//    }
    
    func addLocalAuthPopupView(title: String) {
        let popupView = InviteErrorPopupView(frame: .zero, title: title)
        parentViewController?.view.addSubview(popupView)
    }
    
    func popViewController(_ toastString: String?) {
        parentViewController?.navigationController?.view.makeToastWithCenter(toastString)
        parentViewController?.navigationController?.popViewController(animated: true)
    }
    
    func popPopViewController() {
        guard let index = parentViewController?.navigationController?.viewControllers.count, let moveVC = parentViewController?.navigationController?.viewControllers[index - 3] else { return }
        parentViewController?.navigationController?.popToViewController(moveVC, animated: true)
    }
    
    func addLocalAuthPopupView(type: LABiometryType) {
        let popupView = LocalAuthPopupView(frame: parentViewController?.view.bounds ?? CGRect.zero, type: type)
        parentViewController?.view.addSubview(popupView)
        
        popupView.okButtonClickEvent
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.pushToLocalAuthenticationViewController(bioType: type, passwordType: .regist)
                
            })
        .disposed(by: disposeBag)
        
        popupView.cancelButtonClickEvent
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                UserDefaults.standard.set(false, forKey: UserDefaultKey.kIsLocalAuth.rawValue)
                if UserManager.shared.isNew {
                    self.pushToRecommenderViewController()
                } else {
                    self.pushToTutorialViewController()
                }
            })
        .disposed(by: disposeBag)
    }
    
    func dismiss() {
        parentViewController?.dismiss(animated: true, completion: nil)
    }
}
