//
//  PropertyLoanDetailViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class PropertyLoanDetailViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var aModel: CheckAllAccountInBankList?
    var cModel: CheckCardLoanDetailsList?
    
    // MARK: - UI Components
    
    private weak var nameLabel: UILabel!
    private weak var bankNameLabel: UILabel!
    private weak var remainAmtView: UIView!
    private weak var remainLabel: UILabel!
    private weak var remainAmountLabel: UILabel!
    private weak var middleLine: UIImageView!
    private weak var amtTitleLabel: UILabel!
    private weak var amtLabel: UILabel!
    private weak var rateTitleLabel: UILabel!
    private weak var rateLabel: UILabel!
    private weak var openTitleLabel: UILabel!
    private weak var openLabel: UILabel!
    private weak var closeTitleLabel: UILabel!
    private weak var closeLabel: UILabel!
    private weak var memoTitleLabel: UILabel!
    private weak var memoLabel: UILabel!
    private weak var editButton: UIButton!
    private weak var removeButton: UIButton!
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        bindView()
        setHiddenButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if aModel != nil {
            configureForAccount()
        } else {
            configureForCard()
        }
    }
    
    // MARK: - Binding
    
    private func bindView() {
        editButton.rx.tap
            .map { [weak self] in self?.aModel }
            .filterNil()
            .bind { (aModel) in
                let vc = LoanAddViewController()
                vc.getModel = aModel
                GlobalFunction.pushVC(vc, animated: true)
        }.disposed(by: disposeBag)
        
        removeButton.rx.tap
            .map { [weak self] in self?.aModel?.identity }
            .filterNil()
            .bind { [weak self] (id) in
                guard let self = self else { return }
                GlobalFunction.getAlertController(vc: self,
                                                  title: "삭제",
                                                  message: "선택하신 대출 내역이 삭제됩니다.\n정말 삭제하시겠습니까?")
                    .bind(onNext: { (isOk) in
                        guard isOk else { return }
                        AccountListRealmProxy().delete(identity: id)
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    })
                    .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func configureForAccount() {
        if let name = aModel?.acctKind {
            nameLabel.text = name.isOrEmptyCD
        }
        if let bankName = aModel?.fCodeName {
            let number = aModel?.number ?? ""
            bankNameLabel.text = String(format: "%@ %@", bankName, number).isOrEmptyCD
        }
        // 현재잔액
        if let curBal = aModel?.loanCurBal {
            remainAmountLabel.text = String(format: "%@원", curBal.commaValue).isOrEmptyCD
        }
        // 대출금
        if let loanBal = aModel?.loanBal {
            amtLabel.text = String(format: "%@원", loanBal.commaValue).isOrEmptyCD
        }
        if let enbBal = aModel?.enbBal {
            amtLabel.text = String(format: "%@원", enbBal.commaValue).isOrEmptyCD
        }
        // 이자율
        if let rate = aModel?.interastRate {
            let formatter = NumberFormatter()
            formatter.decimalSeparator = "."
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 3
            if let value = formatter.string(from: NSNumber(value: Double(rate) ?? 0)) {
                rateLabel.text = String(format: "%@%%", value).isOrEmptyCD
            }
        }
        // 개시일
        if let open = aModel?.openDate {
            openLabel.text = open.toDateFormatted.isOrEmptyCD
        }
        // 만기일
        if let close = aModel?.closeDate {
            closeLabel.text = close.toDateFormatted.isOrEmptyCD
        }
        // 메모
        if let memo = aModel?.memo {
            memoLabel.text = memo
        }
    }
    
    private func configureForCard() {
        if let cardName = cModel?.fCodeName {
            nameLabel.text = cardName.isOrEmptyCD
        }
        if let remainAmt = cModel?.curAmt {
            remainAmountLabel.text = String(format: "%@원", remainAmt.commaValue).isOrEmptyCD
        }
        if let loanAmt = cModel?.loanAmt {
            amtLabel.text = String(format: "%@원", loanAmt.commaValue).isOrEmptyCD
        }
        if let rate = cModel?.interastRate {
            rateLabel.text = String(format: "%@%", rate).isOrEmptyCD
        }
        if let open = cModel?.openDate {
            openLabel.text = open.toDateFormatted.isOrEmptyCD
        }
        if  let close = cModel?.closeDate {
            closeLabel.text = close.toDateFormatted.isOrEmptyCD
        }
    }
    
    private func setHiddenButton() {
        if let isHandWrite = aModel?.isHandWrite {
            memoTitleLabel.isHidden = !isHandWrite
            memoLabel.isHidden = !isHandWrite
            editButton.isHidden = !isHandWrite
            removeButton.isHidden = !isHandWrite
        }
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        navigationItem.title = "대출 상세"
        
        nameLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(16)
                make.leading.equalToSuperview().inset(24)
            }
        }
        bankNameLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownishGrayCw
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom)
                make.leading.equalTo(nameLabel.snp.leading)
            }
        }
        remainAmountLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = .blackCw
            $0.textAlignment = .right
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(bankNameLabel.snp.bottom).offset(14.8)
                make.trailing.equalToSuperview().inset(24)
            }
        }
        remainAmtView = UIView().then {
            $0.backgroundColor = .iceBlueCw
            $0.layer.cornerRadius = 11
            $0.clipsToBounds = true
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.bottom.equalTo(remainAmountLabel.snp.top).offset(-6.8)
                make.trailing.equalTo(remainAmountLabel)
                make.width.equalTo(60)
                make.height.equalTo(22)
            }
        }
        remainLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .blueCw
            $0.textAlignment = .center
            $0.text = "현재잔액"
            remainAmtView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview().inset(2)
                make.leading.trailing.equalToSuperview().inset(7)
            }
        }
        middleLine = UIImageView().then {
            $0.backgroundColor = .grayTwoCw
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(remainAmountLabel.snp.bottom).offset(23.2)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(8)
            }
        }
        amtTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "대출금"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(middleLine.snp.bottom).offset(32)
                make.leading.equalTo(nameLabel)
            }
        }
        amtLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(amtTitleLabel)
                make.leading.equalTo(amtTitleLabel).offset(45)
            }
        }
        rateTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "이자율"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(amtTitleLabel.snp.bottom).offset(24)
                make.leading.equalTo(nameLabel)
            }
        }
        rateLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(rateTitleLabel)
                make.leading.equalTo(amtLabel)
            }
        }
        openTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "개시일"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(rateTitleLabel.snp.bottom).offset(24)
                make.leading.equalTo(nameLabel)
            }
        }
        openLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(openTitleLabel)
                make.leading.equalTo(amtLabel)
            }
        }
        closeTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "만기일"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(openTitleLabel.snp.bottom).offset(24)
                make.leading.equalTo(nameLabel)
            }
        }
        closeLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.text = "-"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(closeTitleLabel)
                make.leading.equalTo(amtLabel)
            }
        }
        memoTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .brownishGrayCw
            $0.text = "메모"
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(closeTitleLabel.snp.bottom).offset(24)
                make.leading.equalTo(closeTitleLabel)
            }
        }
        memoLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .blackCw
            $0.numberOfLines = 0
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(memoTitleLabel)
                make.leading.equalTo(closeLabel)
                make.trailing.lessThanOrEqualToSuperview().inset(24)
            }
        }
        editButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.grayCw.cgColor
            $0.setBackgroundColor(.white, forState: .normal)
            $0.setTitle("편집", for: .normal)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.titleLabel?.textAlignment = .center
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.leading.equalToSuperview().inset(16)
                make.height.equalTo(42)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            }
        }
        removeButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.redCw.cgColor
            $0.setBackgroundColor(.white, forState: .normal)
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.brownishGrayCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.titleLabel?.textAlignment = .center
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.leading.equalTo(editButton.snp.trailing).offset(7)
                make.trailing.equalToSuperview().inset(16)
                make.size.equalTo(editButton)
                make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            }
        }
    }
    
}
