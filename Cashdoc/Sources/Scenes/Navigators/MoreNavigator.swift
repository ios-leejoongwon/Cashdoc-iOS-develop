//
//  MoreNavigator.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import LocalAuthentication

final class MoreNavigator {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let navigationController: UINavigationController
    private let parentViewController: UIViewController
    
    // MARK: - Con(De)structor
    
    init(navigationController: UINavigationController, parentViewController: UIViewController) {
        self.navigationController = navigationController
        self.parentViewController = parentViewController
    }
    
    // MARK: - Internal methods
    
    func pushToProfileViewController() {
        let vc = ProfileViewController()
        vc.viewModel = ProfileViewModel(navigator: self)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToCouponViewController() {
        let vc = CouponListViewController()
        vc.viewModel = CouponViewModel.init(parentViewController)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToCashViewController() {
        let vc = CurrentCashViewController()
        vc.viewModel = CurrentCashViewModel(navigator: self, useCase: .init())
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToInviteFriendViewController() {
        let vc = InviteFriendViewController()
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToMyPropertyViewController() {
        // let navigator = DefaultPropertyNavigator(parentViewController: parentViewController)
        let vc = ManagePropertyViewController(type: .자산, date: nil)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToLockAppViewController() {
        let vc = LockAppViewController(viewModel: LockAppViewModel(navigator: self))
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToAlarmSettingViewController() {
        let vc = AlarmSettingViewController()
        vc.viewModel = AlarmSettingViewModel(navigator: self)
        GlobalFunction.pushVC(vc, animated: true)
    }
    func pushToInquireViewController() {
        let vc = InquireViewController(viewModel: InquireViewModel(navigator: self))
        GlobalFunction.pushVC(vc, animated: true)
    }
    func pushToWithdrawViewController() {
        let vc = WithdrawViewController()
        vc.viewModel = WithdrawViewModel(navigator: self, useCase: .init())
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToDebugModeViewController() {
        let vc = DebugModeViewController(viewModel: .init(navigator: self))
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToSmsAuthViewController() {
        let vc = SmsAuthViewController()
        vc.viewModel = AuthViewModel(useCase: .init())
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToEditProfileViewController() {
        let vc = EditProfileViewController()
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func addAccountPopupView(type: AccountPopupType) {
        guard let window = UIApplication.shared.keyWindow else { return }
        
        let popupView = AccountPopupView(frame: UIScreen.main.bounds, type: type)
        window.addSubview(popupView)

        let prefs = UserDefaults.standard
        let authContext = LAContext()
        var authError: NSError?
        
        popupView.okButtonClickEvent
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                if type == .logout {
                    LoginManager.logout()
                } else {
                    if prefs.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) {
                        // 비밀번호 화면으로 로컬인증 체크
                        if prefs.bool(forKey: UserDefaultKey.kIsLocalAuth.rawValue) {
                            if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                                let localAuthType = authContext.bioType()
                                let localAuthVC = LocalAuthenticationViewController(bioType: localAuthType, passwordType: .withdraw)
                                self.parentViewController.navigationController?.pushViewController(localAuthVC, animated: true)
                            } else {
                                let passwordVC = PasswordViewController(type: .withdraw)
                                self.parentViewController.navigationController?.pushViewController(passwordVC, animated: true)
                            }
                        } else {
                            let passwordVC = PasswordViewController(type: .withdraw)
                            self.parentViewController.navigationController?.pushViewController(passwordVC, animated: true)
                        }
                    } else {
                        LoginManager.withdraw()
                    }
                }
        })
        .disposed(by: disposeBag)
    }
    
    func pushToPasswordViewController() {
        let vc = PasswordViewController(type: .modify)
        GlobalFunction.pushVC(vc, animated: true)
    }
    
    func pushToLocalAuthViewController() {
        let type = LAContext().bioType()
        let vc = LocalAuthenticationViewController(bioType: type, passwordType: .settingUse)
        GlobalFunction.pushVC(vc, animated: true)
    }

    func getParentViewController() -> UIViewController {
        return parentViewController
    }
    
    func makeToast(_ toastString: String) {
        parentViewController.navigationController?.view.makeToastWithCenter(toastString)
    }
}
