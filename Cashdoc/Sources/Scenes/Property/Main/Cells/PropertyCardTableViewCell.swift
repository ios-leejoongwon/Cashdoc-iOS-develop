//
//  PropertyCardTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 26/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxGesture
import RxSwift
import RealmSwift

final class PropertyCardTableViewCell: CardBaseTableViewCell {
    
    // MARK: - Properties
    
    var headerViewTapGesture: TapControlEvent {
        return headerView.rx.tapGesture()
    }
    var viewModel: PropertyCardTableViewModel!
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
                return self.stackContainerView.arrangedSubviews[index].rx.tapGesture()
                    .skip(1)
                    .observe(on: MainScheduler.asyncInstance)
                    .bind(onNext: { [weak self] _ in
                        guard let self = self,
                            let propertyVC = vc as? PropertyViewController,
                            propertyVC.checkScrollingToTap() else { return }
                        
                        if index == self.stackContainerView.subviews.count-1 {
                            self.viewModel.checkIsDoingScrapingWhenDidTapEmptyCell()
                        } else {
                            guard let cardView = view as? ExpandCardView,
                                !cardView.isError,
                                let cardList = CardPaymentRealmProxy().card(identity: cardView.getCardIdentity()).results.first else { return }
                            
                            guard let estAmt = cardList.estAmt,
                                !estAmt.isEmpty, estAmt != "0" else {
                                    self.viewModel.parentViewControllerForScraping().view.makeToastWithCenter("결제 예정 내역이 없습니다.")
                                    return
                            }
                            
                            self.viewModel.pushToPropertyCardDetailViewController(cardList: cardList)
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
            let view = PropertyBeforeLinkCardView.init(propertyType: .카드)
            view.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(view)
            headerViewLayout(view: view)
        case .연동후:
            guard let amount = amount else { return }
            let view = PropertyAfterLinkCardView.init(propertyType: .카드, amount: amount)
            view.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(view)
            headerViewLayout(view: view)
        }
    }
    
    func configureForExpandView(cards: [PropertyExpandCard],
                                totalResult: PropertyTotalResult,
                                isExpand: Bool) {
        for (index, card) in cards.enumerated() {
            let cardView = ExpandCardView(navigator: viewModel.getNavigator())
            cardView.configure(card: card,
                               scrapingInfoList: totalResult.scrapingInfoList)
            self.stackContainerView.addArrangedSubview(cardView)
            cardView.isHidden = !isExpand
            if index == cards.count-1 {
                let addView = ExpandAddView()
                addView.configure("카드")
                self.stackContainerView.addArrangedSubview(addView)
                addView.isHidden = !isExpand
            }
        }
        self.stackContainerViewHeightZero.isActive = !isExpand
    }
    
    func expand() {
        guard let view = headerView.subviews.first as? PropertyAfterLinkCardView else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3) {
                view.rotateImage(isExpand: true)
            }
            self.isShowExpandSubViews(isExpand: false)
            self.stackContainerView.layer.add(self.transitionAnimation(subtype: .fromBottom), forKey: "transition")
            self.stackContainerViewHeightZero.isActive = false
        }
    }
    
    func collapse() {
        guard let view = headerView.subviews.first as? PropertyAfterLinkCardView else { return }
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                view.rotateImage(isExpand: false)
                self.stackContainerViewHeightZero.isActive = true
                self.layoutIfNeeded()
            }, completion: { (_) in
                self.isShowExpandSubViews(isExpand: true)
            })
        }
    }
    
    // MARK: - Private methods
    
    private func isShowExpandSubViews(isExpand: Bool) {
        for view in stackContainerView.subviews {
            view.isHidden = isHidden
        }
    }
    
}

// MARK: - Layout

extension PropertyCardTableViewCell {
    
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
