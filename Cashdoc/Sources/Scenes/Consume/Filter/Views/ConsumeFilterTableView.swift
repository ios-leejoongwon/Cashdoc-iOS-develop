//
//  ConsumeFilterTableView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class ConsumeFilterTableView: UITableView {
    
    // MARK: - Properties
    
    var tableViewHeight: NSLayoutConstraint!
    let incomeTrigger = BehaviorRelay<Bool>(value: false)
    let outgoingTrigger = BehaviorRelay<Bool>(value: false)
    let etcTrigger = BehaviorRelay<Bool>(value: false)
    
    private let disposeBag = DisposeBag()
    private var consumeType: CategoryType!
    
    // MARK: - UI Components
    private let consumeHeaderView: ConsumeFilterHeaderView = {
        let view = ConsumeFilterHeaderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setProperties()
        setRegister()
        layout()
        self.layoutIfNeeded()
        reloadTableView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal methods
    
    func reloadTableView() {
        self.reloadData()
        self.reloadInputViews()
    }
    
    func configure(_ priceAndIndex: (String, String)) {
        self.consumeHeaderView.configure(priceAndIndex)
    }
    
    func setConsumeType(type: CategoryType) {
        self.consumeType = type
        self.consumeHeaderView.setType(type: type)
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
        self.register(cellType: ConsumeDateTableViewCell.self)
        self.register(cellType: ConsumeListTableViewCell.self)
    }
}

extension ConsumeFilterTableView {
    private func layout() {
        guard let headerView = self.tableHeaderView else { return }
        headerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        headerView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        headerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }
}
