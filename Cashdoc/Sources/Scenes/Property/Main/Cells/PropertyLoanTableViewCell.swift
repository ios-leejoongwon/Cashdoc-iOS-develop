//
//  PropertyLoanTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 26/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxGesture
import RxCocoa
import RxSwift

final class PropertyLoanTableViewCell: CardBaseTableViewCell {
    
    // MARK: - Properties
    
    var headerViewTapGesture: TapControlEvent {
        return headerView.rx.tapGesture()
    }
    var viewModel: PropertyLoanTableViewModel!
    private var stackViewBottom: NSLayoutConstraint!
    private var stackContainerViewHeightZero: NSLayoutConstraint!
    
    // MARK: - UI Componenets
    
    private let headerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    }
    private let stackView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 0
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    private let stackContainerView = UIStackView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.axis = .vertical
        $0.distribution = .fill
        $0.spacing = 0
        $0.backgroundColor = .white
        $0.clipsToBounds = true
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.addSubview(stackView)
        stackView.addArrangedSubview(headerView)
        stackView.addArrangedSubview(stackContainerView)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func containerViewTapGesture(_ vc: UIViewController) {
        stackContainerView.subviews.enumerated()
            .forEach { [weak self] (index, view) in
                guard let self = self else { return }
                guard !view.isKind(of: ExpandBankView.self) else { return }

                return self.stackContainerView.arrangedSubviews[index]
                    .rx.tapGesture()
                    .skip(1)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind(onNext: { [weak self] _ in
                        guard let self = self else { return }
                        guard let propertyVC = vc as? PropertyViewController,
                            propertyVC.checkScrollingToTap() else { return }
                        
                        if index == self.stackContainerView.subviews.count-1 {
                            self.viewModel.checkIsDoingScrapingWhenDidTapEmptyCell()
                        } else {
                            guard let loanView = view as? ExpandLoanView else { return }
                            guard let id = loanView.getIdentity() else { return }
                            guard let getModel = AccountListRealmProxy().account(identity: id).first else {
                                if let getModel = CardLoanListRealmProxy().card(identity: id).first {
                                    self.viewModel.pushToPropertyLoanDetailViewController(cModel: getModel)
                                }
                                return
                            }
                            if getModel.isHandWrite {
                                self.viewModel.pushToPropertyLoadAddViewController(aModel: getModel)
                            } else {
                                self.viewModel.pushToPropertyLoanDetailViewController(aModel: getModel)
                            }
                            
                        }
                    })
                    .disposed(by: self.disposeBag)
        }
    }
    
    func configureForHeaderView(linkStatus: LinkStatus, amount: String? = nil) {
        headerView.subviews.forEach {$0.removeFromSuperview()}
        stackContainerView.subviews.forEach {$0.removeFromSuperview()}
        
        switch linkStatus {
        case .연동전:
            let view = PropertyBeforeLinkCardView.init(propertyType: .대출)
            view.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(view)
            headerViewLayout(view: view)
        case .연동후:
            guard let amount = amount else { return }
            let view = PropertyAfterLinkCardView.init(propertyType: .대출, amount: amount)
            view.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(view)
            headerViewLayout(view: view)
        }
    }
    
    func configureForExpandView(totalResult: PropertyTotalResult,
                                loans: [PropertyExpandLoan],
                                isExpand: Bool) {
        var bankName = String()
        for (index, loan) in loans.enumerated() {
            guard let currentBankName = loan.fCodeName,
                let bankTotalAmount = totalResult.bankInfo?[currentBankName] else { return }
            if currentBankName != bankName {
                bankName = currentBankName
                let bankView = ExpandBankView(navigator: viewModel.getNavigator())
                bankView.configure(name: bankName,
                                   amount: bankTotalAmount,
                                   scrapingInfoList: Observable.collection(from: LinkedScrapingV2InfoRealmProxy().allLists.results).asObservable())
                self.stackContainerView.addArrangedSubview(bankView)
                bankView.isHidden = !isExpand
            }
            
            let loanView = ExpandLoanView(propertyExpandLoan: loan)
            self.stackContainerView.addArrangedSubview(loanView)
            loanView.isHidden = !isExpand
            
            if index == loans.count-1 {
                let addView = ExpandAddView()
                addView.configure("대출")
                self.stackContainerView.addArrangedSubview(addView)
                addView.isHidden = !isExpand
            }
        }
        self.stackContainerViewHeightZero.isActive = !isExpand
    }
    
    func expand() {
        guard let view = headerView.subviews.first as? PropertyAfterLinkCardView else { return }
        UIView.animate(withDuration: 0.3) {
            view.rotateImage(isExpand: true)
            self.stackContainerViewHeightZero.isActive = false
            self.layoutIfNeeded()
        }
        isShowExpandSubViews(isHidden: false)
        stackContainerView.layer.add(transitionAnimation(subtype: .fromBottom), forKey: "transition")
    }
    
    func collapse() {
        guard let view = headerView.subviews.first as? PropertyAfterLinkCardView else { return }
        UIView.animate(withDuration: 0.3, animations: {
            view.rotateImage(isExpand: false)
            self.stackContainerViewHeightZero.isActive = true
            self.layoutIfNeeded()
        }, completion: { (_) in
            self.isShowExpandSubViews(isHidden: true)
        })
    }
    
    private func isShowExpandSubViews(isHidden: Bool) {
        for view in stackContainerView.subviews {
            view.isHidden = isHidden
        }
    }
    
}

// MARK: - Layout

extension PropertyLoanTableViewCell {
    
    private func layout() {
        stackView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        stackViewBottom = stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        stackViewBottom.priority = .init(999)
        stackViewBottom.isActive = true
        
        stackContainerViewHeightZero = stackContainerView.heightAnchor.constraint(equalToConstant: 0)
        stackContainerViewHeightZero.isActive = true
        stackContainerView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
    private func headerViewLayout(view: UIView) {
        view.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        view.leadingAnchor.constraint(equalTo: headerView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: headerView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
    }
    
}
