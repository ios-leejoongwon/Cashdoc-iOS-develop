//
//  ManagePropertyAfterViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 17/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ManagePropertyAfterViewController: CashdocViewController {
    
    // MARK: - Properties
    private let viewModel: ManagePropertyAfterViewModel
    
    // MARK: - UI Components
    
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.clipsToBounds = true
        $0.register(cellType: ManagePropertyTableViewHeaderCell.self)
        $0.register(cellType: ManagePropertyTableViewCell.self)
    }
    private let resolutionButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.blackCw.cgColor
        $0.backgroundColor = .white
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.blackCw, for: .normal)
        $0.setTitle("재연동 안내", for: .normal)
    }
    private let emptyView = EmptyLinkedView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.isHidden = true
    }
    
    // MARK: - Con(De)structor
    
    init() {
        self.viewModel = ManagePropertyAfterViewModel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
        view.addSubview(tableView)
        view.addSubview(resolutionButton)
        view.addSubview(emptyView)
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showChildViewController()
    }
    
    private func bindView() {
        resolutionButton
            .rx.tap
            .observe(on: MainScheduler.asyncInstance)
            .bind { [weak self] (_) in
                guard let self = self else { return }
                self.viewModel.pushToResolusionWebVC()
            }
            .disposed(by: disposeBag)
        
        emptyView
            .addButtonTap
            .bind { [weak self] (_) in
                guard let self = self else { return }
                if SmartAIBManager.checkIsDoingPropertyScraping() {
                    self.view.makeToastWithCenter("업데이트가 완료된 후 시도해주세요.", title: "자산 업데이트 중입니다.")
                } else {
                    self.toPropertyViewController()
                    guard let propertyVC = GlobalDefine.shared.mainSeg?.children[safe: 2] as? PropertyViewController else { return }
                    propertyVC.pushToLinkPropertyViewController(isAnimated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppear = rx.viewWillAppear.take(1).mapToVoid()
        let input = type(of: self.viewModel).Input(trigger: viewWillAppear.asDriverOnErrorJustNever())
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(tableView.rx.items(dataSource: RxTableViewSectionedReloadDataSource<ManagePropertySection>(configureCell: { (_, tv, ip, item) in
                switch item {
                case .header(let item):
                    let cell = tv.dequeueReusableCell(for: ip, cellType: ManagePropertyTableViewHeaderCell.self)
                    cell.configure(with: item)
                    return cell
                case .bank(let item):
                    let cell = tv.dequeueReusableCell(for: ip, cellType: ManagePropertyTableViewCell.self)
                    cell.configure(with: item)
                    cell.okButtonClickEvent
                        .bind { [weak self] (_) in
                            guard let self = self else { return }
                            guard item.pIsError else { return }
                            UIAlertController.presentAlertController(target: self, title: "다시 연동하시겠습니까?", massage: "'예'클릭 시 자산으로 이동합니다", okBtnTitle: "예", cancelBtn: true, cancelBtnTitle: "아니요") { (_) in
                                self.toPropertyViewController()
                                guard let propertyVC = GlobalDefine.shared.curNav?.viewControllers.first else { return }
                                SmartAIBManager.scrapingForRefresh(vc: propertyVC, scrapingInfoList: [item])
                            }
                    }.disposed(by: self.disposeBag)
                    return cell
                case .card(let item):
                    let cell = tv.dequeueReusableCell(for: ip, cellType: ManagePropertyTableViewCell.self)
                    cell.configure(with: item)
                    return cell
                }
            })))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    private func toPropertyViewController() {
        GlobalDefine.shared.curNav?.popToRootViewController(animated: true)
        // mydata 관련 히든
        // GlobalDefine.shared.mainSeg?.changeSegment(.자산)
    }
       
    private func setProperties() {
        view.backgroundColor = .white
    }
    
    private func showChildViewController() {
        if !LinkedScrapingV2InfoRealmProxy().allLists.results.isEmpty {
            emptyView.isHidden = true
        } else {
            emptyView.isHidden = false
        }
    }
}

// MARK: - Layout

extension ManagePropertyAfterViewController {
    
    private func layout() {
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        resolutionButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16).isActive = true
        resolutionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        resolutionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        resolutionButton.bottomAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        resolutionButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        emptyView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
