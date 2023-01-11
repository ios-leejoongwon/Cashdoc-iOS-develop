//
//  PropertyTableView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 10/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit
import RxDataSources
import RxSwift
import RxCocoa
import RealmSwift

protocol PropertyTableViewDelegate: AnyObject {
    func configureInfoView(totalAmount: Int)
}

class PropertyTableView: SelfSizedTableView {
    
    // MARK: - Properties
    
    weak var customDelegate: PropertyTableViewDelegate?
    
    var tableViewHeight: NSLayoutConstraint!
    
    private var viewModel: PropertyTableViewModel!
    private var rootViewController: UIViewController!
    private let disposeBag = DisposeBag()
    
    private let accountExpanded = BehaviorRelay<Bool>(value: false)
    private let cardExpanded = BehaviorRelay<Bool>(value: false)
    private let loanExpanded = BehaviorRelay<Bool>(value: false)
    private let etcExpanded = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Con(De)structor
    
    init(viewModel: PropertyTableViewModel,
         rootViewController: UIViewController) {
        
        self.viewModel = viewModel
        self.rootViewController = rootViewController
        super.init(frame: .zero, style: .plain)
        
        setProperties()
        setRegister()
        bindViewModel()
        layout()
        reloadTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {

        // Input
        let layoutSubViews = rx.sentMessage(#selector(UITableView.layoutSubviews)).mapToVoid().take(1).asDriverOnErrorJustNever()
        let reload = rx.sentMessage(#selector(UITableView.reloadData)).mapToVoid().take(1).asDriverOnErrorJustNever()
        let trigger = Driver.merge(layoutSubViews, reload)
        let input = PropertyTableViewModel.Input(trigger: trigger)

        // Output
        let output = viewModel.transform(input: input)
        
        output.totalAmountFetching
            .bind { [weak self] (totalAmt) in
                guard let self = self, let delegate = self.customDelegate else { return }
                delegate.configureInfoView(totalAmount: totalAmt)
        
        }.disposed(by: disposeBag)
        
        output.sections
            .drive(self.rx.items(dataSource: PropertyDataSource()))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
//    func didChangeExpandAll(_ isExpanded: BehaviorRelay<Bool>) {
//        let check = Observable.merge(accountExpanded.asObservable(),
//                                     cardExpanded.asObservable(),
//                                     loanExpanded.asObservable())
//
//        check
//            .take(1)
//            .observe(on: MainScheduler.asyncInstance)
//            .bind { [weak self] (isExpand) in
//                guard let self = self else { return }
//                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
//                    if isExpand {
//                        self.collapseAll()
//                        isExpanded.accept(false)
//                    } else {
//                        self.expandAll()
//                        isExpanded.accept(true)
//                    }
//                }
//        }
//        .disposed(by: disposeBag)
//    }
    
    func expandAll() {
        guard let account = self.cellForRow(at: IndexPath(row: 0, section: 1)) as? PropertyAccountTableViewCell else { return }
        account.expand()
        accountExpanded.accept(true)
        guard let card = self.cellForRow(at: IndexPath(row: 0, section: 2)) as? PropertyCardTableViewCell else { return }
        card.expand()
        cardExpanded.accept(true)
        guard let loan = self.cellForRow(at: IndexPath(row: 0, section: 3)) as? PropertyLoanTableViewCell else { return }
        loan.expand()
        loanExpanded.accept(true)
        guard let etc = self.cellForRow(at: IndexPath(row: 0, section: 6)) as? PropertyEtcTableViewCell else { return }
        etc.expand()
        etcExpanded.accept(true)
        tapReloadTableView()
    }
    
    func collapseAll() {
        guard let account = self.cellForRow(at: IndexPath(row: 0, section: 1)) as? PropertyAccountTableViewCell else { return }
        account.collapse()
        accountExpanded.accept(false)
        guard let card = self.cellForRow(at: IndexPath(row: 0, section: 2)) as? PropertyCardTableViewCell else { return }
        card.collapse()
        cardExpanded.accept(false)
        guard let loan = self.cellForRow(at: IndexPath(row: 0, section: 3)) as? PropertyLoanTableViewCell else { return }
        loan.collapse()
        loanExpanded.accept(false)
        guard let etc = self.cellForRow(at: IndexPath(row: 0, section: 6)) as? PropertyEtcTableViewCell else { return }
        etc.collapse()
        etcExpanded.accept(false)
        tapReloadTableView()
    }
    
    func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            CATransaction.begin()
            self.reloadData()
            CATransaction.setCompletionBlock {
                self.tableViewHeight.constant = self.contentSize.height
                self.layoutIfNeeded()
            }
            CATransaction.commit()
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
        separatorStyle = .none
        estimatedRowHeight = 64
        rowHeight = UITableView.automaticDimension
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        isScrollEnabled = false
    }
    
    private func setRegister() {
        self.register(cellType: PropertyAccountTableViewCell.self)
        self.register(cellType: PropertyCardTableViewCell.self)
        self.register(cellType: PropertyLoanTableViewCell.self)
        self.register(PropertyCommonCardTableViewCell.self, forCellReuseIdentifier: PropertyCardType.캐시.serviceType)
        self.register(PropertyCommonCardTableViewCell.self, forCellReuseIdentifier: PropertyCardType.보험.serviceType)
        self.register(PropertyCommonCardTableViewCell.self, forCellReuseIdentifier: PropertyCardType.신용.serviceType)
        self.register(cellType: PropertyEtcTableViewCell.self)
        self.register(cellType: PropertyAddTableViewCell.self)
    }
    
    private func tapReloadTableView() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.beginUpdates()
            self.endUpdates()
        }
    }
    
}

// MARK: - RxTableViewSectionedAnimatedDataSource

extension PropertyTableView {
    private func PropertyDataSource() -> RxTableViewSectionedAnimatedDataSource<PropertySection> {
        return RxTableViewSectionedAnimatedDataSource(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: { [weak self] (dataSource, tableView, indexPath, _) in
                guard let self = self else { return UITableViewCell() }
                switch dataSource[indexPath] {
                case let .AccountItem(_, totalResult, item, _):
                    let cell = tableView.dequeueReusableCell(for: indexPath,
                                                             cellType: PropertyAccountTableViewCell.self)
                    cell.viewModel = PropertyAccountTableViewModel(navigator: self.viewModel.setNavigator())
                    
                    if !item.isEmpty {
                        cell.configureForHeaderView(linkStatus: .연동후,
                                                    amount: totalResult.totalAmount)
                        
                        cell.configureForExpandView(totalResult: totalResult,
                                                    accounts: item,
                                                    isExpand: self.accountExpanded.value)
                        
                    } else {
                        cell.configureForHeaderView(linkStatus: .연동전)
                    }

                    cell.headerViewTapGesture
                        .skip(1)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind(onNext: { [weak self] _ in
                            guard let self = self,
                                let cell = self.cellForRow(at: indexPath) as? PropertyAccountTableViewCell,
                                let propertyVC = self.rootViewController as? PropertyViewController,
                                propertyVC.checkScrollingToTap() else { return }
                            
                            if !item.isEmpty {
                                if self.accountExpanded.value {
                                    cell.collapse()
                                    self.accountExpanded.accept(false)
                                } else {
                                    cell.expand()
                                    self.accountExpanded.accept(true)
                                }
                                self.tapReloadTableView()
                            } else {
                                cell.viewModel.checkIsDoingScrapingWhenDidTapEmptyCell()
                            }

                        })
                        .disposed(by: cell.disposeBag)
                    
                    cell.containerViewTapGesture(self.rootViewController)

                    return cell

                case let .CardItem(_, totalResult, item, _):
                    let cell = tableView.dequeueReusableCell(for: indexPath,
                                                             cellType: PropertyCardTableViewCell.self)
                    cell.viewModel = PropertyCardTableViewModel(navigator: self.viewModel.setNavigator())
                    
                    if !item.isEmpty {
                        cell.configureForHeaderView(linkStatus: .연동후,
                                                    amount: totalResult.totalAmount)
                        cell.configureForExpandView(cards: item,
                                                    totalResult: totalResult,
                                                    isExpand: self.cardExpanded.value)
                    } else {
                        cell.configureForHeaderView(linkStatus: .연동전)
                    }

                    cell.headerViewTapGesture
                        .skip(1)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind(onNext: { [weak self] _ in
                            guard let self = self,
                                let cell = self.cellForRow(at: indexPath) as? PropertyCardTableViewCell,
                                let propertyVC = self.rootViewController as? PropertyViewController,
                                propertyVC.checkScrollingToTap() else { return }
                            
                            if !item.isEmpty {
                                if self.cardExpanded.value {
                                    cell.collapse()
                                    self.cardExpanded.accept(false)
                                } else {
                                    cell.expand()
                                    self.cardExpanded.accept(true)
                                }
                                self.tapReloadTableView()
                            } else {
                                cell.viewModel.checkIsDoingScrapingWhenDidTapEmptyCell()
                            }
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    cell.containerViewTapGesture(self.rootViewController)
                    
                    return cell

                case let .LoanItem(_, totalResult, item, _):
                    let cell = tableView.dequeueReusableCell(for: indexPath,
                                                             cellType: PropertyLoanTableViewCell.self)
                    cell.viewModel = PropertyLoanTableViewModel(navigator: self.viewModel.setNavigator())
                    if !item.isEmpty {
                        cell.configureForHeaderView(linkStatus: .연동후,
                                                    amount: totalResult.totalAmount)
                        cell.configureForExpandView(totalResult: totalResult,
                                                    loans: item,
                                                    isExpand: self.loanExpanded.value)
                    } else {
                        cell.configureForHeaderView(linkStatus: .연동전)
                    }
                    
                    cell.headerViewTapGesture
                        .skip(1)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind(onNext: { [weak self] _ in
                            guard let self = self,
                                let cell = self.cellForRow(at: indexPath) as? PropertyLoanTableViewCell,
                                let propertyVC = self.rootViewController as? PropertyViewController,
                                propertyVC.checkScrollingToTap() else { return }
                            
                            if !item.isEmpty {
                                if self.loanExpanded.value {
                                    cell.collapse()
                                    self.loanExpanded.accept(false)
                                } else {
                                    cell.expand()
                                    self.loanExpanded.accept(true)
                                }
                                self.tapReloadTableView()
                            } else {
                                cell.viewModel.checkIsDoingScrapingWhenDidTapEmptyCell()
                            }
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    cell.containerViewTapGesture(self.rootViewController)
                    
                    return cell
                    
                case .CashItem(_, let item, _),
                     .CreditItem(_, let item, _),
                     .InsuranceItem(_, let item, _):
                    guard let cell = tableView.dequeueReusableCell(withIdentifier: item.type.serviceType, for: indexPath) as? PropertyCommonCardTableViewCell else {
                        return UITableViewCell()
                    }
                    cell.configure(with: item)
                    cell.containerViewTapGesture
                        .skip(1)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { [weak self] (_) in
                            guard let self = self,
                            let propertyVC = self.rootViewController as? PropertyViewController,
                                propertyVC.checkScrollingToTap() else { return }
                            switch item.type {
                            case .캐시:
                                self.viewModel.pushToCashViewController()
                            case .신용:
                                GlobalFunction.FirLog(string: "자산_미연동_신용_클릭")
                                GlobalFunction.pushToSafariBrowser(url: API.CREDIT_JOIN_URL)
                            case .보험:
                                HealthNavigator.pushInsuranPage()
                            default:
                                return
                            }
                    }
                    .disposed(by: cell.disposeBag)
                    return cell
                case .EtcItem(_, let totalAmt, let item, _):
                    let cell = tableView.dequeueReusableCell(for: indexPath,
                                                             cellType: PropertyEtcTableViewCell.self)
                    cell.viewModel = PropertyCardTableViewModel(navigator: self.viewModel.setNavigator())
                    
                    if !item.isEmpty {
                        cell.configureForHeaderView(linkStatus: .연동후,
                                                    amount: totalAmt)
                        cell.configureForExpandView(items: item,
                                                    isExpand: self.etcExpanded.value)
                    } else {
                        cell.configureForHeaderView(linkStatus: .연동전)
                    }

                    cell.headerViewTapGesture
                        .skip(1)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind(onNext: { [weak self] _ in
                            guard let self = self,
                                let cell = self.cellForRow(at: indexPath) as? PropertyEtcTableViewCell,
                                let propertyVC = self.rootViewController as? PropertyViewController,
                                propertyVC.checkScrollingToTap() else { return }
                            
                            if !item.isEmpty {
                                if self.etcExpanded.value {
                                    cell.collapse()
                                    self.etcExpanded.accept(false)
                                } else {
                                    cell.expand()
                                    self.etcExpanded.accept(true)
                                }
                                self.tapReloadTableView()
                            } else {
                                let vc = EtcAddViewController(data: nil)
                                GlobalFunction.pushVC(vc, animated: true)
                            }
                            
                        })
                        .disposed(by: cell.disposeBag)
                    
                    cell.containerViewTapGesture(self.rootViewController)
                    
                    return cell
                    
                case .AddItem:
                    let cell = tableView.dequeueReusableCell(for: indexPath,
                                                             cellType: PropertyAddTableViewCell.self)
                    cell.containerViewTapGesture
                        .skip(1)
                        .observe(on: MainScheduler.asyncInstance)
                        .bind { [weak self] (_) in
                            guard let self = self,
                            let propertyVC = self.rootViewController as? PropertyViewController,
                            propertyVC.checkScrollingToTap() else { return }
                            
                            self.checkIsDoingScrapingWhenDidTapEmptyCell()
                    }
                    .disposed(by: cell.disposeBag)
                    
                    return cell
                }
        },
            canEditRowAtIndexPath: { _, _ in
                return false
        },
            canMoveRowAtIndexPath: { _, _ in
                return true
        })
    }
    
    private func checkIsDoingScrapingWhenDidTapEmptyCell() {
        guard !SmartAIBManager.checkIsDoingPropertyScraping() else {
            self.rootViewController.view.makeToastWithCenter("자산 데이터를 가져오고 있습니다.\n잠시만 기다려 주세요.")
            return
        }
        
        if let islinked = UserDefaults.standard.object(forKey: UserDefaultKey.kIsLinkedProperty.rawValue) as? Bool, islinked == true {
            self.viewModel.pushToLinkPropertyOneByOneViewController()
        } else {
            self.viewModel.pushToLinkPropertyViewController(isAnimated: true)
        }
    }
}

// MARK: - Layout

extension PropertyTableView {
    
    private func layout() {
        tableViewHeight = heightAnchor.constraint(equalToConstant: contentSize.height)
        tableViewHeight.isActive = true
    }
}
