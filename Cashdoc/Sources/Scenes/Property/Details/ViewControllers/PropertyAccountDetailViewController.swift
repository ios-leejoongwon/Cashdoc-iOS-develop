//
//  PropertyAccountDetailViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 02/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class PropertyAccountDetailViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private let data: CheckAllAccountInBankList
    
    // MARK: - UI Components
    
    private weak var nameLabel: UILabel!
    private weak var numberLabel: UILabel!
    private weak var amountLabel: UILabel!
    
    private weak var typeLabel: UILabel!
    private weak var openTitleLabel: UILabel!
    private weak var openLabel: UILabel!
    private weak var closeTitleLabel: UILabel!
    private weak var closeLabel: UILabel!
    private weak var memoTitleLabel: UILabel!
    private weak var memoLabel: UILabel!
    private weak var editButton: UIButton!
    private weak var removeButton: UIButton!
    
    init(data: CheckAllAccountInBankList) {
        self.data = data
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindView(with: data)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configure(with: data)
        setHiddenButton()
    }
    
    func setupView() {
        view.backgroundColor = .white
        
        nameLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = .blackCw
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalToSuperview().inset(16)
                make.leading.equalToSuperview().inset(24)
            }
        }
        numberLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownishGrayCw
            $0.setLineHeight(lineHeight: 20)
            $0.setUnderLine()
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(nameLabel.snp.bottom)
                make.leading.equalTo(nameLabel)
            }
        }
        amountLabel = UILabel().then {
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = .blackCw
            $0.textAlignment = .right
            $0.setLineHeight(lineHeight: 28)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(numberLabel.snp.bottom).offset(14.8)
                make.trailing.equalToSuperview().inset(24)
            }
        }
        let middleLine = UIImageView().then {
            $0.backgroundColor = .grayTwoCw
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(amountLabel.snp.bottom).offset(23.2)
                make.leading.trailing.equalToSuperview()
                make.height.equalTo(8)
            }
        }
        let typeTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "계좌 종류"
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(middleLine.snp.bottom).offset(32)
                make.leading.equalTo(nameLabel)
            }
        }
        typeLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(typeTitleLabel)
                make.leading.equalTo(typeTitleLabel.snp.trailing).offset(45)
            }
        }
        openTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "신규일"
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(typeTitleLabel.snp.bottom).offset(24)
                make.leading.equalTo(nameLabel)
            }
        }
        openLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(openTitleLabel)
                make.leading.equalTo(typeLabel)
            }
        }
        closeTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .brownishGrayCw
            $0.text = "만기일"
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(openTitleLabel.snp.bottom).offset(24)
                make.leading.equalTo(nameLabel)
            }
        }
        closeLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackCw
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.centerY.equalTo(closeTitleLabel)
                make.leading.equalTo(typeLabel)
            }
        }
        memoTitleLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .brownishGrayCw
            $0.text = "메모"
            view.addSubview($0)
        }
        memoLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.setLineHeight(lineHeight: 20)
            $0.textColor = .blackCw
            $0.numberOfLines = 0
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.equalTo(memoTitleLabel)
                make.leading.equalTo(typeLabel)
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
    
    func setupProperty() {
        navigationItem.title = "계좌 상세"
    }
    
    // MARK: - Binding
    
    private func bindView(with data: CheckAllAccountInBankList) {
        editButton.rx.tap
            .map { data }
            .bind { (model) in
                let vc = AccountAddViewController()
                vc.getModel = model
                GlobalFunction.pushVC(vc, animated: true)
        }.disposed(by: disposeBag)
        removeButton.rx.tap
            .map { data.identity }
            .filterNil()
            .bind { [weak self] (id) in
                guard let self = self else { return }
                GlobalFunction.getAlertController(vc: self,
                                                  title: "삭제",
                                                  message: "선택하신 계좌 내역이 삭제됩니다.\n정말 삭제하시겠습니까?")
                    .bind(onNext: { (isOk) in
                        guard isOk else { return }
                        AccountListRealmProxy().delete(identity: id)
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    })
                    .disposed(by: self.disposeBag)
        }.disposed(by: disposeBag)
        numberLabel.rx.tapGesture().when(.recognized).bind { [weak self] (_) in
            guard let number = self?.numberLabel.text else { return }
            UIPasteboard.general.string = number
            self?.view.makeToastWithCenter("계좌가 복사되었습니다.", duration: 2.0, completion: nil)
        }.disposed(by: disposeBag)
    }
    
    // MARK: - Private methods
    
    private func configure(with accountData: CheckAllAccountInBankList) {
        nameLabel.text = accountData.acctKind?.isOrEmptyCD
        
        if accountData.isHandWrite {
            numberLabel.text = String(format: "%@", accountData.fCodeName ?? "-")
        } else {
            numberLabel.text = String(format: "%@ %@", accountData.fCodeName ?? "-", accountData.number ?? "-")
        }
        numberLabel.setUnderLine()
        if let amount = accountData.curBal,
            let intAmt = Int(amount) {
            amountLabel.text = String(format: "%@원", intAmt.commaValue).isOrEmptyCD
        }
        if let type = accountData.acctStatus {
            switch type {
            case "1":
                typeLabel.text = "입출금"
            case "2":
                typeLabel.text = "예금"
            case "3":
                typeLabel.text = "적금"
            default:
                typeLabel.text = "기타"
            }
        }
        if let open = accountData.openDate {
            openLabel.text = open.toDateFormatted.isOrEmptyCD
        }
        if let close = accountData.closeDate {
            closeLabel.text = close.toDateFormatted.isOrEmptyCD
        }
        memoLabel.text = accountData.memo
    }
    
    private func setHiddenButton() {
        let haveClose: Bool = data.acctStatus == "2" || data.acctStatus == "3"
        closeTitleLabel.isHidden = !haveClose
        closeLabel.isHidden = !haveClose
        
        memoTitleLabel.snp.remakeConstraints { (make) in
            var baseLabel: UILabel = openTitleLabel
            if haveClose {
                baseLabel = closeTitleLabel
            }
            make.top.equalTo(baseLabel.snp.bottom).offset(24)
            make.leading.equalTo(baseLabel)
        }
        
        memoTitleLabel.isHidden = !data.isHandWrite
        memoLabel.isHidden = !data.isHandWrite
        editButton.isHidden = !data.isHandWrite
        removeButton.isHidden = !data.isHandWrite
        view.layoutIfNeeded()
    }
    
}
