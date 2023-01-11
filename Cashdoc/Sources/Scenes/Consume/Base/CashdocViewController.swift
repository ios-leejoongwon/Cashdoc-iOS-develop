//
//  CashdocViewController.swift
//  Cashdoc
//
//  Created by DongHeeKang on 21/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

@objc protocol CashdocViewControllerCustomizable: AnyObject {
    @objc optional func setupView()
    @objc optional func setupProperty()
}

class CashdocViewController: UIViewController {
    
    // MARK: - Properties
    
    var disposeBag = DisposeBag()
    
    var backButtonTitleHidden: Bool {
        return false
    }
    var networkExceptionShow: Bool {
        return false
    }
    var navigationBarIsHidden: Bool? {
        return nil
    }
    var navigationBarIsHidesBackButton: Bool? {
        return nil
    }
    var screenName: String {
        return ""
    }
    var navigationBarBarTintColorWhenAppeared: UIColor? {
        return nil
    }
    var navigationBarBarTintColorWhenDisappeared: UIColor? {
        return nil
    }
    var Identifier: String {
        return String(describing: self)
    }
    
    // MARK: - Overridden: UIViewController
    
    deinit {
        print("[👋deinit]\(String(describing: self))")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupView()
        _setupProperty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "",
                                                           style: .plain,
                                                           target: nil,
                                                           action: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if backButtonTitleHidden {
            removeBackButtonTitle()
        }
    }
    
    // MARK: - Private methods
    
    private func _setupView() {
        (self as CashdocViewControllerCustomizable).setupView?()
    }
    
    private func _setupProperty() {
        (self as CashdocViewControllerCustomizable).setupProperty?()
    }
    
    private func removeBackButtonTitle() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
    }
    
    // MARK: - Public methods
    
    func isToday(date: String?) -> Bool {
        guard let date = date else { return false }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let today = formatter.string(from: Date())
        if date == today {
            return true
        } else {
            return false
        }
    }
    
    func saveUpdateDate(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateStr = formatter.string(from: Date())
        UserDefaults.standard.set(dateStr, forKey: UserDefaultKey.kUpdateCancelDate.rawValue)
    }
}

extension CashdocViewController: CashdocViewControllerCustomizable {}
