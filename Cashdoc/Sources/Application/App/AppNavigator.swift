//
//  AppNavigator.swift
//  Cashdoc
//
//  Created by DongHeeKang on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import LocalAuthentication

class AppNavigator {
    func start(in delegate: AppDelegate) {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let prefs = UserDefaults.standard
        
        if #available(iOS 13, *) {
            window.overrideUserInterfaceStyle = .light
        }
        
        if AccessTokenManager.accessToken == "" || prefs.bool(forKey: UserDefaultKey.kIsTermsOfService.rawValue) == false {
            let navigationVC = CashdocNavigationController(rootViewController: LoginViewController())
            GlobalDefine.shared.curNav = navigationVC
            window.rootViewController = navigationVC
        } else {
            let authContext = LAContext()
            var navigationVC = UINavigationController()
            let prefs = UserDefaults.standard
            
            if prefs.bool(forKey: UserDefaultKey.kIsLockApp.rawValue) {
                if prefs.bool(forKey: UserDefaultKey.kIsLocalAuth.rawValue) {
                    let localAuthType = authContext.bioType()
                    navigationVC = CashdocNavigationController(rootViewController: LocalAuthenticationViewController(bioType: localAuthType, passwordType: .loginForStart))
                } else {
                    if let isPassword = prefs.string(forKey: UserDefaultKey.kPassword.rawValue), !isPassword.isEmpty {
                        navigationVC = CashdocNavigationController(rootViewController: PasswordViewController(type: .loginForStart))
                    } else {
                        navigationVC = CashdocNavigationController(rootViewController: PasswordViewController(type: .regist))
                    }
                }
            } else {
                if let mainNav = UIStoryboard.init(name: "Main", bundle: nil).instantiateInitialViewController() as? UINavigationController {
                    navigationVC = mainNav
                }
            }
            
            GlobalDefine.shared.curNav = navigationVC
            window.rootViewController = navigationVC
            
            UserManager.shared.getUser { (error) in
                if error != nil, error?.code != 103 {
                    let popupView = GetUserFailPopupView(frame: UIScreen.main.bounds)
                    window.addSubview(popupView)
                }
            }
        }
        delegate.window = window
        window.makeKeyAndVisible()
        // 탈옥체크 window.makeKeyAndVisible()다음에 호출할것
        JailBreakChecker.checkJail()
    }

    // MARK: - Private methods
    private func compare(_ target: String) -> Bool {
        let appVerison = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        return target.compare(appVerison, options: .numeric) == .orderedDescending
    }
}
