//
//  DirectInputViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/09.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import RxDataSources

final class DirectInputViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var tableView: SelfSizedTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        bindView()
    }
    
    private func setProperties() {
        view.backgroundColor = .grayTwoCw
        view.isHidden = true
        
        tableView = SelfSizedTableView().then {
            $0.estimatedRowHeight = 84
            $0.rowHeight = UITableView.automaticDimension
            $0.showsVerticalScrollIndicator = false
            $0.backgroundColor = .clear
            $0.separatorStyle = .none
            $0.register(cellType: DirectInputTableViewCell.self)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(12)
            }
        }
    }
    
    private func bindView() {
        Observable.just([PropertyCardType.기타자산, PropertyCardType.계좌, PropertyCardType.대출])
            .bind(to: tableView.rx.items) { (tv, row, element) -> UITableViewCell in
                let cell = tv.dequeueReusableCell(for: IndexPath(row: row, section: 0), cellType: DirectInputTableViewCell.self)
                cell.configure(type: element)
                cell.cellSelected(type: element)
                return cell
        }.disposed(by: disposeBag)
    }
}
