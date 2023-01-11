//
//  ConsumeViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 22/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class ConsumeViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var linkBeforeVC: ConsumeLinkBeforeViewController!
    var linkAfterVC: ConsumeLinkAfterViewController!
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
        
        let navigator = DefaultConsumeNavigator(parentViewController: self)
        self.linkBeforeVC = ConsumeLinkBeforeViewController(viewModel: .init(navigator: navigator))
        self.linkAfterVC = ConsumeLinkAfterViewController(viewModel: .init(navigator: navigator))
        
        bindView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - BInding
    
    private func bindView() {
        UserDefaults.standard.rx
            .observe(Bool.self, UserDefaultKey.kIsLinkedPropertyForConsume.rawValue)
            .filterNil()
            .distinctUntilChanged()
            .bind { [weak self] (isLinked) in
                guard let self = self else { return }
                if isLinked {
                    self.linkBeforeVC.view.removeFromSuperview()
                    self.linkBeforeVC.removeFromParent()
                    self.addChild(self.linkAfterVC)
                    self.view.addSubview(self.linkAfterVC.view)
                    self.afterViewLayout()
                    self.linkAfterVC.isFirstConnected.accept(())
                } else {
                    self.linkAfterVC.view.removeFromSuperview()
                    self.linkAfterVC.removeFromParent()
                    self.addChild(self.linkBeforeVC)
                    self.view.addSubview(self.linkBeforeVC.view)
                    self.beforeViewLayout()
                }
        }
        .disposed(by: disposeBag)
    }
}

// MARK: - Layout

extension ConsumeViewController {
    private func beforeViewLayout() {
        linkBeforeVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        linkBeforeVC.view.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        linkBeforeVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        linkBeforeVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    private func afterViewLayout() {
        linkAfterVC.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        linkAfterVC.view.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        linkAfterVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        linkAfterVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}
