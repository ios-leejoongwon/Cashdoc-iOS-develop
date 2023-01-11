//
//  PropertyEtcTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxGesture
import RxCocoa
import RxSwift
import RealmSwift
import RxOptional

final class PropertyEtcTableViewCell: CardBaseTableViewCell {
    
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
                            let vc = EtcAddViewController(data: nil)
                            GlobalFunction.pushVC(vc, animated: true)
                        } else {
                            guard let view = view as? ExpandEtcView,
                                let id = view.getEtcId(),
                                let item = EtcPropertyRealmProxy().getObject(with: id) else { return }
                            let vc = EtcAddViewController(data: item)
                            GlobalFunction.pushVC(vc, animated: true)
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
            let view = PropertyBeforeLinkCardView.init(propertyType: .기타자산)
            view.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(view)
            headerViewLayout(view: view)
        case .연동후:
            guard let amount = amount else { return }
            let view = PropertyAfterLinkCardView.init(propertyType: .기타자산, amount: amount)
            view.translatesAutoresizingMaskIntoConstraints = false
            headerView.addSubview(view)
            headerViewLayout(view: view)
        }
    }
    
    func configureForExpandView(items: [EtcPropertyList],
                                isExpand: Bool) {
        for (index, item) in items.enumerated() {
            let view = ExpandEtcView(navigator: viewModel.getNavigator())
            view.configure(item: item)
            self.stackContainerView.addArrangedSubview(view)
            view.isHidden = !isExpand
            if index == items.count-1 {
                let addView = ExpandAddView()
                addView.configure("기타자산")
                self.stackContainerView.addArrangedSubview(addView)
                addView.isHidden = !isExpand
            }
        }
        self.stackContainerViewHeightZero.isActive = !isExpand
    }
    
    func expand() {
        guard let view = headerView.subviews.first as? PropertyAfterLinkCardView else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
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

extension PropertyEtcTableViewCell {
    
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
