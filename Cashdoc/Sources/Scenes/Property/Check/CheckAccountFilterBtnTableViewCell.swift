//
//  CheckAccountFilterBtnTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/05/26.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

final class CheckAccountFilterBtnTableViewCell: CashdocTableViewCell {
    
    private weak var filterButton: UIButton!
    
    func setupView() {
        filterButton = UIButton().then {
            $0.setTitle("전체 내역", for: .normal)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.setImage(UIImage(named: "icArrow01StyleDownGray"), for: .normal)
            $0.contentHorizontalAlignment = .left
            $0.semanticContentAttribute = .forceRightToLeft
            contentView.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalToSuperview().inset(12)
                m.bottom.equalToSuperview().inset(4)
                m.trailing.equalToSuperview().inset(20)
            }
        }
    }
    
    func setupProperty() {
        backgroundColor = .clear
    }
    
    func clickToFilterButton(completion: ((PropertyCheckAccountViewController.FilterType?) -> Void)? = nil) {
        filterButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            GlobalFunction.CDActionSheet("내역 선택", leftItems: ["전체 내역", "입금 내역", "출금 내역"]) { (_, name) in
                self.filterButton.setTitle(name, for: .normal)
                completion?(PropertyCheckAccountViewController.FilterType(rawValue: name))
            }
        }.disposed(by: cellDisposeBag)
    }
}
