//
//  ModifyConsumeCategoryViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

struct ModifyConsumeCategoryResult {
    let index: Int
    let item: ConsumeContentsItem
    let subCategory: String
}

final class ModifyConsumeCategoryViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var contentsItem: ConsumeContentsItem!
    var consumeOutgoingCategoryVC: ConsumeCategoryViewController!
    var consumeIncomeCategoryVC: ConsumeCategoryViewController!
    var consumeEtcCategoryVC: ConsumeCategoryViewController!
    var selectedIndex = 0
    var selectedItem = PublishRelay<ConsumeContentsItem>()
    
    private var viewModel: ModifyConsumeCategoryViewModel!
    private var middleSelectedLineCenterX: NSLayoutConstraint!
    private var bankViewControllerTop: NSLayoutConstraint!
    private var isPushedPlusButton: Bool = false
    
    // MARK: - UI Components

    private let headerView = CustomMenuBarView(menus: ["지출", "수입", "기타"]).then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    private let contentView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    // MARK: - Con(De)structor
    
    init(viewModel: ModifyConsumeCategoryViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "간편수정"

        setProperties()
        setDelegate()
        bindView()
        bindViewModel()
        view.addSubview(headerView)
        view.addSubview(contentView)
        addChild(consumeOutgoingCategoryVC)
        addChild(consumeIncomeCategoryVC)
        addChild(consumeEtcCategoryVC)
        contentView.addSubview(consumeOutgoingCategoryVC.view)
        contentView.addSubview(consumeIncomeCategoryVC.view)
        contentView.addSubview(consumeEtcCategoryVC.view)
        layout()
        
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(popToVC))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
    }
    
    @objc func popToVC() {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
    }
    
    // MARK: - Binding
    private func bindView() {

    }
    
    private func bindViewModel() {
        let okTrigger = Observable.merge(consumeIncomeCategoryVC.selectRelay.asObservable(),
                                         consumeOutgoingCategoryVC.selectRelay.asObservable(),
                                         consumeEtcCategoryVC.selectRelay.asObservable())
                            .map { [weak self] (item, subCategory) in
                                (ModifyConsumeCategoryResult(index: self?.selectedIndex ?? 0, item: item, subCategory: subCategory))
                        }.asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(selectTrigger: okTrigger)
        
        _ = viewModel.transform(input: input)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        headerView.menuContentViews.append(consumeOutgoingCategoryVC.view)
        headerView.menuContentViews.append(consumeIncomeCategoryVC.view)
        headerView.menuContentViews.append(consumeEtcCategoryVC.view)
        for view in headerView.menuContentViews {
            view.isHidden = true
        }
        headerView.menuContentViews.first?.isHidden = false
        headerView.prevMenuContentView = consumeOutgoingCategoryVC.view
    }
    
    private func setDelegate() {
        headerView.delegate = self
    }
    
    // MARK: - Public methods
    
}

// MARK: - Layout

extension ModifyConsumeCategoryViewController {
    
    private func layout() {
        headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        contentView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        contentView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        contentViewLayout()
    }
    
    private func contentViewLayout() {
        consumeOutgoingCategoryVC.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        consumeOutgoingCategoryVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        consumeOutgoingCategoryVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        consumeOutgoingCategoryVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

        consumeIncomeCategoryVC.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        consumeIncomeCategoryVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        consumeIncomeCategoryVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        consumeIncomeCategoryVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        consumeEtcCategoryVC.view.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        consumeEtcCategoryVC.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        consumeEtcCategoryVC.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        consumeEtcCategoryVC.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
}

// MARK: - CustomMenuBarViewDelegate

extension ModifyConsumeCategoryViewController: CustomMenuBarViewDelegate {
    func didSelectedMenu(index: Int) {
        guard headerView.menuContentViews[index] != headerView.prevMenuContentView else {return}
        self.selectedIndex = index
        for contentView in headerView.menuContentViews {
            contentView.isHidden = true
        }
        headerView.prevMenuContentView = headerView.menuContentViews[index]
        headerView.menuContentViews[index].isHidden = false
    }
}
