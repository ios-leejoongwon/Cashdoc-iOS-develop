//
//  InquireViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class InquireViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var viewModel: InquireViewModel!
    
    // MARK: - UI Components
    
    // MARK: - Con(De)structor
    
    init(viewModel: InquireViewModel) {
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        layout()
    }
    // MARK: - Binding
    
    private func bindViewModel() {
        // Input
        
        // Output
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        self.title = "불편신고"
    }
    
}

// MARK: - Layout

extension InquireViewController {
    
    private func layout() {
    }
    
}
