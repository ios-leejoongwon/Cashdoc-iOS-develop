//
//  ConsumeTypeFilterViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 19/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ConsumeTypeFilterViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var selectedIndex = 0
    var selectedItem = PublishRelay<ConsumeContentsItem>()
    
    var incomeConsumeListViewController: ConsumeListViewController!
    var outgoingConsumeListViewController: ConsumeListViewController!
    var etcConsumeListViewController: ConsumeListViewController!
    
    private var viewModel: ConsumeTypeFilterViewModel!
    private var consumeType: CategoryType!
    
    // MARK: - UI Components
    
    private let naviView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
//    private let closeButton = UIButton().then {
//        $0.translatesAutoresizingMaskIntoConstraints = false
//        $0.setImage(UIImage(named: "icCloseBlack"), for: .normal)
//    }
    private let closeButton = UIBarButtonItem().then {
        $0.image = UIImage(named: "icCloseBlack")
        $0.style = .plain
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 20)
    }
    private let headerView = CustomMenuBarView(menus: ["수입", "지출", "기타"]).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: ConsumeTypeFilterViewModel, consumeType: (String, CategoryType)) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.title = self.changeDateTitle(selectedDate: consumeType.0)
//        self.titleLabel.text = self.changeDateTitle(selectedDate: consumeType.0)
        self.consumeType = consumeType.1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        setDelegate()
        bindView()
//        view.addSubview(naviView)
//        naviView.addSubview(closeButton)
//        naviView.addSubview(titleLabel)
        view.addSubview(headerView)
        view.addSubview(contentView)
        addChild(incomeConsumeListViewController)
        addChild(outgoingConsumeListViewController)
        addChild(etcConsumeListViewController)
        contentView.addSubview(incomeConsumeListViewController.view)
        contentView.addSubview(outgoingConsumeListViewController.view)
        contentView.addSubview(etcConsumeListViewController.view)
        layout()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                self.navigationController?.popViewController(animated: true)
            })
        .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func changeDateTitle(selectedDate: String) -> String {
        let year = selectedDate.subString(to: 4)
        var month = selectedDate.subString(from: 4)
        
        let formatter = DateFormatter()
        let date = Date()
        formatter.dateFormat = "yyyy"
        let currentYear = formatter.string(from: date)
        
        formatter.dateFormat = "MM"
        if month.subString(to: 1) == "0" {
            month = month.subString(from: 1)
        }
        
        if currentYear == year {
            return month + "월"
        } else {
            return year + "년" + " " + month + "월"
        }
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        GlobalDefine.shared.curNav?.navigationItem.leftBarButtonItem = closeButton
        self.navigationItem.leftBarButtonItem = closeButton
        headerView.menuContentViews.append(incomeConsumeListViewController.view)
        headerView.menuContentViews.append(outgoingConsumeListViewController.view)
        headerView.menuContentViews.append(etcConsumeListViewController.view)
        for view in headerView.menuContentViews {
            view.isHidden = true
        }
        headerView.menuContentViews.first?.isHidden = false
        headerView.prevMenuContentView = incomeConsumeListViewController.view
        
        switch self.consumeType {
        case .수입:
            headerView.initialSelectedItem(with: 0)
        case .지출:
            headerView.initialSelectedItem(with: 1)
        case .기타:
            headerView.initialSelectedItem(with: 2)
        default:
            break
        }
    }
    
    private func setDelegate() {
        headerView.delegate = self
    }
}

// MARK: - Layout

extension ConsumeTypeFilterViewController {
    
    private func layout() {
//        naviView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
//        naviView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
//        naviView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
//        naviView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
//        closeButton.topAnchor.constraint(equalTo: naviView.topAnchor, constant: 16).isActive = true
//        closeButton.leadingAnchor.constraint(equalTo: naviView.leadingAnchor, constant: 16).isActive = true
//        closeButton.widthAnchor.constraint(equalTo: closeButton.heightAnchor).isActive = true
//        closeButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
//
//        titleLabel.centerXAnchor.constraint(equalTo: naviView.centerXAnchor).isActive = true
//        titleLabel.centerYAnchor.constraint(equalTo: closeButton.centerYAnchor).isActive = true
        
        headerView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentViewLayout()
    }
    
    private func contentViewLayout() {
        incomeConsumeListViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        incomeConsumeListViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        incomeConsumeListViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        incomeConsumeListViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        outgoingConsumeListViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        outgoingConsumeListViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        outgoingConsumeListViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        outgoingConsumeListViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        etcConsumeListViewController.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        etcConsumeListViewController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        etcConsumeListViewController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        etcConsumeListViewController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

// MARK: - CustomMenuBarViewDelegate

extension ConsumeTypeFilterViewController: CustomMenuBarViewDelegate {
    func didSelectedMenu(index: Int) {
        guard headerView.menuContentViews[index] != headerView.prevMenuContentView else {return}
        headerView.menuContentViews[index].isHidden = false
        headerView.menuContentViews[index].isHidden = false
        headerView.prevMenuContentView.isHidden = true
        headerView.prevMenuContentView = headerView.menuContentViews[index]
    }
}
