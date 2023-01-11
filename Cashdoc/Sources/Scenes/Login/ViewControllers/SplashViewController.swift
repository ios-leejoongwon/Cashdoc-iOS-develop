//
//  SplashViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 16/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

final class SplashViewController: CashdocViewController {
    
    // MARK: - UI Components
    
    private let appIconImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCashdocLogo")
    }
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        bindViewModel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        view.addSubview(appIconImageView)
        layout()
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
    }
    
}

// MARK: - Layout

extension SplashViewController {
    
    private func layout() {
        self.appIconImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.appIconImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
}
