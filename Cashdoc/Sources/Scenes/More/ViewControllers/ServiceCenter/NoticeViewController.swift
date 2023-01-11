//
//  NoticeViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class NoticeViewController: CashdocWebViewController {
    
    // MARK: - Properties
    
    private var navigator: MoreNavigator!
    
    // MARK: - Con(De)structor
    
    init(navigator: MoreNavigator) {
        super.init(nibName: nil, bundle: nil)
        
        self.navigator = navigator
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
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            navigator.showTabBar()
        }
    }
    
    override var urlString: String {
        return "https://www.notion.so/cashwalkteam/72867e3b4b2246a68a0ebc5d09c34f45"
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "공지사항"
    }
    
}
