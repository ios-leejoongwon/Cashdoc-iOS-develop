//
//  ExceptionView.swift
//  Cashdoc
//
//  Created by DongHeeKang on 19/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ExceptionView: UIView {
    
    // MARK: - Properties
    
    var exceptionActionButtonTap: ControlEvent<Void> {
        return exceptionActionButton.rx.tap
    }
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let contentView: UIView
    private let contentLabel: UILabel
    private let exceptionActionButton: UIButton
    private let vc: UIViewController
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Con(De)structor
    
    init(contentView: UIView,
         contentLabel: UILabel,
         exceptionActionButton: UIButton,
         vc: UIViewController) {
        self.contentView = contentView
        self.contentLabel = contentLabel
        self.exceptionActionButton = exceptionActionButton
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentLabel.translatesAutoresizingMaskIntoConstraints = false
        self.exceptionActionButton.translatesAutoresizingMaskIntoConstraints = false
        self.vc = vc
        
        super.init(frame: .zero)
        
        setProperties()
        bindView()
        addSubview(containerView)
        containerView.addSubview(contentView)
        containerView.addSubview(contentLabel)
        containerView.addSubview(exceptionActionButton)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func bindView() {
        exceptionActionButton
            .rx.tap
            .bind(onNext: { [weak self] (_) in
                guard let self = self else { return }
                switch self.vc {
                case is CashdocWebViewController:
                    guard let webVC = self.vc as? CashdocWebViewController,
                        ReachabilityManager.reachability.connection != .unavailable else { return }
                    webVC.loadWebView(with: webVC.urlString)
                    webVC.exceptionable.unconfigure()
                default:
                    if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                        _ = appDelegate.application(UIApplication.shared, didFinishLaunchingWithOptions: nil)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    private func setProperties() {
        backgroundColor = .white
    }
    
}

// MARK: - Layout

extension ExceptionView {
    
    private func layout() {
        containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16).isActive = true
        containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16).isActive = true
        containerView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        layoutContainerView()
    }
    
    private func layoutContainerView() {
        contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        
        contentLabel.topAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 8).isActive = true
        contentLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        contentLabel.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        exceptionActionButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        exceptionActionButton.widthAnchor.constraint(equalToConstant: 136).isActive = true
        exceptionActionButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        exceptionActionButton.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 33).isActive = true
        exceptionActionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }
    
}
