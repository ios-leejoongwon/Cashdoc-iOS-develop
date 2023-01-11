//
//  BirthPopupView.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/04/12.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import UIKit

protocol BirthDatePopupViewDelegate: NSObjectProtocol {
    func confirmClick(_ view: BirthDatePopupView, gender: String, birth: String)
    func openAgreement(isOpen: Bool, gender: Gender, birth: String, isAgree: Bool)
}

class BirthDatePopupView: CashdocViewController {
     
    private var backgroundView: UIView!
    private var titleLabel: UILabel!
    private var contentLabel: UILabel!
    private var maleButton: UIButton!
    private var femaleButton: UIButton!
    private var birthTextField: UITextField!
    private var confirmButton: UIButton!
    private var backButton: UIButton!
    private var arrowImageView: UIImageView!
    private var checkButton: UIButton!
    private var arrowImageButton: UIButton!
    private var agreementStack: UIStackView!
    
    private let ObvGender = BehaviorRelay<Bool>(value: false)
    private let ObvBirth = BehaviorRelay<Bool>(value: false)
    private let ObvTerms = BehaviorRelay<Bool>(value: false)
    
    private var keyboardhHeight: CGFloat = 216.0
    private var keyboardAnimationDuration: Double = 0.25
    private var keyboardAnimationOptions: UIView.AnimationOptions = UIView.AnimationOptions(rawValue: 7)
    private let datePickerView = DatePickerView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private var birth: String = ""
    private var isAgree: Bool = false
    private var genderValue: Gender = .none
     
    weak var delegate: BirthDatePopupViewDelegate?
    private var gender: Gender = .male {
        didSet {
            let regularFont: UIFont = .systemFont(ofSize: 16, weight: .regular)

            switch gender {
            case .none:
                maleButton.titleLabel?.font = regularFont
                femaleButton.titleLabel?.font = regularFont
                maleButton.backgroundColor = .white
                femaleButton.backgroundColor = .white
                maleButton.setTitleColor(.brownishGrayCw, for: .normal)
                femaleButton.setTitleColor(.brownishGrayCw, for: .normal)
                maleButton.layer.borderColor = UIColor.lineGrayCw.cgColor
                femaleButton.layer.borderColor = UIColor.lineGrayCw.cgColor
                ObvGender.accept(false)
            case .male:
                maleButton.titleLabel?.font = regularFont
                femaleButton.titleLabel?.font = regularFont
                maleButton.backgroundColor = .white
                femaleButton.backgroundColor = .white
                maleButton.setTitleColor(.blueCw, for: .normal)
                femaleButton.setTitleColor(.brownishGrayCw, for: .normal)
                maleButton.layer.borderColor = UIColor.blueCw.cgColor
                femaleButton.layer.borderColor = UIColor.lineGrayCw.cgColor
                ObvGender.accept(true)
            case .female:
                maleButton.titleLabel?.font = regularFont
                femaleButton.titleLabel?.font = regularFont
                maleButton.backgroundColor = .white
                femaleButton.backgroundColor = .white
                maleButton.setTitleColor(.brownishGrayCw, for: .normal)
                femaleButton.setTitleColor(.blueCw, for: .normal)
                maleButton.layer.borderColor = UIColor.lineGrayCw.cgColor
                femaleButton.layer.borderColor = UIColor.blueCw.cgColor
                ObvGender.accept(true)
            }
        }
    }
    
    private var birthDate: Date? {
        didSet {
            DispatchQueue.main.async {
                guard let birthDate = self.birthDate else {
                    self.birthTextField.text = nil
                    return
                }
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                self.birthTextField.text = dateFormatter.string(from: birthDate)
                self.birth = dateFormatter.string(from: birthDate)
            }
        }
    }
    
    init(gender: Gender, birth: String, isAgree: Bool) {
        super.init(nibName: nil, bundle: nil)
        Log.al("gender = \(gender)")
        self.birth = birth
        self.genderValue = gender
        self.isAgree = isAgree
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad() 
        setLayout()
        bindView()
        requestAgreementInfo()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        dismissKeyboard()
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func dismissView() {
        self.dismiss(animated: true)
    }
    
    func setupProperty() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }
    
    private func setLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        
        backgroundView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 4
            $0.clipsToBounds = true
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(300)
                m.height.equalTo(427)
                m.center.equalToSuperview()
            }
        }
        
        titleLabel = UILabel().then {
            $0.textAlignment = .center
            $0.text = "용돈퀴즈 풀고\n포인트 받아가세요!😊" //캐시 -> 포인트
            $0.numberOfLines = 2
            $0.setFontToMedium(ofSize: 24)
            $0.textColor = UIColor.blackCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(backgroundView.snp.top).offset(48)
                m.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        contentLabel = UILabel().then {
            $0.textAlignment = .center
            $0.numberOfLines = 0
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGrayCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.text = "성별과 생년월일을 알려주세요. (최초 1회)"
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(titleLabel.snp.bottom).offset(14)
                m.centerX.equalToSuperview()
            }
        }
        
        femaleButton = UIButton(type: .system).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitle("여자", for: .normal)
            $0.setTitleColor(.blackTwoCw, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            $0.backgroundColor = .white
            $0.layer.cornerRadius = 1
            $0.layer.borderWidth = 1
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(120)
                m.height.equalTo(48)
                m.top.equalTo(contentLabel.snp.bottom).offset(32)
                m.leading.equalTo(backgroundView.snp.leading).offset(16)
            }
        }
        
        maleButton = UIButton(type: .system).then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setTitle("남자", for: .normal)
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            $0.backgroundColor = .blackTwoCw
            $0.layer.cornerRadius = 1
            $0.layer.borderWidth = 1
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(120)
                m.height.equalTo(48)
                m.top.equalTo(femaleButton.snp.top)
                m.trailing.equalTo(backgroundView.snp.trailing).offset(-16)
            }
        }
        
        birthTextField = UITextField().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.delegate = self
            $0.backgroundColor = .white
            $0.autocorrectionType = .no
            $0.attributedPlaceholder = NSAttributedString(string: "생년월일을 선택해 주세요.", attributes: [.foregroundColor: UIColor.brownishGrayCw, .font: UIFont.systemFont(ofSize: 16, weight: .regular)])
            $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.layer.cornerRadius = 1
            $0.layer.borderWidth = 1
            $0.clearButtonMode = .whileEditing
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            if self.birth.isEmpty {
                $0.textColor = .blackTwoCw
                $0.layer.borderColor = UIColor.lineGrayCw.cgColor
            } else {
                $0.layer.borderColor = UIColor.blueCw.cgColor
                $0.textColor = .blueCw
            }
            $0.text = self.birth
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(48)
                m.top.equalTo(maleButton.snp.bottom).offset(16)
                m.leading.equalTo(backgroundView.snp.leading).offset(16)
                m.trailing.equalTo(backgroundView.snp.trailing).offset(-16)
            }
        }
         
        arrowImageView = UIImageView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.image = UIImage(named: "icArrow01StyleDownGray")
            $0.backgroundColor = UIColor.clear
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(24)
                m.centerY.equalTo(birthTextField.snp.centerY)
                m.trailing.equalTo(birthTextField.snp.trailing).offset(-16)
            }
        }
        
        agreementStack = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.equalToSuperview().inset(16)
                m.height.equalTo(45)
                m.top.equalTo(birthTextField.snp.bottom).offset(13)
            }
        }
        
        checkButton = UIButton().then {
            $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
            $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
            $0.isSelected = self.isAgree
            agreementStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(24)
            }
        }
        
        _ = UILabel().then {
            $0.text = "개인정보 수집 ・ 이용 동의"
            $0.textColor = .brownishGray
            $0.setFontToMedium(ofSize: 14)
            agreementStack.addArrangedSubview($0)
        }
        arrowImageButton = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleRightGray"), for: .normal)
            agreementStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
            }
        }
        
        confirmButton = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
            $0.setBackgroundColor(UIColor.fromRGB(246, 246, 246), forState: .disabled)
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.veryLightPinkCw, for: .disabled)
            $0.setTitle("정답 맞추러가기", for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.layer.cornerRadius = 4
            $0.isEnabled = false
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(56)
                m.bottom.equalTo(backgroundView.snp.bottom).offset(-16)
                m.leading.equalTo(backgroundView.snp.leading).offset(16)
                m.trailing.equalTo(backgroundView.snp.trailing).offset(-16)
            }
        }
        
        backButton = UIButton().then {
            $0.setImage(UIImage(named: "icCloseBlack"), for: .normal)
            backgroundView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.height.equalTo(24)
                m.trailing.top.equalToSuperview().inset(16)
            }
        }
        
        datePickerView.delegate = self
        reloadData()
    }

    private func bindView() {
        maleButton.rx.tap.bind(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.maleButtonDidClicked()
        }).disposed(by: disposeBag)
        
        femaleButton.rx.tap.bind(onNext: { [weak self] (_) in
            guard let self = self else { return }
            self.femaleButtonDidClicked()
        }).disposed(by: disposeBag)
         
        backButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.delegate?.openAgreement(isOpen: false, gender: .none, birth: "", isAgree: false)
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        checkButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.checkButton.isSelected = !self.checkButton.isSelected
            self.ObvTerms.accept(self.checkButton.isSelected)
        }.disposed(by: disposeBag)
        
        arrowImageButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.delegate?.openAgreement(isOpen: true, gender: self.gender, birth: self.birth, isAgree: self.isAgree)
            self.dismiss(animated: false)
            GlobalFunction.pushToWebViewController(title: "개인정보 수집 및 이용 동의(선택)", url: API.MORE_TERMS_SELECT_URL, webType: .terms)
            
        }.disposed(by: disposeBag)
        
        confirmButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMdd"
            var birthDate = "0"
            if let birth = self.birthDate {
                birthDate = dateFormatter.string(from: birth)
            }
            
            self.delegate?.confirmClick(self, gender: self.gender.rawValue, birth: birthDate)
        }.disposed(by: disposeBag)
        
        Observable.combineLatest(ObvGender, ObvBirth, ObvTerms).subscribe { [weak self] (isGender, isBirth, isTerms) in
            guard let self = self else { return }
            let isValid = isGender && isBirth && isTerms
            if isValid {
                self.confirmButton.isEnabled = true
            } else {
                self.confirmButton.isEnabled = false
            }
        }.disposed(by: disposeBag)
    }
    
    private func reloadData() {
        // 무조건 디폴트값
        self.gender = self.genderValue
    }
     
    private func showDatePickerView() {
        self.view.addSubview(datePickerView)
        datePickerView.snp.makeConstraints { m in
            m.leading.trailing.bottom.top.equalToSuperview()
            
        }
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard let getFrameEnd = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
            var bottom = getFrameEnd.cgRectValue.height
            guard let window = UIApplication.shared.keyWindow else {return}
            bottom -= window.safeAreaInsets.bottom
              
            keyboardhHeight = bottom
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            guard let animationRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
            keyboardAnimationDuration = duration
            keyboardAnimationOptions = UIView.AnimationOptions(rawValue: animationRaw)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        if let userInfo = notification.userInfo {
            guard let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            guard let animationRaw = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }
            keyboardAnimationDuration = duration
            keyboardAnimationOptions = UIView.AnimationOptions(rawValue: animationRaw)
        }
    }
    
    private func maleButtonDidClicked() {
        gender = .male
    }
     
    private func femaleButtonDidClicked() {
        gender = .female
    }
    
    private func requestAgreementInfo() {
        let provider = CashdocProvider<UserSerivce>()
        provider.CDRequest(.getAgree) { json in
            Log.al("json = \(json)")
            let privacyInformationAgreed = json["result"]["privacyInformationAgreed"].boolValue
            self.agreementStack.isHidden = privacyInformationAgreed
            self.checkButton.isSelected = privacyInformationAgreed
            self.ObvTerms.accept(self.checkButton.isSelected)
        }
    }
}

// MARK: - UITextViewDelegate

extension BirthDatePopupView: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        guard textField == birthTextField else {return true}
        Log.al("textFieldShouldBeginEditing")
        view.endEditing(true)
        dismissKeyboard()
        showDatePickerView()
        return false
    }
    
}

// MARK: - DatePickerViewDelegate

extension BirthDatePopupView: DatePickerViewDelegate {
    
    func datePickerViewDidDismissed(_ view: DatePickerView) {
        dismissKeyboard()
    }
    
    func datePickerView(_ view: DatePickerView, didClickedOkButton date: Date) {
        birthDate = date
        
        birthTextField.layer.borderColor = UIColor.blueCw.cgColor
        birthTextField.textColor = .blueCw
        ObvBirth.accept(true)
    }
}
