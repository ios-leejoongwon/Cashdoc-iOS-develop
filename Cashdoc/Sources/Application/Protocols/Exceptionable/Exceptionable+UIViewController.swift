//
//  Exceptionable+UIViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 19/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

private var exceptionActionButtonTapContext: UInt8 = 0
private var exceptionViewContext: UInt8 = 0
private var disposeBagContext: UInt8 = 0

extension Exceptionable where Base: UIViewController {
    
    // MARK: - Properties
    
    private(set) var exceptionView: ExceptionView? {
        get {
            return objc_getAssociatedObject(base, &exceptionViewContext, defaultValue: nil)
        }
        set {
            objc_setAssociatedObject(base, &exceptionViewContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    private(set) var exceptionActionButtonTap: ControlEvent<Void>? {
        get {
            return objc_getAssociatedObject(base, &exceptionActionButtonTapContext, defaultValue: nil)
        }
        set {
            objc_setAssociatedObject(base, &exceptionActionButtonTapContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var disposeBag: DisposeBag! {
        get {
            return objc_getAssociatedObject(base, &disposeBagContext, defaultValue: nil)
        }
        set {
            objc_setAssociatedObject(base, &disposeBagContext, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // MARK: - Internal methods
    
    func configure() {
        if self.exceptionView == nil {
            setExceptionView()
            bindReachability()
        }
    }
    
    func unconfigure() {
        exceptionView?.removeFromSuperview()
        exceptionView = nil
        exceptionActionButtonTap = nil
        disposeBag = DisposeBag()
    }
    
    // MARK: - Private methods
    
    private func setExceptionView() {
        let contentView = NetworkExceptionContentView()
        let contentLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = .blackCw
            label.text = "인터넷 연결이 원활하지 않습니다.\n다시 시도해주세요."
            return label
        }()
        let exceptionActionButton: UIButton = {
            let button = UIButton()
            button.setTitle("다시시도", for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            button.backgroundColor = .black
            button.layer.cornerRadius = 4
            return button
        }()
        let exceptionView: ExceptionView = {
            let view = ExceptionView(contentView: contentView,
                                     contentLabel: contentLabel,
                                     exceptionActionButton: exceptionActionButton,
                                     vc: self.base)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.isHidden = true
            return view
        }()
        
        defer {
            self.exceptionView = exceptionView
            self.exceptionActionButtonTap = exceptionView.exceptionActionButtonTap
        }
        
        base.view.addSubview(exceptionView)
        exceptionView.leadingAnchor.constraint(equalTo: base.view.leadingAnchor).isActive = true
        exceptionView.topAnchor.constraint(equalTo: base.view.topAnchor).isActive = true
        exceptionView.trailingAnchor.constraint(equalTo: base.view.trailingAnchor).isActive = true
        exceptionView.bottomAnchor.constraint(equalTo: base.view.bottomAnchor).isActive = true
    }
    
    private func bindReachability() {
        disposeBag = DisposeBag()
        
        base.rx
            .sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .take(1)
            .bind { [weak self] (_) in
                guard let self = self else {return}
                guard let exceptionView = self.exceptionView else {return}
                guard ReachabilityManager.reachability.connection == .unavailable else {return}

                self.base.view.bringSubviewToFront(exceptionView)
                exceptionView.isHidden = false
                self.base.view.makeToastWithCenter("네트워크 연결 상태를 확인해주세요.")
            }
            .disposed(by: disposeBag)
    }
}
