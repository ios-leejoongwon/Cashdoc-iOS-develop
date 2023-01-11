//
//  CpqProblemWinnerViewController.swift
//  Cashdoc
//
//  Created by A lim on 04/04/2022.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class CpqProblemWinnerViewController: CashdocViewController {
    
    // MARK: - NSLayoutConstraints
    private var tableViewHeight: NSLayoutConstraint!
    
    // MARK: - Properties
    
    var cpqQuizModel: CpqQuizModel? {
        didSet {
            guard let cpqQuizModel = cpqQuizModel else {return}
            
            if cpqQuizModel.winnerList!.count > 0 {
                horizontalLine.alpha = 1
                winnerTextLabel.text = "당첨을 축하합니다!"
                reloadTableView()
            }
    
        }
    }
    
    // MARK: - UI Components
    private var horizontalLine: UILabel!
    private var winnerTextLabel: UILabel!
    private var tableView: UITableView! 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setDelegate()
    }
    
    // MARK: - Private methods
    private func setDelegate() {
        tableView.dataSource = self
    }
    
    private func reloadTableView() {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            self.tableViewHeight.constant = self.tableView.contentSize.height+15
            self.view.layoutIfNeeded()
        }
        tableView.reloadData()
        CATransaction.commit()
    }
    
    private func setupUI() {
        horizontalLine = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .lineGrayCw
            $0.alpha = 0
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.leading.trailing.equalTo(view)
                $0.height.equalTo(8)
            }
        }
        winnerTextLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            $0.textColor = .black
            $0.numberOfLines = 1
            $0.text = ""
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(horizontalLine.snp.bottom).offset(22)
                $0.centerX.equalTo(view)
            }
        }
        tableView = UITableView(frame: .zero, style: .plain).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.isScrollEnabled = false
            $0.backgroundColor = .clear
            $0.estimatedRowHeight = 60
            $0.rowHeight = UITableView.automaticDimension
            $0.separatorColor = .clear
            $0.register(cellType: CpqQuizWinnerListCell.self)
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.equalTo(winnerTextLabel.snp.bottom).offset(12)
                $0.leading.trailing.bottom.equalTo(view)
            }
            tableViewHeight = $0.heightAnchor.constraint(equalToConstant: 0)
            tableViewHeight.isActive = true
        }
    }
}

// MARK: - UITableViewDataSource

extension CpqProblemWinnerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cpqQuizModel = cpqQuizModel else {return 0}
        return cpqQuizModel.winnerList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: CpqQuizWinnerListCell.self)
        guard let cpqQuizModel = cpqQuizModel else {return cell}
        cell.cpqWinnerModel = cpqQuizModel.winnerList?[safe: indexPath.row]
        return cell
    }
}
