//
//  InsuranceJoin03VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

final class InsuranceJoin03VC: CashdocViewController {
    @IBOutlet weak var passwordField: kTextFiledPlaceHolder!
    @IBOutlet weak var passwordBar: UIView!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var showHiddenButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedPW: Driver<CDValidationResult> = .just(.failed)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
    }
    
    func bindView() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        validatedPW = passwordField.rx.text.orEmpty.asDriver()
            .flatMapLatest { (getText) -> Driver<CDValidationResult> in
            return InsuranceJoin03VC.setPWValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedPW
            .drive(passwordField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedPW
            .drive(passwordBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedPW
            .drive(passwordLabel.rx.validationPWResult)
            .disposed(by: disposeBag)
        
        validatedPW.drive(onNext: { [weak self] (result) in
            guard let self = self else { return }
            self.nextButton.isEnabled = result.isValid
        }).disposed(by: disposeBag)
    }
    
    @IBAction func showHidden(_ sender: UIButton) {
        passwordField.isSecureTextEntry = sender.isSelected
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func nextAct() {
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(passwordField.text ?? "", forKey: "JOINPWD")
        
        HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceJoin04VC.reuseIdentifier)
    }
}

// check Validate
extension InsuranceJoin03VC {
    class func setPWValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = "문자, 숫자, 특수문자 조합 9~20자리\n(특수문자는 !, @, #, $, %, ^, &, *, ?, _, ~ 만 가능)\n- 문자, 숫자, 특수문자 필수 입력\n- 동일한 문자 또는 숫자의 3자 이상 금지\n- 연속되는 문자(abc...) 또는 숫자(123...)의 3자 이상 금지\n- 사용자 ID와 동일한 패스워드 금지\n- 생년월일(YYYYMMDD, YYMMDD), 전화번호, 이름 등과 동일한\n비밀번호 금지\n- 주민등록번호 사용금지(앞6자리, 뒤7자리, 전체13자리)"
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if validString.count < 9 {
            return .just(.validating(message: userDefaultText))
        }
        
        var haveMatch = 0
        
        // 문자가 포함
        if GlobalFunction.matches(for: "[a-zA-Z가-힣]", in: validString) != 0 {
            haveMatch += 1
        }
        // 숫자가 포함
        if GlobalFunction.matches(for: "[0-9]", in: validString) != 0 {
            haveMatch += 1
        }
        // 특정 특수문자가 포함
        if GlobalFunction.matches(for: "[!,@,#,$,%,^,&,*,?,_,~]", in: validString) != 0 {
            haveMatch += 1
        }
        
        var haveNotMatch = 0
        // 동일한 문자 또는 숫자의 3자 이상 금지
        if GlobalFunction.matches(for: "[ㄱ-힣]", in: validString) != 0 {
            haveNotMatch += 1
        }
        
        // 사용자 ID을 포함
        if validString.contains(GlobalDefine.shared.saveInsuranJoinParam["JOINID"] ?? "") {
            haveNotMatch += 1
        }
        
        // 사용자 이름을 포함
        if validString.contains(GlobalDefine.shared.saveInsuranJoinParam["DSNM"] ?? "") {
            haveNotMatch += 1
        }
        
        if let getJumin = GlobalDefine.shared.saveInsuranJoinParam["JUMIN"], getJumin.count > 12 {
            // 주민번호 앞자리 포함
            if validString.contains(getJumin[0..<7]) {
                haveNotMatch += 1
            }
            // 주민번호 뒷자리 포함
            if validString.contains(getJumin[6..<13]) {
                haveNotMatch += 1
            }
            // 주민번호 13자리 포함
            if validString.contains(getJumin) {
                haveNotMatch += 1
            }
        }
        
        if validString.count > 3 {
            for i in 0..<validString.count-2 {
                let getcharacterA = validString[i].unicodeScalars.first?.value ?? 0
                let getcharacterB = validString[i+1].unicodeScalars.first?.value ?? 0
                let getcharacterC = validString[i+2].unicodeScalars.first?.value ?? 0
                                
                // 같은문자가 연속3번으로 사용
                if getcharacterA == getcharacterB, getcharacterB == getcharacterC {
                    haveNotMatch += 1
                }
                
                // abc,123같이 연속적인문자가 3번사용
                if getcharacterA+1 == getcharacterB, getcharacterB + 1 == getcharacterC {
                    haveNotMatch += 1
                }
            }
        }
        
        if haveMatch == 3, haveNotMatch == 0 {
            return .just(.ok(message: userDefaultText))
        } else {
            return .just(.failed)
        }
    }
}
