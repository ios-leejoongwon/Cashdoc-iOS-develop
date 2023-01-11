//
//  EasyAuthInputVC.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/14.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit

class EasyAuthInputVC: CashdocViewController, View {
    
    typealias Reactor = EasyAuthInputReactor
     
    private var authPurpose: EasyAuthPurpose = .none
    private var type: AuthType = .none
    private var Mobiletype: MobileType = .none
    private var name = ""
    private var phoneNum = ""
    private var birth = ""
    
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    private var nameTextField: UITextField!
    private var lbNameError: UILabel!
    private var birthTextField: UITextField!
    private var lbBirthError: UILabel!
    private var phoneTextField: UITextField!
    private var lbPhoneError: UILabel!
    
    private var btnSKT: UIButton!
    private var btnKT: UIButton!
    private var btnLGU: UIButton!
    private var lbMobileError: UILabel!
    private var lbAgreement00: UILabel!
    private var lbAgreement01: UILabel!
    private var check01: UIButton!
    private var check02: UIButton!
    private var arrow01: UIButton!
    private var arrow02: UIButton!
    private var agreementStackV: UIStackView!
    
    private let obvName = BehaviorRelay<String>(value: "")
    private let obvBirth = BehaviorRelay<String>(value: "")
    private let obvPhone = BehaviorRelay<String>(value: "")
    private let obvMobileType = BehaviorRelay<MobileType>(value: .none)
    private let obvTerms = BehaviorRelay<Bool>(value: false)
    
    private var confirmButton: UIButton!
    private var contentViewBottom: Constraint?
    private var keyHeight: CGFloat?
      
    init(authPurpose: EasyAuthPurpose, type: AuthType) {
        super.init(nibName: nil, bundle: nil)
        self.type = type
        self.authPurpose = authPurpose
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        self.reactor = EasyAuthInputReactor()
        requestAgreementInfo()
        setUserInfo()
    }
     
    private func setProperties() {
        title = "간편인증 요청"
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .yellowCw
        self.navigationController?.navigationBar.isTranslucent = true
        setSelector()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setSelector() {
        NotificationCenter.default.addObserver(self, selector: #selector(showWillKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideWillKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        let navibarHeight = topbarHeight + StatusBarSize.HEIGHT
        
        scrollView = UIScrollView().then {
            $0.isUserInteractionEnabled = true
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(navibarHeight)
                m.left.right.equalToSuperview()
                m.bottom.equalToSuperview().offset(-85)
            }
        }
        
        contentView = UIView().then {
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(32)
                m.left.equalToSuperview()
                m.width.equalTo(view.snp.width)
                m.bottom.equalToSuperview()
                contentViewBottom = m.bottom.equalToSuperview().constraint
            }
        }
        
        let VStack = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            contentView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview()
                m.left.right.equalToSuperview().inset(16)
            }
        }
        
        let vName = UIView().then {
            $0.backgroundColor = .clear
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(85)
                m.width.equalToSuperview()
            }
        }
        
        let lbName = UILabel().then {
            $0.textAlignment = .left
            $0.text = "이름*"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.blackCw
            vName.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.top.equalToSuperview()
            }
        }
        
        nameTextField = UITextField().then {
            $0.backgroundColor = .white
            $0.autocorrectionType = .no
            $0.placeholder = "이름 입력해 주세요."
            $0.textColor = .blackTwoCw
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.layer.cornerRadius = 4
            $0.keyboardType = .namePhonePad
            $0.returnKeyType = .next
            $0.clearButtonMode = .whileEditing
            $0.doneAccessory = true
            $0.delegate = self
            $0.highlighting.enable(normalBorderColor: .lineGray)
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            vName.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(lbName.snp.bottom).offset(8)
                m.left.right.equalToSuperview()
                m.height.equalTo(56)
            }
        }
        
        lbNameError = UILabel().then {
            $0.textAlignment = .left
            $0.text = "올바른 이름을 입력해 주세요."
            $0.setFontToMedium(ofSize: 12)
            $0.textColor = UIColor.redCw
            $0.isHidden = true
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
                m.width.equalToSuperview()
            }
        }
        
        let vBirth = UIView().then {
            $0.backgroundColor = .clear
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(85)
                m.width.equalToSuperview()
            }
        }
        
        let lbBirthday = UILabel().then {
            $0.textAlignment = .left
            $0.text = "생년월일*(예시 : 19850101)"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.blackCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            vBirth.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.left.right.equalToSuperview()
            }
        }
        
        birthTextField = UITextField().then {
            $0.backgroundColor = .white
            $0.autocorrectionType = .no
            $0.placeholder = "생년월일을 입력해 주세요."
            $0.textColor = .blackTwoCw
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.layer.cornerRadius = 4
            $0.keyboardType = .numberPad
            $0.returnKeyType = .next
            $0.clearButtonMode = .whileEditing
            $0.doneAccessory = true
            $0.delegate = self
            $0.highlighting.enable(normalBorderColor: .lineGray)
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            vBirth.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(lbBirthday.snp.bottom).offset(8)
                m.left.right.equalToSuperview()
                m.height.equalTo(56)
            }
        }
        
        lbBirthError = UILabel().then {
            $0.textAlignment = .left
            $0.text = "올바른 생년월일을 입력해 주세요."
            $0.setFontToMedium(ofSize: 12)
            $0.textColor = UIColor.redCw
            $0.isHidden = true
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
                m.width.equalToSuperview()
            }
        }
        let vMobileCarrier = UIView().then {
            $0.backgroundColor = .clear
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(85)
                m.width.equalToSuperview()
            }
        }
        
        let lbMobileCarrier = UILabel().then {
            $0.textAlignment = .left
            $0.text = "통신사*"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.blackCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            vMobileCarrier.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.left.right.equalToSuperview()
            }
        }
        
        let hStack = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .equalSpacing
            $0.alignment = .center
            $0.spacing = 8
            vMobileCarrier.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(56)
                m.top.equalTo(lbMobileCarrier.snp.bottom).offset(8)
                m.right.left.equalToSuperview()
            }
        }
        
        btnSKT = UIButton().then {
            $0.IBborderWidth = 0.5
            $0.IBborderColor = .lineGrayCw
            $0.titleLabel?.textAlignment = .center
            $0.setTitleColor(.brownishGray, for: .normal)
            $0.setTitleColor(.blueCw, for: .selected)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setTitle("SKT", for: .normal)
            $0.layer.cornerRadius = 1
            hStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(55)
                m.width.equalToSuperview().multipliedBy(0.3)
            }
        }
        
        btnKT = UIButton().then {
            $0.IBborderWidth = 0.5
            $0.IBborderColor = .lineGrayCw
            $0.titleLabel?.textAlignment = .center
            $0.setTitleColor(.brownishGray, for: .normal)
            $0.setTitleColor(.blueCw, for: .selected)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setTitle("KT", for: .normal)
            $0.layer.cornerRadius = 1
            hStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(55)
                m.width.equalToSuperview().multipliedBy(0.3)
            }
        }
        
        btnLGU = UIButton().then {
            $0.IBborderWidth = 0.5
            $0.IBborderColor = .lineGrayCw
            $0.titleLabel?.textAlignment = .center
            $0.setTitleColor(.brownishGray, for: .normal)
            $0.setTitleColor(.blueCw, for: .selected)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            $0.setTitle("LG U+", for: .normal)
            $0.layer.cornerRadius = 1
            hStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(55)
                m.width.equalToSuperview().multipliedBy(0.3)
            }
        }
        
        lbMobileError = UILabel().then {
            $0.textAlignment = .left
            $0.text = "통신사를 선택해 주세요."
            $0.setFontToMedium(ofSize: 12)
            $0.textColor = UIColor.redCw
            $0.isHidden = true
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
                m.width.equalToSuperview()
            }
        }
        
        let vPhone = UIView().then {
            $0.backgroundColor = .clear
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(85)
                m.width.equalToSuperview()
            }
        }
        let lbPhoneNum = UILabel().then {
            $0.textAlignment = .left
            $0.text = "휴대폰번호*"
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.blackCw
            $0.translatesAutoresizingMaskIntoConstraints = false
            vPhone.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.top.equalToSuperview()
            }
        }
        
        phoneTextField = UITextField().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.autocorrectionType = .no
            $0.placeholder = "- 없이 휴대폰번호 입력"
            $0.textColor = .blackTwoCw
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.layer.cornerRadius = 4
            $0.keyboardType = .phonePad
            $0.returnKeyType = .next
            $0.clearButtonMode = .whileEditing
            $0.doneAccessory = true
            $0.delegate = self
            $0.highlighting.enable(normalBorderColor: .lineGray)
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            vPhone.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(lbPhoneNum.snp.bottom).offset(8)
                m.left.right.equalToSuperview()
                m.height.equalTo(56)
            }
        }
        
        lbPhoneError = UILabel().then {
            $0.textAlignment = .left
            $0.text = "올바른 휴대폰번호를 입력해 주세요."
            $0.setFontToMedium(ofSize: 12)
            $0.textColor = UIColor.redCw
            $0.isHidden = true
            VStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(20)
                m.width.equalToSuperview()
            }
        }
        
        agreementStackV = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.alignment = .leading
            $0.spacing = 8
            contentView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.left.right.equalToSuperview().inset(24)
                m.height.equalTo(90)
                m.top.equalTo(lbPhoneError.snp.bottom).offset(28)
                m.bottom.equalToSuperview().offset(-50)
            }
        }
        
        _ = UILabel().then {
            $0.text = "건강 서비스를 위한 약관 동의"
            $0.setFontToBold(ofSize: 14)
            $0.textColor = .blackCw
            agreementStackV.addArrangedSubview($0)
        }
        
        let stackH00 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            agreementStackV.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalToSuperview()
            }
        }
          
        check01 = UIButton().then {
            $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
            $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(24)
            }
        }
        
        lbAgreement00 = UILabel().then {
            $0.text = "개인정보 수집·이용 동의(필수)"
            $0.textColor = .brownishGray
            $0.setFontToMedium(ofSize: 14)
            stackH00.addArrangedSubview($0)
        }
        
        arrow01 = UIButton().then {
            $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            $0.setContentCompressionResistancePriority(.required, for: .horizontal)
            $0.setImage(UIImage(named: "icArrow01StyleRightGray"), for: .normal)
            stackH00.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(22)
            }
        }
        
        let stackH01 = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            agreementStackV.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalToSuperview()
            }
        }
        
        check02 = UIButton().then {
            $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
            $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.width.equalTo(24)
            }
        }
        
        lbAgreement01 = UILabel().then {
            $0.text = "민감정보 수집·이용 동의(필수)"
            $0.textColor = .brownishGray
            $0.setFontToMedium(ofSize: 14)
            stackH01.addArrangedSubview($0)
        }
        
        arrow02 = UIButton().then {
            $0.setImage(UIImage(named: "icArrow01StyleRightGray"), for: .normal)
            stackH01.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(22)
            }
        }
        
        confirmButton = UIButton().then {
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setBackgroundColor(.grayCw, forState: .disabled)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .disabled)
            $0.setTitle("\(self.type.name()) 인증 요청", for: .normal)
            $0.isEnabled = false
            $0.addTarget(self, action: #selector(clickConfirm), for: .touchUpInside)
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(56)
                m.right.left.equalToSuperview().inset(16)
                m.bottom.equalTo(view.snp.bottomMargin).offset(-16)
            }
        }
        
       if type != .pass {
           vMobileCarrier.isHidden = true
       }
    }
    
    func bind(reactor: EasyAuthInputReactor) {
        Log.al("bind")
        obvTerms
            .distinctUntilChanged()
            .map { Reactor.Action.setAgreementState($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        obvName
            .distinctUntilChanged()
            .map { Reactor.Action.setName($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        obvPhone
            .distinctUntilChanged()
            .map { Reactor.Action.setPhone($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        obvBirth
            .distinctUntilChanged()
            .map { Reactor.Action.setBirth($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        obvMobileType
            .distinctUntilChanged()
            .map { Reactor.Action.clickMobileType($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        nameTextField.rx.text
            .compactMap { $0 }
            .distinctUntilChanged()
            .map { Reactor.Action.setName($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        birthTextField.rx.text
            .compactMap { $0 }
            .distinctUntilChanged()
            .map { Reactor.Action.setBirth($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text
            .compactMap { $0 }
            .distinctUntilChanged()
            .map { Reactor.Action.setPhone($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        if type == .pass {
            btnSKT.rx.tap
                .map { Reactor.Action.clickMobileType(.SKT) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            btnKT.rx.tap
                .map { Reactor.Action.clickMobileType(.KT) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            btnLGU.rx.tap
                .map { Reactor.Action.clickMobileType(.LGU) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        check01.rx.tap
            .map { self.check01.isSelected }
            .map { Reactor.Action.clickAgreement00($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        check02.rx.tap
            .map { self.check02.isSelected }
            .map { Reactor.Action.clickAgreement01($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        lbAgreement00.rx
            .tapGesture()
            .when(.recognized)
            .bind { _ in
                GlobalFunction.pushToWebViewController(title: "건강 개인정보 수집 및 이용", url: API.SENSITIVE_ESSENTIAL_URL, webType: .terms)
            }.disposed(by: disposeBag)
        
        lbAgreement01.rx
            .tapGesture()
            .when(.recognized)
            .bind { _ in
                GlobalFunction.pushToWebViewController(title: "건강 민감정보 수집 및 이용", url: API.SENSITIVE_URL, webType: .terms)
            }.disposed(by: disposeBag)
        
        arrow01.rx.tap.bind {
            GlobalFunction.pushToWebViewController(title: "건강 개인정보 수집 및 이용", url: API.SENSITIVE_ESSENTIAL_URL, webType: .terms)
        }.disposed(by: disposeBag)
        
        arrow02.rx.tap.bind {
            GlobalFunction.pushToWebViewController(title: "건강 민감정보 수집 및 이용", url: API.SENSITIVE_URL, webType: .terms)
        }.disposed(by: disposeBag)
        
        reactor.state.map(\.selectMobile)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] type in
                guard let self = self else { return }
                self.setMobileButtons(type: type)
            }).disposed(by: disposeBag)
        
        reactor.state.map(\.agreement00)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isAgree in
                guard let self = self else { return }
                self.check01.isSelected = isAgree
            }).disposed(by: disposeBag)
        
        reactor.state.map(\.agreement01)
            .distinctUntilChanged()
            .bind(onNext: { [weak self] isAgree in
                guard let self = self else { return }
                self.check02.isSelected = isAgree
            }).disposed(by: disposeBag)
        
        reactor.state.map(\.isEnable)
            .bind(onNext: { [weak self] isEnable in
                guard let self = self else { return }
                
                if isEnable {
                    if self.type == .pass, self.Mobiletype == .none {
                        self.confirmButton.isEnabled = false
                    } else {
                        self.confirmButton.isEnabled = true
                    }
                } else {
                    self.confirmButton.isEnabled = false
                }
            }).disposed(by: disposeBag)
         
    }
    
    private func setMobileButtons(type: MobileType) {
        self.Mobiletype = type
        switch type {
        case .SKT:
            btnSKT.isSelected = true
            btnSKT.IBborderColor = .blueCw
            btnKT.isSelected = false
            btnKT.IBborderColor = .lineGrayCw
            btnLGU.isSelected = false
            btnLGU.IBborderColor = .lineGrayCw
            
        case .KT:
            btnSKT.isSelected = false
            btnSKT.IBborderColor = .lineGrayCw
            btnKT.isSelected = true
            btnKT.IBborderColor = .blueCw
            btnLGU.isSelected = false
            btnLGU.IBborderColor = .lineGrayCw
            
        case .LGU:
            btnSKT.isSelected = false
            btnSKT.IBborderColor = .lineGrayCw
            btnKT.isSelected = false
            btnKT.IBborderColor = .lineGrayCw
            btnLGU.isSelected = true
            btnLGU.IBborderColor = .blueCw
        case .none:
            btnSKT.isSelected = false
            btnSKT.IBborderColor = .lineGrayCw
            btnKT.isSelected = false
            btnKT.IBborderColor = .lineGrayCw
            btnLGU.isSelected = false
            btnLGU.IBborderColor = .lineGrayCw
        }
    }
    
    private func setUserInfo() {
        if let userName = UserDefaults.standard.string(forKey: UserDefaultKey.kUserName.rawValue), !userName.isEmpty {
            obvName.accept(userName)
            self.nameTextField.text = userName
        }
        
        if let birth = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpBirth.rawValue), !birth.isEmpty {
            obvBirth.accept(birth)
            self.birthTextField.text = birth
        }
        
        if let telecomType = UserDefaults.standard.string(forKey: UserDefaultKey.kTelecomtype.rawValue), !telecomType.isEmpty {
            let type = Mobiletype.changeType(type: telecomType)
            obvMobileType.accept(type)
            self.setMobileButtons(type: type)
        }
        if let phoneNum = UserDefaults.standard.string(forKey: UserDefaultKey.kPhoneNumber.rawValue), !phoneNum.isEmpty {
            obvPhone.accept(phoneNum)
            self.phoneTextField.text = phoneNum
        }
    }
    
    private func validatePhoneNumber(_ phone: String) -> Bool {
        let PHONE_REGEX = "^\\s*(010|011|012|013|014|015|016|017|018|019)(-|\\)|\\s)*(\\d{3,4})(-|\\s)*(\\d{4})\\s*$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
    }
    
    @objc func clickConfirm() {
        guard let state = self.reactor?.currentState else { return }
        Log.al("state = \(state), self.name.count = \(self.name.count)")
        
        if state.name.count < 2 {
            self.nameTextField.IBborderColor = .redCw
            self.lbNameError.isHidden = false
            return
        } else {
            self.nameTextField.IBborderColor = .lineGrayCw
            self.lbNameError.isHidden = true
        }
        
        if state.birth.count != 8 {
            self.birthTextField.IBborderColor = .redCw
            self.lbBirthError.isHidden = false
            return
        } else {
            self.birthTextField.IBborderColor = .lineGrayCw
            self.lbBirthError.isHidden = true
        }
        
        if state.type == .pass {
            if self.Mobiletype == .none {
                self.lbMobileError.isHidden = false
                return
            } else {
                self.lbMobileError.isHidden = true
            }
        }
        
        if !self.validatePhoneNumber(state.phoneNum) {
            self.lbPhoneError.isHidden = false
            self.phoneTextField.IBborderColor = .redCw
            return
        } else {
            self.lbPhoneError.isHidden = true
            self.phoneTextField.IBborderColor = .lineGray
        }
        
        putAgreed()
        GlobalFunction.FirLog(string: "간편인증2단계_인증요청_클릭_iOS")
        let easyAuthWaiting = EasyAuthWaiting(authPurpose: self.authPurpose, type: self.type, name: state.name, birth: state.birth, phoneNum: state.phoneNum, mobileType: state.selectMobile)
        GlobalFunction.pushVC(easyAuthWaiting, animated: true)
    }
    
    func requestAgreementInfo() {
        let provider = CashdocProvider<UserSerivce>()
        provider.CDRequest(.getAgree) { json in
            Log.al("json = \(json)")
            let privacyInformationAgreed = json["result"]["healthServiceAgreed"].boolValue
            self.agreementStackV.isHidden = privacyInformationAgreed
            self.obvTerms.accept(privacyInformationAgreed)
        }
    }
    
    private func putAgreed() {
        let accountService = CashdocProvider<AccountService>()
        accountService.request(PutAccountModel.self, token: .putAccountAgreed(privacyInformationAgreed: nil, sensitiveInformationAgreed: nil, healthServiceAgreed: true))
            .subscribe(onSuccess: { _ in
                if let userModel = UserManager.shared.userModel {
                    var user = userModel
                    user.healthServiceAgreed = true
                    UserManager.shared.user.onNext(user)
                }
            }, onFailure: { error in
                Log.al("Error putAccount \(error)")
            })
            .disposed(by: disposeBag)
    }
}

extension EasyAuthInputVC: UITextFieldDelegate {
    
    @objc private func hideWillKeyboard(_ notification: NSNotification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        contentViewBottom?.update(offset: 0)
        view.layoutIfNeeded()
    }
    
    @objc private func showWillKeyboard(_ notification: NSNotification) {
        guard let info = notification.userInfo else { return }
        guard let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let contentInset = UIEdgeInsets( top: 0.0, left: 0.0, bottom: keyboardFrame.size.height, right: 0.0)
        scrollView.contentInset = contentInset
        contentViewBottom?.update(offset: keyboardFrame.size.height)
        view.layoutIfNeeded()
    }
    
    @objc private func didTapViewDismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        
        if let char = string.cString(using: String.Encoding.utf8) {
            let isBackSpace = strcmp(char, "\\b")
            if isBackSpace == -92 {
                return true
            }
        }
        
        switch textField {
        case birthTextField:
            return checkStringCount(count: 7, text: text)
        case phoneTextField:
            return checkStringCount(count: 10, text: text)
        default:
            return true
        }
    }
    
    private func checkStringCount(count: Int, text: String) -> Bool {
        if text.count > count {
            return false
        }
        return true
    }
    
}
