//  EtcAddViewController.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/09.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

import SnapKit

final class EtcAddViewController: CashdocViewController {
    
    // MARK: - Properties
    
    private var getModel: EtcPropertyList?
    private weak var betweenButtonsConstraint: Constraint!
    private weak var saveButtonBottom: Constraint!
    
    // MARK: - UI Components
    
    private weak var scrollView: UIScrollView!
    private weak var contentView: UIView!
    private weak var stackView: UIStackView!
    private weak var descTopView: UIView!
    private weak var descTopLabel: UILabel!
    private weak var nickNameView: PropertyTFView!
    private weak var balanceView: PropertyTFView!
    private weak var memoView: PropertyTFView!
    private weak var removeButton: UIButton!
    private weak var saveButton: UIButton!
    
    // MARK: - Overridden: CashdocViewController
    
    init(data: EtcPropertyList?) {
        self.getModel = data
        super.init(nibName: nil, bundle: nil)
        setProperties()
        configure(with: getModel)
        bindView(with: data)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bindView(with data: EtcPropertyList?) {
        Observable.combineLatest(nickNameView.cdTF.rx.text.orEmpty,
                                 balanceView.cdTF.rx.text.orEmpty)
            .map { (name, balance) -> Bool in
                let result = name.isNotEmpty && balance.isNotEmpty
                return result
        }
        .bind(to: saveButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        if let data = data {
            removeButton.rx.tap
                .map { data.id }
                .bind { [weak self] (id) in
                    guard let self = self else { return }
                    GlobalFunction.getAlertController(vc: self,
                                                      title: "삭제",
                                                      message: "선택하신 기타 자산 내역이 삭제됩니다.\n정말 삭제하시겠습니까?")
                        .bind(onNext: { (isOk) in
                            guard isOk else { return }
                            EtcPropertyRealmProxy().delete(id: id)
                            GlobalFunction.CDPopToRootViewController(animated: true)
                        })
                        .disposed(by: self.disposeBag)
            }.disposed(by: disposeBag)
        }
        
        saveButton.rx.tap
            .map({ [weak self] (_) -> EtcPropertyList? in
                guard let self = self else { return nil }
                let object = EtcPropertyList()
                object.id = self.getModel?.id ?? UUID().uuidString
                object.nickName = self.nickNameView.cdTF.text ?? ""
                object.balance = self.removeAmountValue(self.balanceView.cdTF.text ?? "").toInt
                object.memo = self.memoView.cdTF.text ?? ""
                return object
            })
            .filterNil()
            .bind { [weak self] (object) in
                EtcPropertyRealmProxy().append(object, completion: {
                    guard let self = self else { return }
                    if self.getModel != nil {
                        GlobalDefine.shared.curNav?.popViewController(animated: true)
                    } else {
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    }
                })
        }.disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] (height) in
            guard let self = self else { return }
            self.saveButtonBottom.update(inset: height + 16)
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        nickNameView.cdTF.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            self.balanceView.cdTF.becomeFirstResponder()
        }.disposed(by: disposeBag)
        
        memoView.cdTF.rx.controlEvent(.editingDidEndOnExit).bind { [weak self] (_) in
            guard let self = self else { return }
            if self.saveButton.isEnabled {
                self.saveButton.sendActions(for: .touchUpInside)
            }
        }.disposed(by: disposeBag)
        
        nickNameView.cdTF.rx.text.orEmpty
            .map { $0[0..<15] }
            .bind(to: nickNameView.cdTF.rx.text)
            .disposed(by: disposeBag)
        
        memoView.cdTF.rx.text.orEmpty
            .map { $0[0..<30] }
            .bind(to: memoView.cdTF.rx.text)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private
    
    private func configure(with model: EtcPropertyList? = nil) {
        if let name = model?.nickName {
            nickNameView.cdTF.text = name
        }
        if let value = model?.balance {
            let balance = value.commaValue + "원"
            balanceView.cdTF.text = balance
        }
        if let memo = model?.memo {
            memoView.cdTF.text = memo
        }
    }
    
    private func setProperties() {
        view.backgroundColor = .white
        if getModel == nil {
            title = "기타 자산 추가"
        } else {
            title = "기타 자산 수정"
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
        nickNameView = PropertyTFView(type: .textField, title: "별칭", placeHolder: "별칭을 입력해주세요.").then {
            stackView.addArrangedSubview($0)
        }
        balanceView = PropertyTFView(type: .textField, title: "보유잔액", placeHolder: "0원").then {
            $0.cdTF.keyboardType = .numberPad
            $0.cdTF.delegate = self
            stackView.addArrangedSubview($0)
        }
        memoView = PropertyTFView(type: .textField, title: "메모", placeHolder: "메모할 사항이 있으면 입력해주세요.").then {
            stackView.addArrangedSubview($0)
        }
    }
}

extension EtcAddViewController {
    private func removeAmountValue(_ text: String) -> String {
        return text.replace(target: "원", withString: "").replace(target: ",", withString: "")
    }
}

extension EtcAddViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == balanceView.cdTF {
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
