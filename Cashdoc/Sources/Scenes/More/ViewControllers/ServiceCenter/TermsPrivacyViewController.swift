//
//  TermsPrivacyViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class TermsPrivacyViewController: CashdocWebViewController {
    
    // MARK: - Properties
    
    private var viewModel: TermsPrivacyViewModel!
    
    // MARK: - Con(De)structor
    
    init(viewModel: TermsPrivacyViewModel) {
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
        loadWebView(with: urlString)
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            viewModel.showTabBar()
        }
    }
    
    override var urlString: String {
        return "https://www.notion.so/cashwalkteam/41e08c5d212e4717a1289331317b8494"
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        self.title = "이용약관 및 개인정보 방침"
    }
    
}
