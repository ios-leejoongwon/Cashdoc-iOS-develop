//
//  InsuranceJoin05VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

import SafariServices
import SwiftyJSON

final class InsuranceJoin05VC: CashdocViewController {
    @IBOutlet weak var phoneField: kTextFiledPlaceHolder!
    @IBOutlet weak var phoneBar: UIView!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var selectAgencyButton: UIButton!
    @IBOutlet weak var cannotRememberButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedPhone: Driver<CDValidationResult> = .just(.failed)
    var validatedAgency: Driver<Bool> = .just(false)
    var selectIndex = BehaviorRelay.init(value: 0)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
    }
    
    func bindView() {
        cannotRememberButton.setTitleUnderLine()
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        validatedPhone = phoneField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
            guard let self = self else { return .just(.failed) }
            return self.setPhoneValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedPhone
            .drive(phoneField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedPhone
            .drive(phoneBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedPhone
            .drive(phoneLabel.rx.validationResult)
            .disposed(by: disposeBag)
                
        validatedAgency = selectIndex.flatMapLatest { (index) -> Driver<Bool> in
            .just(index != 0)
        }.asDriver(onErrorJustReturn: false)
        
        Driver.combineLatest(
            validatedPhone, validatedAgency
        ) { $0.isValid && $1 }
            .distinctUntilChanged()
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)

    }
    
    @IBAction func canNotRemember() {
        guard let url = URL(string: API.INSURANCE_JOIN_URL) else {return}
         let controller = SFSafariViewController(url: url)
         controller.setTintColor()
         self.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func changeAgency() {
        GlobalFunction.CDActionSheet("통신사 선택", leftItems: ["KT", "SKT", "LG", "KT알뜰폰", "SKT알뜰폰", "LG알뜰폰"]) { (idx, name) in
            self.selectAgencyButton.setTitleColor(UIColor.blackCw, for: .normal)
            self.selectAgencyButton.setTitle(name, for: .normal)
            self.selectIndex.accept(idx+1)
        }
    }
    
    @IBAction func nextAct() {
        GlobalDefine.shared.saveInsuranJoinParam.updateValue("\(selectIndex.value)", forKey: "TELECOMGUBUN")
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(phoneField.text ?? "", forKey: "PHONENUM")
  
        self.view.endEditing(true)
        let makeInput = ScrapingInput.내보험다보여_회원가입(params: GlobalDefine.shared.saveInsuranJoinParam)
        SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: 180)
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true, failure: { json in
            if json == JSON.null {
                HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceCertPhone01VC.reuseIdentifier)
            } else {
                if json["ECODE"].stringValue == "ERR_MLCOM_MSG50060" || json["ECODE"].stringValue == "ERR_MLCOM_MSG50054" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        self.retryCapcha()
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: json["ERRMSG"].stringValue, preferredStyle: .alert, actions: [makeAction])
                } else if json["ECODE"].stringValue != "ERR_MIMSG_SCR40902" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
                        aibScr.cancel()
                        GlobalFunction.CDPoptoViewController(InsuranceJoin05VC.self, animated: false)
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: json["ERRMSG"].stringValue, preferredStyle: .alert, actions: [makeAction])
                }
                SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: SmartAIBManager.shared.timeOut)
            }
        }, getResultJson: { _ in
            let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                GlobalDefine.shared.saveInsuranJoinParam.updateValue("Y", forKey: "directLogin")
                GlobalFunction.CDPopToRootViewController(animated: false)
                HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceLoginVC.reuseIdentifier)
            }
            GlobalDefine.shared.curNav?.alert(title: nil, message: "본인인증이 완료되었습니다.", preferredStyle: .alert, actions: [makeAction])
            SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: SmartAIBManager.shared.timeOut)
        })
    }
    
    private func retryCapcha() {
        var joinParam = GlobalDefine.shared.saveInsuranJoinParam
        joinParam.updateValue(joinParam["JOINID"] ?? "", forKey: "LOGINID")
        joinParam.updateValue(joinParam["JOINPWD"] ?? "", forKey: "LOGINPWD")
        joinParam.updateValue("1", forKey: "LOGINMETHOD")
        
        let makeInput = ScrapingInput.내보험다보여_아이디비번찾기(module: "16", params: joinParam)
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true, failure: { json in
            if json == JSON.null {
                DispatchQueue.main.async {
                    GlobalFunction.CDPopToRootViewController(animated: false)
                }
                HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceCertPhone01VC.reuseIdentifier)
            } else {
                if json["ECODE"].stringValue == "ERR_MLCOM_MSG50060" || json["ECODE"].stringValue == "ERR_MLCOM_MSG50054" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        self.retryCapcha()
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: json["ERRMSG"].stringValue, preferredStyle: .alert, actions: [makeAction])
                } else if json["ECODE"].stringValue != "ERR_MIMSG_SCR40902" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
                        aibScr.cancel()
                        GlobalFunction.CDPoptoViewController(HealthViewController.self, animated: false)
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: json["ERRMSG"].stringValue, preferredStyle: .alert, actions: [makeAction])
                }
            }
        }, getResultJson: { _ in
            GlobalDefine.shared.saveInsuranJoinParam.updateValue("Y", forKey: "directLogin")
            GlobalFunction.CDPopToRootViewController(animated: false)
            HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceLoginVC.reuseIdentifier)
        })
    }
}

// check Validate
extension InsuranceJoin05VC {
    func setPhoneValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = "숫자만 입력"
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if validString.count > 10 {
            if GlobalFunction.isPhone(candidate: validString) {
                return .just(.ok(message: userDefaultText))
            } else {
                return .just(.failed)
            }
        } else {
            return .just(.validating(message: userDefaultText))
        }
    }
}
