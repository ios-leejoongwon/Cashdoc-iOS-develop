//
//  LoanAddViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

import SnapKit

final class LoanAddViewController: CashdocViewController {
    
    // MARK: - Properties
    
    var getModel: CheckAllAccountInBankList?
    
    private var bankSectionoModel: [CDCVSectionModel] = []
    private weak var betweenButtonsConstraint: Constraint!
    private weak var saveButtonBottom: Constraint!
    
    // MARK: - UI Components
    
    private weak var scrollView: UIScrollView!
    private weak var contentView: UIView!
    private weak var stackView: UIStackView!
    private weak var descTopView: UIView!
    private weak var descTopLabel: UILabel!
    
    private weak var bankNameView: PropertyTFView!
    private weak var loanNameView: PropertyTFView!
    private weak var curBalView: PropertyTFView!
    private weak var loanBalView: PropertyTFView!
    private weak var rateView: PropertyTFView!
    private weak var openView: PropertyTFView!
    private weak var closeView: PropertyTFView!
    private weak var memoView: PropertyTFView!
    private weak var removeButton: UIButton!
    private weak var saveButton: UIButton!
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        configure()
        bindView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bindView() {
        Observable.combineLatest(bankNameView.cdTF.rx.text.orEmpty,
                                 loanNameView.cdTF.rx.text.orEmpty,
                                 curBalView.cdTF.rx.text.orEmpty,
                                 loanBalView.cdTF.rx.text.orEmpty)
            .map({ [weak self] (bankName, loanName, curBal, loanBal) -> Bool in
                return bankName.isNotEmpty &&
                    loanName.isNotEmpty &&
                    self?.removeAmountValue(curBal).isNotEmpty ?? false &&
                    self?.removeAmountValue(loanBal).isNotEmpty ?? false
            })
            .bind(to: saveButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        if let data = self.getModel {
            removeButton.rx.tap
                .map { data.identity }
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
        saveButton.rx.tap.map({ [weak self] (_) -> CheckAllAccountInBankList? in
            guard let self = self else { return nil }
            guard let fCode: FCode = FCode.getFCode(fCodeName: self.bankNameView.cdTF.text ?? "") else { return nil }
            let rate: String? = self.rateView.cdTF.text?.replace(target: "%", withString: "")
            let open: String? = self.openView.cdTF.text?.replace(target: ".", withString: "")
            let close: String? = self.closeView.cdTF.text?.replace(target: ".", withString: "")
            let curBal: String = self.removeAmountValue(self.curBalView.cdTF.text ?? "")
            let object = CheckAllAccountInBankList()
            object.identity = self.getModel?.identity ?? UUID().uuidString
            object.acctStatus = "6"
            object.fCodeName = fCode.rawValue
            object.fCodeIndex = fCode.index
            object.acctKind = self.loanNameView.cdTF.text
            object.loanCurBal = self.removeAmountValue(self.curBalView.cdTF.text ?? "")
            object.intLoanCurBal = curBal.toInt
            object.loanBal = self.removeAmountValue(self.loanBalView.cdTF.text ?? "")
            object.interastRate = rate
            object.openDate = open
            object.closeDate = close
            object.memo = self.memoView.cdTF.text ?? ""
            object.isHandWrite = true
            return object
        })
            .filterNil()
            .bind { [weak self] (object) in
                AccountListRealmProxy().append(object, completion: {
                    guard let self = self else { return }
                    if self.getModel != nil {
                        GlobalDefine.shared.curNav?.popViewController(animated: true)
                    } else {
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    }
                })
        }.disposed(by: disposeBag)
        
        bankNameView.cdTF.rx.tapGesture().skip(1).bind { [weak self] (_) in
            guard let self = self else { return }
            GlobalFunction.CDCollectionViewActionSheet("은행명", sectionList: self.bankSectionoModel) { [weak self] (_, name) in
                guard let self = self else { return }
                self.bankNameView.cdTF.rxText(name)
            }
        }.disposed(by: disposeBag)
        
        openView.cdTF.rx.tapGesture().skip(1)
            .map { [weak self] _ in self?.openView.cdTF.text }
            .bind { [weak self] (text) in
                guard let text = text == "-" ? "" : text else { return }
                GlobalFunction.CDDateActionSheet(text) { [weak self] (date) in
                    guard let self = self else { return }
                    self.openView.cdTF.text = date
                    if !self.compareDate(open: date, close: self.closeView.cdTF.text ?? "") {
                        self.closeView.cdTF.text = nil
                    }
                }
        }.disposed(by: disposeBag)
        
        closeView.cdTF.rx.tapGesture().skip(1)
            .map { [weak self] _ in self?.closeView.cdTF.text }
            .bind { [weak self] (text) in
                guard let text = text == "-" ? "" : text else { return }
                GlobalFunction.CDDateActionSheet(text) { [weak self] (date) in
                    guard let self = self else { return }
                    self.closeView.cdTF.text = date
                    if !self.compareDate(open: self.openView.cdTF.text ?? "", close: date) {
                        self.openView.cdTF.text = nil
                    }
                }
        }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (height) in
            guard let self = self else { return }
            self.saveButtonBottom.update(inset: height + 16)
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        loanNameView.cdTF.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            self.curBalView.cdTF.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        memoView.cdTF.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            if self.saveButton.isEnabled {
                self.saveButton.sendActions(for: .touchUpInside)
            }
        }.disposed(by: disposeBag)
        
        loanNameView.cdTF.rx.text.orEmpty
            .map { $0[0..<15] }
            .bind(to: loanNameView.cdTF.rx.text)
            .disposed(by: disposeBag)
        
        memoView.cdTF.rx.text.orEmpty
            .map { $0[0..<30] }
            .bind(to: memoView.cdTF.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private
    
    private func compareDate(open: String, close: String) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let s: Date = dateFormatter.date(from: open) ?? Date()
        let e: Date = dateFormatter.date(from: close) ?? Date()
        if s > e {
            return false
        }
        return true
    }
    
    private func configure() {
        if let bank = getModel?.fCodeName {
            bankNameView.cdTF.text = bank
        }
        if let name = getModel?.acctKind {
            loanNameView.cdTF.text = name
        }
        if let curBal = getModel?.loanCurBal {
            curBalView.cdTF.text = curBal.commaValue + "원"
        }
        if let loanBal = getModel?.loanBal {
            loanBalView.cdTF.text = loanBal.commaValue + "원"
        }
        if let loanBal = getModel?.enbBal {
            loanBalView.cdTF.text = loanBal.commaValue + "원"
        }
        if let rate = getModel?.interastRate {
            rateView.cdTF.text = rate + "%"
        }
        if let open = getModel?.openDate {
            openView.cdTF.text = open.toDateFormatted
        }
        if let close = getModel?.closeDate {
            closeView.cdTF.text = close.toDateFormatted
        }
        if let memo = getModel?.memo {
            memoView.cdTF.text = memo
        }
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        if getModel == nil {
            title = "대출 추가"
        } else {
            title = "대출 상세 수정"
        }
        
        for fCode in FCode.allCases where fCode.type == .은행 {
            bankSectionoModel.append(.init(image: fCode.image ?? "", name: fCode.rawValue))
        }
        scrollView = UIScrollView().then {
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.leading.trailing.equalToSuperview()
            }
        }
        removeButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.layer.borderColor = UIColor.blackCw.cgColor
            $0.layer.borderWidth = 1
            $0.clipsToBounds = true
            $0.setTitle("삭제", for: .normal)
            $0.setTitleColor(.blackCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.titleLabel?.textAlignment = .center
            view.addSubview($0)
            $0.snp.makeConstraints {
                $0.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(16)
                $0.leading.equalToSuperview().inset(16)
                $0.height.equalTo(56)
                saveButtonBottom = $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16).constraint
                if getModel == nil {
                    $0.width.equalTo(0)
                }
            }
        }
        saveButton = UIButton().then {
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            $0.setBackgroundColor(.whiteCw, forState: .disabled)
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitleColor(.blackCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.titleLabel?.textAlignment = .center
            $0.setTitle("저장", for: .normal)
            $0.isEnabled = false
            view.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.top.greaterThanOrEqualTo(scrollView.snp.bottom).offset(16)
                betweenButtonsConstraint = make.leading.equalTo(removeButton.snp.trailing).offset(8).constraint
                make.trailing.equalToSuperview().inset(16)
                make.height.equalTo(56)
                saveButtonBottom = make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16).constraint
                if getModel != nil {
                    make.width.equalTo(removeButton)
                    betweenButtonsConstraint.update(offset: 8)
                } else {
                    betweenButtonsConstraint.update(offset: 0)
                }
            }
        }
        contentView = UIView().then {
            scrollView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.width.equalToSuperview()
                make.height.equalToSuperview().priority(.low)
            }
        }
        stackView = UIStackView().then {
            $0.axis = .vertical
            $0.alignment = .fill
            $0.distribution = .fill
            $0.spacing = 16
            contentView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
        descTopView = UIView().then {
            $0.backgroundColor = .grayTwoCw
            $0.clipsToBounds = true
            stackView.addArrangedSubview($0)
            $0.snp.makeConstraints { (make) in
                make.height.equalTo(50)
            }
        }
        descTopLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownishGrayCw
            $0.textAlignment = .center
            $0.text = "직접 작성한 내용은 재설치, 로그아웃 시 복원이 불가능합니다."
            descTopView.addSubview($0)
            $0.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
        }
        bankNameView = PropertyTFView(type: .button, title: "은행명", placeHolder: "은행을 선택해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        loanNameView = PropertyTFView(type: .textField, title: "대출명", placeHolder: "대출명을 입력해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        curBalView = PropertyTFView(type: .textField, title: "현재잔액", placeHolder: "0원").then {
            $0.cdTF.keyboardType = .numberPad
            $0.cdTF.delegate = self
            stackView.addArrangedSubview($0)
        }
        loanBalView = PropertyTFView(type: .textField, title: "대출금", placeHolder: "0원").then {
            $0.cdTF.keyboardType = .numberPad
            $0.cdTF.delegate = self
            stackView.addArrangedSubview($0)
        }
        rateView = PropertyTFView(type: .textField, title: "이자율", placeHolder: "0.00%").then {
            $0.cdTF.keyboardType = .decimalPad
            $0.cdTF.delegate = self
            stackView.addArrangedSubview($0)
        }
        openView = PropertyTFView(type: .button, title: "개시일", placeHolder: "선택해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        closeView = PropertyTFView(type: .button, title: "만기일", placeHolder: "선택해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        memoView = PropertyTFView(type: .textField, title: "메모", placeHolder: "메모할 사항이 있으면 입력해주세요.").then {
            stackView.addArrangedSubview($0)
        }
    }
    
}

extension LoanAddViewController {
    private func removeAmountValue(_ text: String) -> String {
        return text.replace(target: "원", withString: "").replace(target: ",", withString: "")
    }
}

extension LoanAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard var modifiedText = textField.text else { return true }
        // placeHolder 처리
        if modifiedText.isEmpty, string.isEmpty {
            return true
        }
        if string.isBackspace {
            modifiedText = String(modifiedText.dropLast(2))
            // placeHolder 처리
            if modifiedText.isEmpty {
                textField.text = ""
                return true
            }
        }
        if textField == curBalView.cdTF || textField == loanBalView.cdTF {
            let text = String(format: "%@%@", modifiedText, string)
            let resultText = String(format: "%@원", removeAmountValue(text)[0..<11].commaValue)
            textField.rxText(resultText)
            return false
        } else if textField == rateView.cdTF {
            let resultText = String(format: "%@%@", modifiedText, string).replace(target: "%", withString: "")
            textField.text = resultText[0..<6] + "%"
            return false
        }
        return true
    }
}
