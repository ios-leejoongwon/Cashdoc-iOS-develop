//
//  UIViewController+Extensions.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 06/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
 
extension UIViewController {
    
    var topbarHeight: CGFloat {
        let statusBar_height = self.navigationController?.navigationBar.frame.height ?? 0.0
        if #available(iOS 13.0, *) {
            return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) + statusBar_height
        } else {
            let topBarHeight = UIApplication.shared.statusBarFrame.size.height + statusBar_height
            return topBarHeight
        }
    }
    
    var isModal: Bool {
        if let navigationController = navigationController, navigationController.viewControllers.first != self {return true}
        if presentingViewController != nil {return false}
        if navigationController?.presentingViewController?.presentedViewController == navigationController {return false}
        if tabBarController?.presentingViewController is UITabBarController {return false}
        return true
    }
    
    @discardableResult
    func alert(title: String? = nil,
               message: String? = nil,
               preferredStyle: UIAlertController.Style = .alert,
               actions: [UIAlertAction]?,
               textFieldHandlers: [((UITextField) -> Void)]? = nil,
               completion: SimpleCompletion? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        if let actions = actions {
            actions.forEach({ (action) in
                alert.addAction(action)
            })
        }
        if let textFieldHandlers = textFieldHandlers {
            textFieldHandlers.forEach { (handler) in
                alert.addTextField(configurationHandler: handler)
            }
        }        
        DispatchQueue.main.async { [weak self] in
            self?.present(alert, animated: true, completion: completion)
        }
        return alert
    }
    
    func simpleAlert(title: String? = nil, message: String? = nil) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    // self.view 탭시 키보드를 닫아주는기능 
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = true
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    static func visibleViewController(from viewController: UIViewController?) -> UIViewController? {
        if let navigationController = viewController as? UINavigationController {
            return UIViewController.visibleViewController(from: navigationController.visibleViewController)
        } else if let tabBarController = viewController as? UITabBarController {
            return UIViewController.visibleViewController(from: tabBarController.selectedViewController)
        } else {
            if let presentedViewController = viewController?.presentedViewController {
                return UIViewController.visibleViewController(from: presentedViewController)
            } else {
                return viewController
            }
        }
    }
    
    var layoutInsets: UIEdgeInsets {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets
        } else {
            return UIEdgeInsets(top: topLayoutGuide.length,
                                left: 0.0,
                                bottom: bottomLayoutGuide.length,
                                right: 0.0)
        }
    }
    
    var layoutGuide: LayoutGuideProvider {
        if #available(iOS 11.0, *) {
            return view!.safeAreaLayoutGuide
        } else {
            return CustomLayoutGuide(topAnchor: topLayoutGuide.bottomAnchor,
                                     bottomAnchor: bottomLayoutGuide.topAnchor)
        }
    }
    
    func setCurrentBackButton(title: String) {
        guard let vcCount = self.navigationController?.viewControllers.count else {
            return
        }

        let priorVCPosition = vcCount - 2

        guard priorVCPosition >= 0 else {
            return
        }

        if let getViewCon = self.navigationController?.viewControllers[safe: priorVCPosition] {
            getViewCon.navigationItem.backBarButtonItem = UIBarButtonItem(title: title, style: .plain, target: self, action: nil)
        }
    }
}

protocol LayoutGuideProvider {
    var topAnchor: NSLayoutYAxisAnchor { get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}
extension UILayoutGuide: LayoutGuideProvider {}

class CustomLayoutGuide: LayoutGuideProvider {
    let topAnchor: NSLayoutYAxisAnchor
    let bottomAnchor: NSLayoutYAxisAnchor
    init(topAnchor: NSLayoutYAxisAnchor, bottomAnchor: NSLayoutYAxisAnchor) {
        self.topAnchor = topAnchor
        self.bottomAnchor = bottomAnchor
    }
}

extension UINavigationController {
    func removeVC(_ kindClass: AnyClass) {
        self.viewControllers = self.viewControllers.filter {!$0.isKind(of: kindClass)}
    }
    
    func containsVC(_ kindClass: AnyClass) -> Bool {
        return self.viewControllers.contains(where: {$0.isKind(of: kindClass)})
    }
    
    func setToVC(_ kindClass: AnyClass) -> UIViewController? {
        var stack: [UIViewController] = self.viewControllers
        var index: Int = 0
        for vc in stack {
            if vc.isKind(of: kindClass) {
                stack.remove(at: index)
                stack.append(vc)
                self.viewControllers = stack
                return vc
            }
            index += 1
        }
        
        return nil
    }
    
    func activateVC(_ kindClass: AnyClass) {
        if containsVC(kindClass) {
            _ = setToVC(kindClass)
        }
    }
}
