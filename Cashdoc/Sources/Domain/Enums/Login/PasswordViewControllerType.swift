//
//  PasswordViewControllerType.swift
//  Cashdoc
//
//  Created by Taejune Jung on 29/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

enum PasswordType {
    case regist
    case registForSetting
    case loginForStart
    case modify
    case withdraw
    case settingUse
    case loginForInApp(nextVC: UIViewController)
}
