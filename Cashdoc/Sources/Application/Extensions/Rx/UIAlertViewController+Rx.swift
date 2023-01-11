//
//  UIAlertViewController+Rx.swift
//  Cashdoc
//
//  Created by Oh Sangho on 21/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

protocol RxAlertActionType {
    associatedtype Result
    
    var title: String? {get}
    var style: UIAlertAction.Style {get}
    var result: Result {get}
}

struct RxAlertAction<R>: RxAlertActionType {
    typealias Result = R
    
    let title: String?
    let style: UIAlertAction.Style
    let result: R
}

struct RxDefaultAlertAction: RxAlertActionType {
    typealias Result = RxAlertControllerResult
    
    let title: String?
    let style: UIAlertAction.Style
    let result: Result
}

enum RxAlertControllerResult {
    case Ok
}

extension UIAlertController {
    static func rx_presentAlert<Action: RxAlertActionType, Result>(viewController: UIViewController,
                                                                   title: String? = nil,
                                                                   message: String? = nil,
                                                                   preferredStyle: UIAlertController.Style = .alert,
                                                                   animated: Bool = true,
                                                                   actions: [Action]) -> Observable<Result> where Action.Result == Result {
        return Observable.create({ (observer) -> Disposable in
            let alertController = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
            
            actions.map({ (rxAction) in
                UIAlertAction(title: rxAction.title, style: rxAction.style, handler: { (_) in
                    observer.onNext(rxAction.result)
                    observer.onCompleted()
                })
            })
            .forEach(alertController.addAction(_:))
            
            DispatchQueue.main.async {
                viewController.present(alertController, animated: animated, completion: nil)
            }
                        
            return Disposables.create {
                DispatchQueue.main.async {
                    alertController.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
}
