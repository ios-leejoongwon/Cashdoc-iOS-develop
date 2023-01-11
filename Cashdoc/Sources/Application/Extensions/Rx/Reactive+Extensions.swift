//
//  Reactive+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/03.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

extension Reactive where Base: UIViewController {
    // 예제. rx.viewWillAppear.map~
    internal var viewWillAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillAppear(_:)))
    }
    internal var viewDidAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidAppear(_:)))
    }
    internal var viewWillDisAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewWillDisappear(_:)))
    }
    internal var viewDidDisAppear: Observable<[Any]> {
        return sentMessage(#selector(UIViewController.viewDidDisappear(_:)))
    }
}

extension Reactive where Base: UIView {
    public func tapGesture(_ interval: RxTimeInterval) -> Observable<Void> {
        return tapGesture().when(.recognized)
            .throttle(interval, scheduler: MainScheduler.instance)
            .mapToVoid()
    }
}

extension Reactive where Base: UIButton {
    public func tap(_ interval: RxTimeInterval) -> Observable<Void> {
        return tap.throttle(interval, scheduler: MainScheduler.instance).mapToVoid()
    }
}
