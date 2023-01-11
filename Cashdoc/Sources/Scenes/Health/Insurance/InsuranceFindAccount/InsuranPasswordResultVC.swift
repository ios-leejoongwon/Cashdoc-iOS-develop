//
//  InsuranPasswordResultVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/19.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

class InsuranPasswordResultVC: CashdocViewController {
    @IBOutlet weak var topTitleLabel: UILabel!
    @IBOutlet weak var tempPWField: UITextField!
    @IBOutlet weak var newPWField: UITextField!
    @IBOutlet weak var validLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    
    var validatedPW01: Driver<CDValidationResult> = .just(.failed)
    var validatedPW02: Driver<CDValidationResult> = .just(.failed)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
    }
    
    @IBAction func nextAct() {
        let passArray = [tempPWField.text!, newPWField.text!]
        guard let aibData = SmartAIBManager.shared.capchaResult else {return}
        GlobalDefine.shared.saveInsuranJoinParam.updateValue(newPWField.text!, forKey: "LOGINPWD")
        aibData.setMultiInputDialog(passArray)
    }
    
    @objc func cancelCert() {
        let cancelAction = UIAlertAction(title: "나중에 하기", style: .cancel) { (_) in
            guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
            aibScr.cancel()
            GlobalFunction.CDPopToRootViewController(animated: true)
        }
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        self.alert(title: "인증을 안하시는 경우 보험조회가\n불가능합니다.", message: "", preferredStyle: .alert, actions: [cancelAction, okAction])
    }
    
    func bindView() {
        let button = UIBarButtonItem(title: "",
                                     style: .plain,
                                     target: self,
                                     action: #selector(cancelCert))
        button.image = UIImage(named: "icCloseBlack")
        navigationItem.leftBarButtonItem = button
        
        let getEmail = GlobalDefine.shared.saveInsuranJoinParam["EMAIL"] ?? ""
        topTitleLabel.attributedText = GlobalFunction.stringToAttriColor("\(getEmail) 에서\n임시 비밀번호를 확인하고\n새 비밀번호로 변경해주세요.", wantText: getEmail, textColor: UIColor.blueCw, lineHeight: 24)
        
        tempPWField.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.newPWField.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
        
        validatedPW01 = tempPWField.rx.text.orEmpty.asDriver()
            .flatMapLatest { (getText) -> Driver<CDValidationResult> in
            return InsuranceJoin03VC.setPWValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedPW01
            .drive(tempPWField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedPW01
            .drive(validLabel.rx.validationPWResult)
            .disposed(by: disposeBag)
                
        validatedPW02 = newPWField.rx.text.orEmpty.asDriver()
            .flatMapLatest { (getText) -> Driver<CDValidationResult> in
            return InsuranceJoin03VC.setPWValid(getText)
        }.asDriver(onErrorJustReturn: .failed)
        
        validatedPW02
            .drive(newPWField.rx.validationResult)
            .disposed(by: disposeBag)
        validatedPW02
            .drive(validLabel.rx.validationPWResult)
            .disposed(by: disposeBag)
        
        Driver.combineLatest(
            validatedPW01, validatedPW02
        ) { $0.isValid && $1.isValid }
            .distinctUntilChanged()
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
