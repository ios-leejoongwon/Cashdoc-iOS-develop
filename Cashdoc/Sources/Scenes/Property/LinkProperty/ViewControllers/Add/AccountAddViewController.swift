//
//  AccountAddViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/13.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

import SnapKit

final class AccountAddViewController: CashdocViewController {
    
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
    private weak var accountTypeView: PropertyTFView!
    private weak var bankNameView: PropertyTFView!
    private weak var accountNameView: PropertyTFView!
    private weak var amountView: PropertyTFView!
    private weak var openView: PropertyTFView!
    private weak var closeView: PropertyTFView!
    private weak var memoView: PropertyTFView!
    private weak var removeButton: UIButton!
    private weak var saveButton: UIButton!
    
    // MARK: - Overridden: CashdocViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        configure(with: getModel)
        bindView()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func bindView() {
        Observable.combineLatest(accountTypeView.cdTF.rx.text.orEmpty,
                                 bankNameView.cdTF.rx.text.orEmpty,
                                 accountNameView.cdTF.rx.text.orEmpty,
                                 amountView.cdTF.rx.text.orEmpty)
            .map { (type, bankName, accountName, amount) -> Bool in
                let result: Bool = type.isNotEmpty && bankName.isNotEmpty && accountName.isNotEmpty && amount.isNotEmpty
                return result
        }
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
                                                  message: "선택하신 계좌 내역이 삭제됩니다.\n정말 삭제하시겠습니까?")
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
            guard let status: String = self.setStatus(with: self.accountTypeView.cdTF.text) else { return nil }
            guard let fCode: FCode = FCode.getFCode(fCodeName: self.bankNameView.cdTF.text ?? "") else { return nil }
            let open: String? = self.openView.cdTF.text?.replace(target: ".", withString: "")
            let close: String? = self.closeView.cdTF.text?.replace(target: ".", withString: "")
            let amount: String = self.removeAmountValue(self.amountView.cdTF.text ?? "")
            let object = CheckAllAccountInBankList()
            object.identity = self.getModel?.identity ?? UUID().uuidString
            object.acctStatus = status
            object.fCodeName = fCode.rawValue
            object.fCodeIndex = fCode.index
            object.acctKind = self.accountNameView.cdTF.text
            object.curBal = amount
            object.intCurBal = amount.toInt
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
        
        accountTypeView.cdTF.rx.tapGesture().skip(1).bind { [weak self] (_) in
            GlobalFunction.CDActionSheet("계좌종류", leftItems: ["입출금", "예금", "적금"]) { (_, name) in
                guard let self = self else { return }
                self.closeView.isHidden = name.contains("입출금")
                self.accountTypeView.cdTF.rxText(name)
            }
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
        
        accountNameView.cdTF.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            self.amountView.cdTF.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        memoView.cdTF.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            if self.saveButton.isEnabled {
                self.saveButton.sendActions(for: .touchUpInside)
            }
        }.disposed(by: disposeBag)
        
        accountNameView.cdTF.rx.text.orEmpty
            .map { $0[0..<15] }
            .bind(to: accountNameView.cdTF.rx.text)
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
    
    private func setStatus(with type: String?) -> String? {
        switch type {
        case "입출금":
            return "1"
        case "예금":
            return "2"
        case "적금":
            return "3"
        default:
            return nil
        }
    }
    
    private func configure(with model: CheckAllAccountInBankList?) {
        if let type = model?.acctStatus {
            switch type {
            case "1":
                accountTypeView.cdTF.text = "입출금"
            case "2":
                accountTypeView.cdTF.text = "예금"
                closeView.isHidden = false
            case "3":
                accountTypeView.cdTF.text = "적금"
                closeView.isHidden = false
            default:
                accountTypeView.cdTF.text = "기타"
            }
        }
        if let bank = model?.fCodeName {
            bankNameView.cdTF.text = bank
        }
        if let account = model?.acctKind {
            accountNameView.cdTF.text = account
        }
        if let amount = model?.curBal {
            amountView.cdTF.text = amount.commaValue + "원"
        }
        if let open = model?.openDate {
            openView.cdTF.text = open.toDateFormatted
        }
        if let close = model?.closeDate {
            closeView.cdTF.text = close.toDateFormatted
        }
        if let memo = model?.memo {
            memoView.cdTF.text = memo
        }
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        if getModel == nil {
            title = "계좌 추가"
        } else {
            title = "계좌 상세 수정"
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
        accountTypeView = PropertyTFView(type: .button, title: "계좌종류", placeHolder: "계좌종류를 선택해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        bankNameView = PropertyTFView(type: .button, title: "은행명", placeHolder: "은행을 선택해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        accountNameView = PropertyTFView(type: .textField, title: "계좌명", placeHolder: "계좌명을 입력해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        amountView = PropertyTFView(type: .textField, title: "현재잔액", placeHolder: "0원").then {
            $0.cdTF.keyboardType = .numberPad
            $0.cdTF.delegate = self
            stackView.addArrangedSubview($0)
        }
        openView = PropertyTFView(type: .button, title: "신규일", placeHolder: "선택해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
        closeView = PropertyTFView(type: .button, title: "만기일", placeHolder: "선택해 주세요.").then {
            $0.isHidden = true
            stackView.addArrangedSubview($0)
        }
        memoView = PropertyTFView(type: .textField, title: "메모", placeHolder: "메모할 사항이 있으면 입력해 주세요.").then {
            stackView.addArrangedSubview($0)
        }
    }
    
}

extension AccountAddViewController {
    private func removeAmountValue(_ text: String) -> String {
        return text.replace(target: "원", withString: "").replace(target: ",", withString: "")
    }
}

extension AccountAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == amountView.cdTF {
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
            
            let text = String(format: "%@%@", modifiedText, string)
            let resultText = String(format: "%@원", removeAmountValue(text)[0..<11].commaValue)
            textField.rxText(resultText)
            return false
        }
        return true
    }
}
