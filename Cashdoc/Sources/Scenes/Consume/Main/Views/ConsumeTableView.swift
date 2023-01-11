//
//  ConsumeTableView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 09/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ConsumeTableView: UITableView {
    
    // MARK: - Properties
    
    var tableViewHeight: NSLayoutConstraint!
    let selectedTrigger = PublishRelay<String>()
    let cautionButtonTrigger = PublishRelay<String>()
    let addButtonTrigger = PublishRelay<Void>()
    let alertTrigger = PublishRelay<Void>()
    let incomeTrigger = PublishRelay<CategoryType>()
    let outgoingTrigger = PublishRelay<CategoryType>()
    let etcTrigger = PublishRelay<CategoryType>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Components
    
    private let consumeHeaderView: ConsumeHeaderView = {
        let view = ConsumeHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    private let dimView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .blackCw
        $0.alpha = 0.5
        //        $0.isHidden = true
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setProperties()
        bindView()
        setRegister()
        self.addSubview(self.dimView)
        layout()
        self.layoutIfNeeded()
        reloadTableView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindView() {
        self.consumeHeaderView.selectedTrigger.bind { [weak self] date in
            guard let self = self else { return }
            self.selectedTrigger.accept(date)
        }
        .disposed(by: disposeBag)
        
        self.consumeHeaderView.addButtonTrigger.bind { [weak self] _ in
            guard let self = self else { return }
            self.addButtonTrigger.accept(())
        }
        .disposed(by: disposeBag)
        
        self.consumeHeaderView.cautionButtonTrigger.bind { [weak self] date in
            guard let self = self else { return }
            self.cautionButtonTrigger.accept(date)
        }
        .disposed(by: disposeBag)
        
        self.consumeHeaderView.alertTrigger.bind { [weak self] _ in
            guard let self = self else { return }
            self.alertTrigger.accept(())
        }
        .disposed(by: disposeBag)
        
        self.consumeHeaderView.incomeButtonTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.incomeTrigger.accept(.수입)
            })
            .disposed(by: disposeBag)
        
        self.consumeHeaderView.outgoingButtonTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.outgoingTrigger.accept(.지출)
            })
            .disposed(by: disposeBag)
        
        self.consumeHeaderView.etcButtonTrigger
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.etcTrigger.accept(.기타)
            })
            .disposed(by: disposeBag)
        
        self.dimView.rx.tapGesture()
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.consumeHeaderView.resignTextField()
            })
            .disposed(by: disposeBag)
        
        consumeHeaderView.dimViewTrigger
            .subscribe(onNext: { [weak self] isHidden in
                guard let self = self else { return }
                self.dimView.isHidden = isHidden
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Internal methods
    
    func reloadTableView() {
        self.reloadData()
        self.reloadInputViews()
    }
    
    func configure(_ item: Int, type: CategoryType) {
        self.consumeHeaderView.configure(item, type: type)
    }
    
    func cautionButton(isHidden: Bool) {
        self.consumeHeaderView.cautionButton(isHidden: isHidden)
    }
    
    func setMonthTitle(date: String) {
        self.consumeHeaderView.setMonthTitle(date: date)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        tableHeaderView = consumeHeaderView
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
    
    private func setRegister() {
        self.register(ConsumeDateTableViewCell.self, forCellReuseIdentifier: "ConsumeDateTableViewCell")
        self.register(ConsumeListTableViewCell.self, forCellReuseIdentifier: "ConsumeListTableViewCell")
    }
}

extension ConsumeTableView {
    private func layout() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        dimView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
