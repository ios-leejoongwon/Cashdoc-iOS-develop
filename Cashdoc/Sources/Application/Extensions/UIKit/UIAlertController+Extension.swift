//
//  UIAlertController-Extension.swift
//  Cashdoc
//
//  Created by Taejune Jung on 01/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UIAlertController {

    // MARK: 알림창
    // swiftlint:disable:next function_parameter_count
    static func presentAlertController(target: UIViewController,
                                       title: String?,
                                       massage: String?,
                                       actionStyle: UIAlertAction.Style = UIAlertAction.Style.default,
                                       okBtnTitle: String,
                                       cancelBtn: Bool,
                                       cancelBtnTitle: String = "",
                                       completion: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: massage, preferredStyle: .alert)
        if cancelBtn {
            let cancelAction = UIAlertAction(title: cancelBtnTitle, style: .default, handler: nil)
            alert.addAction(cancelAction)
        }
        let okAction = UIAlertAction(title: okBtnTitle, style: actionStyle, handler: completion)
        alert.addAction(okAction)
        
        DispatchQueue.main.async {
            target.present(alert, animated: true, completion: nil)
        }
    }
}
