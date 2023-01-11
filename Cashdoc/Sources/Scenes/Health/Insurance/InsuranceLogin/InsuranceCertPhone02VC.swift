//
//  InsuranceCertPhone02VC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/13.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa

final class InsuranceCertPhone02VC: CashdocViewController {
    @IBOutlet weak var numberField: kTextFiledPlaceHolder!
    @IBOutlet weak var numberBar: UIView!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var changeNumButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedNumber: Driver<CDValidationResult> = .just(.failed)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
    }
    
    func bindView() {
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(cancelCert))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
        
        changeNumButton.setTitleUnderLine()
        if let aibScr = SmartAIBManager.shared.capchaScarrping,
            let moduleString = aibScr.input["MODULE"] as? String {
                changeNumButton.isHidden = moduleString == "13"
        }

        let getPhoneNum = GlobalDefine.shared.saveInsuranJoinParam["PHONENUM"] ?? ""
        titleLabel.attributedText = GlobalFunction.stringToAttriColor("\(getPhoneNum)로\n인증번호가 전송되었습니다.", wantText: getPhoneNum, textColor: UIColor.blueCw, lineHeight: 24)
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        validatedNumber = numberField.rx.text.orEmpty.asDriver()
            .flatMapLatest { [weak self] (getText) -> Driver<CDValidationResult> in
            guard let self = self else { return .just(.failed) }
            return self.setNumberValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedNumber
            .drive(numberField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedNumber
            .drive(numberBar.rx.validationResult)
            .disposed(by: disposeBag)
        validatedNumber
            .drive(numberLabel.rx.validationResult)
            .disposed(by: disposeBag)
        validatedNumber.drive(onNext: { [weak self] (result) in
            guard let self = self else { return }
            self.nextButton.isEnabled = result.isValid
        }).disposed(by: disposeBag)
    }
    
    @objc func cancelCert() {
        let cancelAction = UIAlertAction(title: "나중에 하기", style: .cancel) { (_) in
            guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
            aibScr.cancel()
            if let moduleString = aibScr.input["MODULE"] as? String, moduleString == "13" {
                GlobalFunction.CDPopToRootViewController(animated: true)
            } else {
                GlobalDefine.shared.curNav?.popViewController(animated: false)
                GlobalDefine.shared.curNav?.popViewController(animated: false)
            }
        }
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        self.alert(title: "인증을 안하시는 경우 보험조회가\n불가능합니다.", message: "", preferredStyle: .alert, actions: [cancelAction, okAction])
    }
    
    @IBAction func changeNumAct(_ sender: UIButton) {
        guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
        aibScr.cancel()
        GlobalFunction.CDPoptoViewController(InsuranFindSegVC.self, animated: false)
    }
    
    @IBAction func nextAct() {
        guard let aibData = SmartAIBManager.shared.capchaResult else {return}
        aibData.setSMSText(numberField.text ?? "")
    }
}

// check Validate
extension InsuranceCertPhone02VC {
    func setNumberValid(_ validString: String) -> Driver<CDValidationResult> {
        let userDefaultText = ""
        
        if validString.isEmpty {
            return .just(.empty(message: userDefaultText))
        }
        
        if validString.count > 4 {
            return .just(.ok(message: userDefaultText))
        } else {
            return .just(.validating(message: userDefaultText))
        }
    }
}
