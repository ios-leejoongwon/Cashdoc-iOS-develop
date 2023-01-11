//
//  ResolusionViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 12/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ResolusionViewController: CashdocWebViewController {
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        loadWebView(with: urlString)
    }
    
    override var urlString: String {
        return "https://www.notion.so/cashwalkteam/b7ca1284977646ac81cbeb70a2e78ce3"
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "연동 실패 시 해결 방법"
    }
    
}
