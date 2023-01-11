//
//  ShopSMSAuthViewController.swift
//  Cashdoc
//
//  Created by Sangbeom Han on 09/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa
import SnapKit

final class SmsAuthViewController: CashdocViewController {
    
    // MARK: - Constants
    
    private struct Const {
        static let authCount = 120
        static let authButtonEnableCount = 113
    }
    
    // MARK: - NSLayoutConstraints
    
    private var confirmButtonBottom: Constraint?
    
    // MARK: - Properties
    
    var phoneNumber = String()
    private var authSecond = Const.authCount
    private var timer: Timer?
    var viewModel: AuthViewModel!
    
    // MARK: - UI Components
    
    private var contentView: UIView!
    private var scrollView: UIScrollView!
    private var phoneTitleLabel: UILabel!
    private var phoneTextField: UITextField!
    private var authButton: UIButton!
    private var confirmButton: UIButton!
    private var authCodeView: UIView!
    private var authCodeTextField: UITextField!
    private var authDescriptionLabel: UILabel!
    private var authCodeTimerLabel: UILabel!
    private var descriptionLabel: UILabel!
    private var checkButton: UIButton!
    private var arrowImageButton: UIButton!
    private var agreementStack: UIStackView!
    
    private let obvConfirmButton = BehaviorRelay<Bool>(value: false)
    private let obvTerms = BehaviorRelay<Bool>(value: false)
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: BaseViewController
    
    override var backButtonTitleHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setProperties()
        setSelector()
        bindView()
        requestAgreementInfo()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        timer?.invalidate()
        timer = nil

    }
    
    private func setupView() {
        confirmButton = UIButton().then {
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setBackgroundColor(.sunFlowerYellowClick, forState: .highlighted)
            $0.setBackgroundColor(.fromRGB(216, 216, 216), forState: .disabled)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .disabled)
            $0.setTitle("인증 완료 및 다음 단계 이동", for: .normal)
            $0.isEnabled = false
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.right.left.equalToSuperview().inset(16)
                m.height.equalTo(45)
                confirmButtonBottom = m.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).constraint
            }
        }
        
        contentView = UIView().then {
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                m.right.left.equalToSuperview()
                m.bottom.equalTo(confirmButton.snp.top)
            }
        }
         
        let vStack = UIStackView().then {
            $0.axis = .vertical
            $0.distribution = .fill
            $0.spacing = 10
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.bottom.equalTo(confirmButton.snp.top).offset(-16)
                m.right.left.equalToSuperview().inset(24)
            }
        }
         
        agreementStack = UIStackView().then {
            $0.axis = .horizontal
            $0.distribution = .fill
            $0.alignment = .center
            $0.spacing = 8
            vStack.addArrangedSubview($0)
            $0.snp.makeConstraints { m in
//                m.left.right.equalToSuperview().inset(24)
                m.height.equalTo(45)
//                m.bottom.equalTo(descriptionLabel.snp.top).offset(-10)
            }
        }
        
        checkButton = UIButton().then {
            $0.setImage(UIImage(named: "icCheckBoxEnabled"), for: .selected)
            $0.setImage(UIImage(named: "icCheckBoxDefault"), for: .normal)
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
        
        descriptionLabel = UILabel().then {
            $0.setFontToRegular(ofSize: 14)
            $0.textColor = .blackTwo
            let text = NSMutableAttributedString(string: "안내사항\n\n", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .bold), .foregroundColor: UIColor.blackTwo])
            text.append(NSAttributedString(string: "- 쇼핑에 안전한 캐시 사용을 위해 최초 1회에 한 해 본인인증을 \n 진행합니다.\n- 최초 1회만 인증하면 계속 편하게 쇼핑을 이용하실 수 있습니다.\n- 본인인증 문자는 1일 최대 3회까지 받을 수 있습니다.", attributes: [.font: UIFont.systemFont(ofSize: 14, weight: .thin), .foregroundColor: UIColor.blackTwo]))
            $0.numberOfLines = 10
            $0.attributedText = text
            $0.textAlignment = .left
            vStack.addArrangedSubview($0)
        }
        
        scrollView = UIScrollView().then {
            $0.showsVerticalScrollIndicator = false
            $0.alwaysBounceVertical = true
            $0.keyboardDismissMode = .onDrag
            contentView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.size.width.height.equalToSuperview()
                m.top.left.equalToSuperview()
//                m.bottom.equalTo(authCodeView.snp.bottom)
            }
            
        }
        
        phoneTitleLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToBold(ofSize: 16)
            $0.textColor = .blackTwoCw
            $0.text = "휴대전화번호"
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(contentView.snp.top).offset(33)
                m.left.equalTo(contentView.snp.left).offset(33)
            }
        }
        
        authButton = UIButton().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setBackgroundColor(.blackTwoCw, forState: .normal)
            $0.setBackgroundColor(.blackTwoClick, forState: .highlighted)
            $0.setBackgroundColor(.fromRGB(216, 216, 216), forState: .disabled)
            $0.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
            $0.setTitleColor(.white, for: .normal)
            $0.setTitle("인증번호 받기", for: .normal)
            $0.layer.cornerRadius = 4
            $0.isEnabled = false
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(phoneTitleLabel.snp.bottom).offset(8)
                m.right.equalTo(contentView.snp.right).offset(-32)
                m.width.equalTo(110)
                m.height.equalTo(48)
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
            $0.highlighting.enable(normalBorderColor: .lineGray)
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(phoneTitleLabel.snp.bottom).offset(8)
                m.left.equalTo(contentView.snp.left).offset(32)
                m.right.equalTo(authButton.snp.left).offset(-4)
                m.height.equalTo(48)
            }
        }
        
        authCodeView = UIView().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .clear
            $0.isHidden = true
            scrollView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(phoneTextField.snp.bottom).offset(12)
                m.left.right.equalTo(contentView).inset(32)
//                m.bottom.equalTo(authCodeTimerLabel.snp.bottom).offset(12)
            }
        }
        
        authCodeTextField = UITextField().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.backgroundColor = .white
            $0.autocorrectionType = .no
            $0.placeholder = "인증번호를 입력해주세요."
            $0.textColor = .blackTwoCw
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.layer.cornerRadius = 4
            $0.keyboardType = .numberPad
            $0.returnKeyType = .done
            $0.clearButtonMode = .whileEditing
            $0.highlighting.enable(normalBorderColor: .lineGray)
            
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 48))
            $0.leftView = paddingView
            $0.leftViewMode = .always
            authCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.right.left.equalToSuperview()
                m.height.equalTo(56)
            }
        }
        authDescriptionLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 13)
            $0.textColor = .fromRGB(155, 154, 155)
            $0.text = "인증번호가 발송되었습니다."
            $0.textAlignment = .center
            authCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(authCodeTextField.snp.bottom).offset(24)
                m.right.left.equalToSuperview()
            }
        }
        authCodeTimerLabel = UILabel().then {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.setFontToRegular(ofSize: 15)
            $0.textColor = .azureBlue
            $0.textAlignment = .center
            authCodeView.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(authDescriptionLabel.snp.bottom).offset(8)
                m.right.left.equalTo(authCodeView)
            }
        }
        
    }
    
    // MARK: - Private methods
    
    private func resetAuthCountAndTimer() {
        timer?.invalidate()
        timer = nil
        authSecond = Const.authCount
    }
    
    private func requestAuthSms(phoneNumber: String) {

        let onError: (Error) throws -> Void = { error in
            let code = error.code
            if code == 301 {
                self.showAlert(message: "이미 인증된 번호입니다.\n회원탈퇴 시 7일 후에 다른계정에서 다시 인증할 수 있습니다.")
                return
            } else if code == 10300 {
                self.showAlert(title: "문자인증 한도가 초과되었으니 내일 다시 시도해주세요.", message: "신속한 인증을 원할 경우 앱내 불편사항 신고하기를 통해 문의해주세요.")
                return
            }

            self.authCodeTextField.becomeFirstResponder()
            self.authCodeView.isHidden = false
            self.updateAuthButton(isEnabled: false, title: "인증번호 재전송")
            self.updatePhoneTextField(isEnabled: false)
            self.resetAuthCountAndTimer()
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateAuthTimer), userInfo: nil, repeats: true)
        }
        
        viewModel.sendAuthSms(toPhone: phoneNumber, onError: onError)
            .asObservable()
            .subscribe(onNext: { (_, _) in
                self.authCodeTextField.becomeFirstResponder()
                self.authCodeView.isHidden = false
                self.updateAuthButton(isEnabled: false, title: "인증번호 재전송")
                self.updatePhoneTextField(isEnabled: false)
                self.resetAuthCountAndTimer()
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateAuthTimer), userInfo: nil, repeats: true)
            }).disposed(by: disposeBag)
    }
    
    private func setProperties() {
        title = "본인인증"
        self.navigationController?.navigationBar.topItem?.title = ""
        view.backgroundColor = .white
    }
    
    private func setSelector() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapViewDismissKeyboard)))
        authButton.addTarget(self, action: #selector(didClickedAuthButtonItem), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(didClickedConfirmButtonItem), for: .touchUpInside)
        phoneTextField.addTarget(self, action: #selector(editingChangedPhoneTextField(_:)), for: .editingChanged)
        authCodeTextField.addTarget(self, action: #selector(editingChangedAuthCodeTextField(_:)), for: .editingChanged)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func bindView() {
        checkButton.rx.tap.bind { [weak self] (_) in
            guard let self = self else { return }
            self.checkButton.isSelected = !self.checkButton.isSelected
            self.obvTerms.accept(self.checkButton.isSelected)
        }.disposed(by: disposeBag)
        
        arrowImageButton.rx.tap.bind { (_) in
            GlobalFunction.pushToWebViewController(title: "개인정보 수집 및 이용 동의(선택)", url: API.MORE_TERMS_SELECT_URL, webType: .terms)
        }.disposed(by: disposeBag)
        
        Observable.combineLatest(obvConfirmButton, obvTerms).subscribe { [weak self] (isConfirm, isTerms) in
            guard let self = self else { return }
            let isValid = isConfirm && isTerms
            if isValid {
                self.confirmButton.isEnabled = true
            } else {
                self.confirmButton.isEnabled = false
            }
        }.disposed(by: disposeBag)
    }
    
    private func showAlert(title: String? = nil, message: String) {
        let alertAction = UIAlertAction(title: "확인", style: .default)
        alert(title: title, message: message, preferredStyle: .alert, actions: [alertAction])
    }
    
    private func showAlertAuthComplete() {
        let alertAction = UIAlertAction(title: "확인", style: .default) { (_) in
            self.navigationController?.popViewController(animated: true)
        }
        alert(title: "", message: "본인인증에 성공하였습니다.", preferredStyle: .alert, actions: [alertAction])

        UserManager.shared.getUser()
    }
    
    private func showAlertPhoneNumber(phoneNumber: String) {
        let alertAction = UIAlertAction(title: "확인", style: .default) { (_) in
            self.requestAuthSms(phoneNumber: phoneNumber)
        }
        alert(title: "+82 \(phoneNumber) 로", message: "인증번호를 보내드립니다. 전송받은 인증번호를 입력하셔야 상품구입이 가능합니다.", preferredStyle: .alert, actions: [alertAction])
    }
    
    private func updateAuthButton(isEnabled: Bool, title: String? = nil) {
        authButton.isEnabled = isEnabled
        guard let title = title else {return}
        authButton.setTitle(title, for: .normal)
    }
    
    private func updatePhoneTextField(isEnabled: Bool) {
        phoneTextField.isEnabled = isEnabled
        phoneTextField.backgroundColor = isEnabled ? .white : UIColor.fromRGB(235, 235, 235)
    }
    
    private func resetAuthCodeView() {
        authCodeView.isHidden = true
        authCodeTextField.text = ""
        authCodeTimerLabel.text = ""
        confirmButton.isEnabled = false
        authButton.setTitle("인증번호 받기", for: .normal)
    }
    
    private func validatePhoneNumber(phone: String) -> Bool {
        let PHONE_REGEX = "^\\s*(010|011|012|013|014|015|016|017|018|019)(-|\\)|\\s)*(\\d{3,4})(-|\\s)*(\\d{4})\\s*$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: phone)
        return result
    }
    
    // MARK: - Private selector
    
    @objc private func didClickedAuthButtonItem() {
        guard let phoneNumber = phoneTextField.text, phoneNumber.isEmpty == false else {
            showAlert(message: "휴대전화 번호를 입력해주세요")
            return
        }
        
        guard validatePhoneNumber(phone: phoneNumber) else {
            showAlert(message: "올바른 번호를 입력 후 다시 시도해주세요.")
            return
        }
        
        view.endEditing(true)
        
        guard ReachabilityManager.reachability.connection != .unavailable else {
            self.view.makeToastWithCenter("네트워크 연결 상태를 확인해 주세요.")
            return
        }
        
        showAlertPhoneNumber(phoneNumber: phoneNumber)
    }
    
    @objc private func didClickedConfirmButtonItem() {
        GlobalFunction.CDShowLogoLoadingView()
        guard let authCode = authCodeTextField.text else {
            showAlert(message: "올바른 인증번호 입력 후 다시 시도해주세요.")
            return
        }
        self.authCodeTextField.isEnabled = false
        
        let onError: (Error) throws -> Void = { error in
            GlobalFunction.CDHideLogoLoadingView()
            self.authCodeTextField.isEnabled = true
            
            let code = error.code
            if code == 10301 {
                self.showAlert(message: "잘못된 인증번호입니다.\n확인 후 다시 시도해 주세요.")
                return
            }
        }
       
        viewModel.validateSms(by: authCode, onError: onError)
            .asObservable()
            .subscribe(onNext: { result in
                GlobalFunction.CDHideLogoLoadingView()
                self.authCodeTextField.isEnabled = true
                
                if result != "ok" {
                    self.showAlert(message: "잘못된 인증번호입니다.\n확인 후 다시 시도해 주세요.")
                    return
                }
                self.putAgreed()
                self.showAlertAuthComplete()
            }).disposed(by: disposeBag)
    }
    
    @objc private func didTapViewDismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc private func editingChangedAuthCodeTextField(_ textField: UITextField) {
        guard let text = textField.text else {return}
         
        let isConfirm = text.count >= 4 ? true:false
        obvConfirmButton.accept(isConfirm)
    }
    
    @objc private func editingChangedPhoneTextField(_ textField: UITextField) {
        guard let text = textField.text else {return}
        
        updateAuthButton(isEnabled: text.count > 0, title: "인증번호 받기")
    }
    
    @objc private func updateAuthTimer() {
        guard timer != nil else {return}
        
        if authSecond < 1 {
            resetAuthCodeView()
            resetAuthCountAndTimer()
            updatePhoneTextField(isEnabled: true)
        } else {
            authSecond -= 1
            if authSecond == Const.authButtonEnableCount {
                updateAuthButton(isEnabled: true)
            }
            
            if authSecond >= 60 {
                let minute = authSecond/60
                let second = authSecond%60
                authCodeTimerLabel.text = String(format: "남은 시간 %02d:%02d", minute, second)
            } else {
                authCodeTimerLabel.text = String(format: "남은 시간 00:%02d", authSecond)
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: NSNotification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue, let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        // hide confirmButton
        var keyboardHeight = keyboardFrame.cgRectValue.height
        guard let window = UIApplication.shared.keyWindow else {return}
        keyboardHeight -= window.safeAreaInsets.bottom
        
        view.layoutAnimate(duration: TimeInterval(truncating: duration), animations: {
            self.confirmButtonBottom?.update(offset: -keyboardHeight - 16)
            self.descriptionLabel.isHidden = true
            self.view.layoutIfNeeded()
        })
        
    }
    
    @objc private func keyboardWillHide(_ notification: NSNotification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else {return}
        
        // show confirmButton
        view.layoutAnimate(duration: TimeInterval(truncating: duration), animations: {
            self.confirmButtonBottom?.update(offset: 0)
            self.view.layoutIfNeeded()
            self.descriptionLabel.isHidden = false
        })
        
    }
    
    private func requestAgreementInfo() {
        let provider = CashdocProvider<UserSerivce>()
        provider.CDRequest(.getAgree) { json in
            Log.al("json = \(json)")
            let privacyInformationAgreed = json["result"]["privacyInformationAgreed"].boolValue
            self.agreementStack.isHidden = privacyInformationAgreed
            self.checkButton.isSelected = privacyInformationAgreed
            self.obvTerms.accept(self.checkButton.isSelected)
        }
    }
    
    private func putAgreed() {
        let accountService = CashdocProvider<AccountService>()
        accountService.request(PutAccountModel.self, token: .putAccountAgreed(privacyInformationAgreed: true, sensitiveInformationAgreed: nil, healthServiceAgreed: nil))
            .subscribe(onSuccess: { _ in
                if let userModel = UserManager.shared.userModel {
                    var user = userModel
                    user.privacyInformationAgreed = true
                    UserManager.shared.user.onNext(user)
                }
            }, onFailure: { error in
                Log.al("Error putAccount \(error)")
            })
            .disposed(by: disposeBag)
    }
}
 
