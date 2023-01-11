//
//  CouponViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

final class ManagePropertyViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let manageType: ManageType
    private let managePropertyVC: ManagePropertyAfterViewController
    private let manageConsumeVC: ManageConsumeViewController
    
    // MARK: - UI Components
    
    private let headerView = CustomMenuBarView(menus: ["자산", "가계부"]).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Con(De)structor
    
    init(type: ManageType, date: (String, String)?) {
        self.manageType = type
        self.managePropertyVC = ManagePropertyAfterViewController()
        if let date = date {
            self.manageConsumeVC = ManageConsumeViewController(date: date)
        } else {
            self.manageConsumeVC = ManageConsumeViewController(date: GlobalFunction.rangeOfCurrentMonth())
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setDelegate()
        setInitalView()
        view.addSubview(headerView)
        view.addSubview(contentView)
        addChild(managePropertyVC)
        addChild(manageConsumeVC)
        contentView.addSubview(managePropertyVC.view)
        contentView.addSubview(manageConsumeVC.view)
        
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        title = "연동 상태 관리"
        
        managePropertyVC.view.translatesAutoresizingMaskIntoConstraints = false
        manageConsumeVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.menuContentViews.append(managePropertyVC.view)
        headerView.menuContentViews.append(manageConsumeVC.view)
        
        for view in headerView.menuContentViews {
            view.isHidden = true
        }
        headerView.menuContentViews.first?.isHidden = false
        headerView.prevMenuContentView = managePropertyVC.view
        
        headerView.initialSelectedItem(with: 0)
    }
    
    private func setInitalView() {
        switch self.manageType {
        case .자산:
            headerView.initialSelectedItem(with: 0)
        case .가계부:
            headerView.initialSelectedItem(with: 1)
        }
    }
    
    private func setDelegate() {
        headerView.delegate = self
    }
}

// MARK: - Layout

extension ManagePropertyViewController {
    
    private func layout() {
        headerView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor).isActive = true
        
        managePropertyVC.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        managePropertyVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        managePropertyVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        managePropertyVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        manageConsumeVC.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        manageConsumeVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        manageConsumeVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        manageConsumeVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

extension ManagePropertyViewController: CustomMenuBarViewDelegate {
    func didSelectedMenu(index: Int) {
        guard headerView.menuContentViews[index] != headerView.prevMenuContentView else {return}
        headerView.menuContentViews[index].isHidden = false
        headerView.prevMenuContentView.isHidden = true
        headerView.prevMenuContentView = headerView.menuContentViews[index]
    }
}
