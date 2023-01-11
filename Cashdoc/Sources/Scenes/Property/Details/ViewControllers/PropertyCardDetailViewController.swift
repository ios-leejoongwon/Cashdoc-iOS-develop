//
//  PropertyCardDetailViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources
import RealmSwift

final class PropertyCardDetailViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let viewModel: PropertyCardDetailViewModel
    private let cardList: CheckCardPaymentDetailsList
    
    // MARK: - UI Components
    
    private let estView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .iceBlueCw
        $0.layer.cornerRadius = 11
        $0.clipsToBounds = true
    }
    private let estLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .blueCw
        $0.textAlignment = .center
        $0.numberOfLines = 1
        $0.clipsToBounds = true
    }
    private let totalEstAmtLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 24)
        $0.textColor = .blackCw
        $0.textAlignment = .right
    }
    private let tableView = SelfSizedTableView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.showsVerticalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.estimatedRowHeight = 65
        $0.rowHeight = UITableView.automaticDimension
        $0.separatorStyle = .none
        $0.clipsToBounds = true
        $0.register(cellType: PropertyCardDetailTableViewHeaderCell.self)
        $0.register(cellType: PropertyCardDetailTableViewCell.self)
    }
    
    init(viewModel: PropertyCardDetailViewModel,
         cardList: CheckCardPaymentDetailsList) {
        self.viewModel = viewModel
        self.cardList = cardList
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        bindViewModel()
        view.addSubview(estView)
        view.addSubview(totalEstAmtLabel)
        view.addSubview(tableView)
        estView.addSubview(estLabel)
        configure()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    // MARK: - Binding
    
    private func bindViewModel() {
        let viewWillAppear = rx.sentMessage(#selector(UIViewController.viewWillAppear(_:))).take(1).mapToVoid()
        let layoutSubviews = rx.sentMessage(#selector(UITableView.layoutSubviews)).take(1).mapToVoid()
        let trigger = Driver.merge(viewWillAppear.asDriverOnErrorJustNever(),
                                   layoutSubviews.asDriverOnErrorJustNever()).map { (_) in
                                    self.cardList.identity
                                    }.filterNil()
        
        let input = type(of: self.viewModel).Input(trigger: trigger)
        
        let output = viewModel.transform(input: input)
        
        output.sections
            .drive(tableView.rx.items(dataSource: self.dataSource()))
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        view.backgroundColor = .white
        navigationItem.title = cardList.fCodeName?.isOrEmptyCD
    }
    
    private func configure() {
        guard let estAmt = cardList.estAmt, let intAmt = Int(estAmt) else { return }
        totalEstAmtLabel.text = String(format: "%@원", intAmt.commaValue).isOrEmptyCD
        
        if let date = cardList.estDate {
            estLabel.text = String(format: "%@ 결제예정", String(date.toDateFormatted.suffix(5)))
        } else {
            estView.isHidden = true
        }
    }
    
}

// MARK: - Layout

extension PropertyCardDetailViewController {
    private func layout() {
        totalEstAmtLabel.topAnchor.constraint(equalTo: view.compatibleSafeAreaLayoutGuide.topAnchor, constant: 70.8).isActive = true
        totalEstAmtLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24).isActive = true
        
        estView.bottomAnchor.constraint(equalTo: totalEstAmtLabel.topAnchor, constant: -6.8).isActive = true
        estView.trailingAnchor.constraint(equalTo: totalEstAmtLabel.trailingAnchor).isActive = true
        estView.widthAnchor.constraint(equalToConstant: 96).isActive = true
        estView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        
        estLabel.centerXAnchor.constraint(equalTo: estView.centerXAnchor).isActive = true
        estLabel.centerYAnchor.constraint(equalTo: estView.centerYAnchor).isActive = true
        
        tableView.topAnchor.constraint(equalTo: totalEstAmtLabel.bottomAnchor, constant: 23.2).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
    }
}

// MARK: - DataSource

extension PropertyCardDetailViewController {
    private func dataSource() -> RxTableViewSectionedReloadDataSource<CardDetailSection> {
        return RxTableViewSectionedReloadDataSource<CardDetailSection>(configureCell: { [weak self] (_, tv, ip, item) in
            guard self != nil else {return UITableViewCell()}
            
            switch item {
            case .header(let item, let totalAmt):
                let cell = tv.dequeueReusableCell(for: ip, cellType: PropertyCardDetailTableViewHeaderCell.self)
                cell.configure(with: item, totalAmt: totalAmt)
                return cell
            case .contents(let item):
                let cell = tv.dequeueReusableCell(for: ip, cellType: PropertyCardDetailTableViewCell.self)
                cell.configure(with: item)
                return cell
            }
        })
    }
}
