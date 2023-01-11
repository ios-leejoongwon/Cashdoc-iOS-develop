//
//  LinkPropertyOneByOneViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class LinkPropertyOneByOneViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var viewModel: LinkPropertyOneByOneViewModel!
    var bankViewController: LinkPropertyChildViewController!
    var cardViewController: LinkPropertyChildViewController!
    private let directInputVC: DirectInputViewController
    private var propertyType: LinkPropertyChildType!
    private var isPushedPlusButton: Bool = false
    
    private var middleSelectedLineCenterX: NSLayoutConstraint!
    private var bankViewControllerTop: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let headerView = CustomMenuBarView(menus: ["은행", "카드", "직접입력"])
    private let contentView = UIView()
    
    // MARK: - Con(De)structor
    
    init(propertyType: LinkPropertyChildType) {
        directInputVC = DirectInputViewController()
        super.init(nibName: nil, bundle: nil)
        self.propertyType = propertyType
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setDelegate()
        setHeaderView()
        checkPushedViewController()
        view.addSubview(headerView)
        view.addSubview(contentView)
        addChild(bankViewController)
        addChild(cardViewController)
        addChild(directInputVC)
        contentView.addSubview(bankViewController.view)
        contentView.addSubview(cardViewController.view)
        contentView.addSubview(directInputVC.view)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        navigationItem.title = "자산 추가하기"
    }
    
    private func setDelegate() {
        headerView.delegate = self
    }
    
    private func checkPushedViewController() {
        guard let viewControllers = navigationController?.viewControllers else { return }
        if viewControllers[safe: 1] is LinkPropertyOneByOneViewController {
            isPushedPlusButton = true
        } else {
            isPushedPlusButton = false
        }
    }
    
    private func setHeaderView() {
        headerView.menuContentViews.append(bankViewController.view)
        headerView.menuContentViews.append(cardViewController.view)
        headerView.menuContentViews.append(directInputVC.view)
        headerView.prevMenuContentView = bankViewController.view
        if propertyType == .카드 {
            headerView.initialSelectedItem(with: 1)
        } else {
            headerView.initialSelectedItem(with: 0)
        }
    }
}

// MARK: - Layout

extension LinkPropertyOneByOneViewController {
    private func layout() {
        headerView.snp.makeConstraints { (make) in
            make.top.leading.trailing.equalToSuperview()
        }
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        bankViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        cardViewController.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        directInputVC.view.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - CustomMenuBarViewDelegate

extension LinkPropertyOneByOneViewController: CustomMenuBarViewDelegate {
    func didSelectedMenu(index: Int) {
        guard headerView.menuContentViews[safe: index] != headerView.prevMenuContentView else { return }
        headerView.menuContentViews[safe: index]?.isHidden = false
        headerView.prevMenuContentView.isHidden = true
        headerView.prevMenuContentView = headerView.menuContentViews[safe: index]
    }
}
