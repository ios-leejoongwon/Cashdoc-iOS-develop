//
//  ConsumeListViewController.swift
//  Cashdoc
//
//  Created by Taejune Jung on 26/11/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class ConsumeListViewController: CashdocViewController {
     
    // MARK: - Properties
    
    private var viewModel: ConsumeListViewModel!
    private let consumeContentRelay = PublishRelay<ConsumeContentsItem>()
    private var categoryType: CategoryType!
    private var selectedMonth: String!
    private let selectedCategoryTrigger = PublishRelay<ConsumeContentsItem>()
    private let emptyConsume = PublishRelay<Void>()
    
    // MARK: - UI Components
    
    private let consumeTableView = ConsumeFilterTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.rowHeight = UITableView.automaticDimension
        $0.backgroundColor = .grayTwoCw
    }
    private let emptyView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
        $0.clipsToBounds = true
    }
    private let emptyImageView = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgExpenseNone")
    }
    private let emptyTitleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
        $0.textAlignment = .center
        $0.text = "수입 내역이 없습니다."
    }
    // MARK: - Con(De)structor
    
    init(viewModel: ConsumeListViewModel, consumeType: (String, CategoryType)) {
        super.init(nibName: nil, bundle: nil)
        self.selectedMonth = consumeType.0
        self.categoryType = consumeType.1
        self.viewModel = viewModel
    }
     
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindView()
        bindViewModel()
        view.addSubview(consumeTableView)
        view.addSubview(emptyView)
        emptyView.addSubview(emptyImageView)
        emptyView.addSubview(emptyTitleLabel)
        
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        consumeTableView.reloadData()
    }
    
    // MARK: - Binding
    
    private func bindView() {
        consumeTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] index in
                guard let self = self else { return }
                if let cell = self.consumeTableView.cellForRow(at: index) as? ConsumeListTableViewCell {
                    guard let contents = cell.contentsItem else { return }
                    self.consumeContentRelay.accept(contents)
                }
            })
        .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let viewWillAppearTakeOne = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).map { [weak self]_ in
            return (self?.selectedMonth, self?.categoryType)}.asDriverOnErrorJustNever()
        let consumeTableViewSelectedTrigger = consumeContentRelay.asDriverOnErrorJustNever()
        let selectedCategoryButtonClicked = selectedCategoryTrigger.asDriverOnErrorJustNever()
        
        let input = type(of: self.viewModel).Input(viewWillAppearTakeOneTrigger: viewWillAppearTakeOne,
                                              selectTrigger: consumeTableViewSelectedTrigger,
                                              selectedItemTrigger: selectedCategoryButtonClicked)
        
        let output = viewModel.transform(input: input)
        
        output.section
            .drive(consumeTableView.rx.items(dataSource: self.dataSource()))
        .disposed(by: disposeBag)
        
        output.emptyConsume
            .drive(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.emptyView.isHidden = false
            })
        .disposed(by: disposeBag)
        
        Observable.zip(output.totalPriceRelay.asObservable(), output.totalIndexRelay.asObservable())
            .subscribe(onNext: { [weak self] (totalPerice, totalIndex) in
                guard let self = self else { return }
                self.consumeTableView.configure((totalPerice, totalIndex))
            })
        .disposed(by: disposeBag)
    }
     
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        view.translatesAutoresizingMaskIntoConstraints = false
        self.consumeTableView.setConsumeType(type: self.categoryType)
        emptyView.isHidden = true
        
        switch self.categoryType {
        case .수입:
            emptyTitleLabel.text = "수입 내역이 없습니다."
        case .지출:
            emptyTitleLabel.text = "지출 내역이 없습니다."
        case .기타:
            emptyTitleLabel.text = "기타 내역이 없습니다."
        default:
            break
        }
    }
}

// MARK: - Layout

extension ConsumeListViewController {
    private func layout() {
        consumeTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        consumeTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        consumeTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        consumeTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        emptyViewLayout()
    }
    
    private func emptyViewLayout() {
        emptyView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        emptyView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        emptyView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        emptyView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        emptyImageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        emptyImageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant: -65).isActive = true
        emptyImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyImageView.heightAnchor.constraint(equalTo: emptyImageView.widthAnchor, multiplier: 1).isActive = true
        
        emptyTitleLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 16).isActive = true
        emptyTitleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
    }
}

extension ConsumeListViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<ConsumeSection> {
        return RxTableViewSectionedReloadDataSource<ConsumeSection>(configureCell: { [weak self] (_, tv, ip, item) in
            guard let self = self else {return UITableViewCell()}
            self.emptyView.isHidden = true
            switch item {
            case .date(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: ConsumeDateTableViewCell.self)
                cell.configure(with: item, isFilter: true, type: self.categoryType)
                return cell
            case .contents(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: ConsumeListTableViewCell.self)
                cell.cateBtnPushed = { [weak self] in
                    self?.selectedCategoryTrigger.accept(item)
                }
                cell.configure(with: item, isMovedCashViewBottomConstraint: false, isConsumeMain: false)
                return cell
            }
        })
    }
}
