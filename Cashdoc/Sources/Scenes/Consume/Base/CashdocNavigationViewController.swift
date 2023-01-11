//
//  CashdocNavigationViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 01/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift

class CashdocNavigationController: UINavigationController {
    var disposeBag = DisposeBag()
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.isTranslucent = false
        self.hidesBarsOnSwipe = false
        self.navigationBar.backIndicatorImage = UIImage(named: "icArrow02StyleLeftBlack")
        self.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "icArrow02StyleLeftBlack")
        self.navigationBar.tintColor = .blackTwoCw
         
        self.rx.willShow.subscribe(onNext: { [weak self] (vc, _) in
            guard let self = self else { return }
            if vc.title?.isNotEmpty ?? false || vc.navigationItem.title?.isNotEmpty ?? false {
                self.navigationBar.backgroundColor = .yellowCw
                self.navigationBar.barTintColor = .yellowCw
                
                if #available(iOS 13.0, *) {
                    
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = .yellowCw
                    appearance.shadowColor = .clear
                    self.navigationBar.standardAppearance = appearance
                    self.navigationBar.scrollEdgeAppearance = appearance
                }
                
            } else {
                self.navigationBar.backgroundColor = .white
                self.navigationBar.barTintColor = .white
                
                if #available(iOS 13.0, *) {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = .white
                    appearance.shadowColor = .clear
                    self.navigationBar.standardAppearance = appearance
                    self.navigationBar.scrollEdgeAppearance = appearance
                }
            }
        }).disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}
