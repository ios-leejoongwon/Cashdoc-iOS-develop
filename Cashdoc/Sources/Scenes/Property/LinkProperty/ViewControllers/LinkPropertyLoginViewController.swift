//
//  LinkPropertyLoginViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 04/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

final class LinkPropertyLoginViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var selectCertificateVC: SelectCertificateViewController!
    var loginForCertificateVC: LoginForCertificateViewController!
    
    private var linkType: HowToLinkType!
    private var bankInfo: BankInfo!
    
    // MARK: - UI Components
    
    private let headerView = CustomMenuBarView(menus: ["공동인증서", "로그인"]).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Con(De)structor
    
    init(linkType: HowToLinkType,
         bankInfo: BankInfo) {
        super.init(nibName: nil, bundle: nil)
        
        self.linkType = linkType
        self.bankInfo = bankInfo
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setDelegate()
        setHeaderView()
        view.addSubview(headerView)
        addChild(selectCertificateVC)
        addChild(loginForCertificateVC)
        view.addSubview(selectCertificateVC.view)
        view.addSubview(loginForCertificateVC.view)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        switch linkType {
        case .한번에연결:
            headerView.isHidden = true
            title = "공동인증서 로그인"
        default:
            if !bankInfo.isCanLogin {
                headerView.isHidden = true
                title = bankInfo.bankName
            } else {
                headerView.isHidden = false
                title = bankInfo.bankName
            }
        }
    }
    
    private func setHeaderView() {
        headerView.menuContentViews.append(selectCertificateVC.view)
        headerView.menuContentViews.append(loginForCertificateVC.view)
        headerView.prevMenuContentView = selectCertificateVC.view
    }
    
    private func setDelegate() {
        headerView.delegate = self
    }
    
}

// MARK: - Layout

extension LinkPropertyLoginViewController {
    private func layout() {
        headerView.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        selectCertificateVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        selectCertificateVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        selectCertificateVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        selectCertificateVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        loginForCertificateVC.view.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        loginForCertificateVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        loginForCertificateVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        loginForCertificateVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

// MARK: - CustomMenuBarViewDelegate
extension LinkPropertyLoginViewController: CustomMenuBarViewDelegate {
    func didSelectedMenu(index: Int) {
        guard headerView.menuContentViews[index] != headerView.prevMenuContentView else { return }
        headerView.menuContentViews[index].isHidden = false
        headerView.menuContentViews[index].isHidden = false
        headerView.prevMenuContentView.isHidden = true
        headerView.prevMenuContentView = headerView.menuContentViews[index]
        if headerView.menuContentViews[index] == loginForCertificateVC.view {
            loginForCertificateVC.setTextField(with: true)
        } else {
            loginForCertificateVC.setTextField(with: false)
        }
    }
}
