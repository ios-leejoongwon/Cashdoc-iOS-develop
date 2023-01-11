//
//  UIWindow+ReplaceRootViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 18/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

extension UIView {
    var snapshot: UIImage! {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: bounds, afterScreenUpdates: true)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension UIWindow {
    func replaceRootViewController(with replacementController: UIViewController?,
                                   animated: Bool,
                                   completion: (() -> Void)? = nil) {
        let snapshotImageView = UIImageView(image: snapshot)
        addSubview(snapshotImageView)
        
        let dismissCompletion = { () -> Void in
            self.rootViewController = replacementController
            self.bringSubviewToFront(snapshotImageView)
            if animated {
                UIView.animate(withDuration: 0.4, animations: { () -> Void in
                    snapshotImageView.alpha = 0
                }, completion: { (_) -> Void in
                    snapshotImageView.removeFromSuperview()
                    completion?()
                })
            } else {
                snapshotImageView.removeFromSuperview()
                completion?()
            }
        }
        
        guard rootViewController?.presentedViewController != nil else {
            dismissCompletion()
            return
        }
        rootViewController?.dismiss(animated: false, completion: dismissCompletion)
    }
}
