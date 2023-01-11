//
//  InsuranContainVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/18.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import SwiftyJSON

class InsuranContainVC: CashdocViewController {
    @IBOutlet weak var boxStackView01: UIStackView!
    @IBOutlet weak var boxStackView01Field: UITextField!
    @IBOutlet weak var boxStackView01ForButton: UIButton!
    
    @IBOutlet weak var boxStackView02: UIStackView!
    @IBOutlet weak var boxStackView02Field01: UITextField!
    @IBOutlet weak var boxStackView02Field02: UITextField!
    @IBOutlet weak var boxStackView02ValidView: UIView!
    
    @IBOutlet weak var boxStackView03: UIStackView!
    @IBOutlet weak var boxStackView03Field: UITextField!
    @IBOutlet weak var boxStackView03AgencyButton: UIButton!
    @IBOutlet weak var boxStackView03ValidView: UIView!
    
    @IBOutlet weak var boxStackView04: UIStackView!
    @IBOutlet weak var boxStackView04Field: UITextField!
    @IBOutlet weak var boxStackView04ValidView: UIView!
    
    @IBOutlet weak var boxStackView05: UIStackView!
    @IBOutlet weak var boxStackView05Field: UITextField!
    @IBOutlet weak var boxStackView05ValidView: UIView!
    
    @IBOutlet weak var getScrollView: UIScrollView!
    @IBOutlet weak var nextButton: UIButton!
    
    var getType = true // true: 아이디찾기 false: 비번찾기
    var selectIndex = BehaviorRelay(value: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bindView()
        self.bindViewModel()
    }
            
    @IBAction func changeForeigner(_ sender: UIButton) {
        GlobalFunction.CDActionSheet("내/외국인 선택", leftItems: ["내국인", "외국인"]) { (_, name) in
            sender.setTitle(name, for: .normal)
        }
    }
    
    @IBAction func changeAgency(_ sender: UIButton) {
        GlobalFunction.CDActionSheet("통신사 선택", leftItems: ["KT", "SKT", "LG", "KT알뜰폰", "SKT알뜰폰", "LG알뜰폰"]) { (idx, name) in
            self.boxStackView03AgencyButton.setTitleColor(UIColor.blackCw, for: .normal)
            self.boxStackView03AgencyButton.setTitle(name, for: .normal)
            self.selectIndex.accept(idx+1)
        }
    }
        
    @IBAction func nextAct() {
        self.view.endEditing(true)
        let makeParam: [String: String] = ["DSNM": boxStackView01Field.text!,
                         "JUMIN": boxStackView02Field01.text! + boxStackView02Field02.text!,
                         "PHONENUM": boxStackView03Field.text!,
                         "TELECOMGUBUN": "\(selectIndex.value)",
                         "GENDERGUBUN": GlobalFunction.checkGender(boxStackView02Field01.text! + boxStackView02Field02.text!),
                         "FOREIGNGUBUN": boxStackView01ForButton.title(for: .normal) == "내국인" ? "1" : "2",
                         "EMAIL": boxStackView04Field.text!,
                         "LOGINID": boxStackView05Field.text!
            ]
        GlobalDefine.shared.saveInsuranJoinParam = makeParam
        let makeType = getType ? "14" : "15"
        let makeInput = ScrapingInput.내보험다보여_아이디비번찾기(module: makeType, params: makeParam)
        SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: 180)
        SmartAIBManager.getRunScarpingResult(inputData: makeInput, showLoading: true, failure: { json in
            if json == JSON.null {
                HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceCertPhone01VC.reuseIdentifier)
            } else {
                if json["ECODE"].stringValue != "ERR_MIMSG_SCR40902" {
                    let makeAction = UIAlertAction(title: "확인", style: .default) { _ in
                        guard let aibScr = SmartAIBManager.shared.capchaScarrping else {return}
                        aibScr.cancel()
                        GlobalFunction.CDPoptoViewController(InsuranFindSegVC.self, animated: false)
                    }
                    GlobalDefine.shared.curNav?.alert(title: nil, message: json["ERRMSG"].stringValue, preferredStyle: .alert, actions: [makeAction])
                }
                SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: SmartAIBManager.shared.timeOut)
            }
        }, getResultJson: { [weak self] _ in
            guard let self = self else {return}
            if self.getType {
                HealthNavigator.pushShowFindAccountStoryboard(identi: InsuranAccountResultVC.reuseIdentifier)
            } else {
                GlobalDefine.shared.saveInsuranJoinParam.updateValue("Y", forKey: "directLogin")
                DispatchQueue.main.async {
                    GlobalFunction.CDPopToRootViewController(animated: false)
                }
                HealthNavigator.pushInsuranceLoginStoryboard(identi: InsuranceLoginVC.reuseIdentifier)
            }
            SmartAIBManager.setConfigAIBKey(key: SMARTAIB_ACCESSKEY, sharedKey: SMARTAIB_SHAREDKEY, timeout: SmartAIBManager.shared.timeOut)
        })
    }
    
    func bindView() {
        boxStackView05.isHidden = getType
        boxStackView05Field.text = getType ? "1234567" : "" // 아이디찾기일경우 valid검증 맞추기위해 억지로 박아둠...
        
        boxStackView01Field.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView02Field01.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView02Field01.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView02Field02.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView02Field02.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView03Field.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView03Field.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView04Field.becomeFirstResponder()
        }).disposed(by: disposeBag)
        
        boxStackView04Field.rx.controlEvent([.editingDidEndOnExit]).bind(onNext: { [weak self] _ in
            guard let self = self else {return}
            self.boxStackView05Field.becomeFirstResponder()
        }).disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        let viewModel = InsuranContainViewModel(usernameD: boxStackView01Field.rx.text.orEmpty.asDriver(),
                                                jumin01D: boxStackView02Field01.rx.text.orEmpty.asDriver(),
                                                jumin02D: boxStackView02Field02.rx.text.orEmpty.asDriver(),
                                                phone01D: selectIndex.asDriver(),
                                                phone02D: boxStackView03Field.rx.text.orEmpty.asDriver(),
                                                emailD: boxStackView04Field.rx.text.orEmpty.asDriver(),
                                                loginIDD: boxStackView05Field.rx.text.orEmpty.asDriver(),
                                                passWordD: nil)
        
        viewModel.validatedJumin
            .drive(boxStackView02Field01.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedJumin
            .drive(boxStackView02Field02.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedJumin.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView02ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)
        viewModel.validatedPhone
            .drive(boxStackView03Field.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedPhone.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView03AgencyButton.layer.borderColor = cdvalid.isFailed ? UIColor.redCw.cgColor : UIColor.grayCw.cgColor
            self.boxStackView03ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)

        viewModel.validatedEmail
            .drive(boxStackView04Field.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedEmail.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.boxStackView04ValidView.isHidden = !cdvalid.isFailed
        }).disposed(by: disposeBag)
        
        if !getType {
            viewModel.validatedID
                .drive(boxStackView05Field.rx.validationResult)
                .disposed(by: disposeBag)
            viewModel.validatedID.drive(onNext: { [weak self] (cdvalid) in
                guard let self = self else {return}
                self.boxStackView05ValidView.isHidden = !cdvalid.isFailed
            }).disposed(by: disposeBag)
        }

        viewModel.nextEnabled
            .drive(nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}
