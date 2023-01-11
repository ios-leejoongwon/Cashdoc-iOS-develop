//
//  MedicHistoryJuminVC.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/01/09.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxCocoa

import SmartAIB
import SwiftyJSON

class MedicHistoryJuminVC: CashdocViewController {
    @IBOutlet weak var juminField01: UITextField!
    @IBOutlet weak var juminField02: UITextField!
    @IBOutlet weak var juminLabel: UIView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var nextButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var titleJuminLabel: UILabel!
    
    var validatedJumin: Driver<CDValidationResult> = .just(.failed)
    var isCheckUp = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.bindView()
        self.bindViewModel()
        
        // titleJuminLabel.text = isCheckUp ? "건강검진 내역 조회를 위해\n주민번호를 입력해 주세요." : "진료 및 투약 내역 조회를 위해\n주민번호를 입력해 주세요."
        
        // 하단에 ISMS용 문구추가
        let infoLabel = UILabel().then {
            $0.text = "- 주민번호는 저장되지 않으며, 서비스 조회 목적 외에\n 다른 용도로 절대 사용되지 않습니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(juminField01.snp.bottom).offset(20)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
        
        _ = UILabel().then {
            $0.text = "- 미국 NASA에서 사용하는 SSL/TLS 및 AES-256 암호화\n 알고리즘을 적용해 고객님의 개인정보는 안전하게 관리됩니다."
            $0.numberOfLines = 0
            $0.font = .systemFont(ofSize: 12)
            $0.textColor = .brownishGray
            $0.setLineHeight(lineHeight: 20)
            view.addSubview($0)
            $0.snp.makeConstraints { (m) in
                m.top.equalTo(infoLabel.snp.bottom).offset(6)
                m.left.equalToSuperview().offset(16)
                m.right.equalToSuperview().inset(16)
            }
        }
    }
    
    func bindView() {
        RxKeyboard.instance.visibleHeight.drive(onNext: { [weak self] keyHeight in
            guard let self = self else {return}
            self.nextButtonBottom.constant = keyHeight + 16
            self.view.layoutIfNeeded()
        }).disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        let viewModel = InsuranContainViewModel(usernameD: Driver.empty(),
                                                jumin01D: juminField01.rx.text.orEmpty.asDriver(),
                                                jumin02D: juminField02.rx.text.orEmpty.asDriver(),
                                                phone01D: Driver.empty(),
                                                phone02D: Driver.empty(),
                                                emailD: Driver.empty(),
                                                loginIDD: Driver.empty(),
                                                passWordD: Driver.empty())
        
        viewModel.validatedJumin
            .drive(juminField01.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedJumin
            .drive(juminField02.rx.validationResult)
            .disposed(by: disposeBag)
        viewModel.validatedJumin.drive(onNext: { [weak self] (cdvalid) in
            guard let self = self else {return}
            self.juminLabel.isHidden = !cdvalid.isFailed
            self.nextButton.isEnabled = cdvalid.isValid
        }).disposed(by: disposeBag)
    }
    
    @IBAction func nextAct() {
        GlobalDefine.shared.saveCertParam = [String: String]()
        GlobalDefine.shared.saveCertParam.updateValue(juminField01.text! + juminField02.text!, forKey: "JUMIN")
        MedicHistoryJuminVC.setStartEndDate()
        
        CertificateManager.pushModuleCertificate(currentVC: self, exitVoid: {
            var makeInputArray = [ScrapingInput]()
            
            makeInputArray.append(ScrapingInput.진료내역_진료조회(params: GlobalDefine.shared.saveCertParam))
            makeInputArray.append(ScrapingInput.진료내역_투약정보(params: GlobalDefine.shared.saveCertParam))
            makeInputArray.append(ScrapingInput.건강검진_결과정보(params: GlobalDefine.shared.saveCertParam))
            makeInputArray.append(ScrapingInput.건강검진_소견정보(params: GlobalDefine.shared.saveCertParam))
            
            GlobalFunction.CDShowLogoLoadingView(.long)
            
            SmartAIBManager.getRunMultiScarpingResult(inputData: makeInputArray, showLoading: false) { (results) in
                var ERRMSG = ""
                var resultJSON01 = JSON.null // 진료내역
                var resultJSON02 = JSON.null // 투약정보
                var appendSwifyObj = [SwiftyJSONRealmObject]()
                var appendSwifyObj02 = [SwiftyJSONRealmObject]()
                GlobalFunction.CDHideLogoLoadingView()
                
                for forResult in results {
                    if forResult.module == "14" {
                        resultJSON02 = JSON(parseJSON: forResult.getResult() ?? "")
                        if resultJSON02["RESULT"].stringValue != "SUCCESS" {
                            ERRMSG = resultJSON02["ERRMSG"].stringValue
                        }
                        let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicIneListModel.self, fromJson: resultJSON02["MEDICINELIST"])
                        appendSwifyObj.append(contentsOf: makeListModel)
                    } else if forResult.module == "5" {
                        resultJSON01 = JSON(parseJSON: forResult.getResult() ?? "")
                        if resultJSON01["RESULT"].stringValue != "SUCCESS" {
                            ERRMSG = resultJSON02["ERRMSG"].stringValue
                        }
                        for joinList in resultJSON01["JOINLIST"].arrayValue {
                            let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicJoinListModel.self, fromJson: joinList["JINLIST"])
                            appendSwifyObj.append(contentsOf: makeListModel)
                        }
                    } else if forResult.module == "6" {
                        let makeJSON = JSON(parseJSON: forResult.getResult() ?? "")
                        if makeJSON["RESULT"].stringValue != "SUCCESS" {
                            ERRMSG = makeJSON["ERRMSG"].stringValue
                        }
                        let makeIncomeModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupIncomeModel.self, fromJson: makeJSON["INCOMELIST"])
                        appendSwifyObj02.append(contentsOf: makeIncomeModel)
                        
                        let makeReferModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupReferceListModel.self, fromJson: makeJSON["REFERECELIST"])
                        appendSwifyObj02.append(contentsOf: makeReferModel)
                    } else if forResult.module == "13" {
                        let makeJSON = JSON(parseJSON: forResult.getResult() ?? "")
                        if makeJSON["RESULT"].stringValue != "SUCCESS" {
                            ERRMSG = makeJSON["ERRMSG"].stringValue
                        }
                        let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupListModel.self, fromJson: makeJSON["CHECKUPLIST"])
                        appendSwifyObj02.append(contentsOf: makeListModel)
                    }
                }
                
                // 에러가 있을시에
                if ERRMSG.isNotEmpty {
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                        GlobalFunction.CDPopToRootViewController(animated: true)
                    })
                    GlobalFunction.FirLog(string: "건강_진료내역_건강검진결과_연동_실패")
                    self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                } else {
                    UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinked내진료내역_new.rawValue)
                    MedicHistoryRealmProxy().append(appendSwifyObj)
                    MedicHistoryRealmProxy().changePriceQuery()
                    // 진료내역 로그인정보저장하기
                    if let certDir = GlobalDefine.shared.saveCertParam["CERTDIRECTORY"],
                       let certPwd = GlobalDefine.shared.saveCertParam["CERTPWD"],
                       let juminNum = GlobalDefine.shared.saveCertParam["JUMIN"] {
                        
                        let makeMehod = ["CERTDIRECTORY": certDir, "CERTPWD": certPwd]
                        let makeScarpInfo = LinkedScrapingInfo(loginMethods: ["진료내역": makeMehod])
                        makeScarpInfo.juminNumber = juminNum
                        LinkedScrapingV2InfoRealmProxy().appendList([makeScarpInfo], clearHandler: nil)
                    }
                    
                    // 진료내역 서버로 전송하기
                    if let treatValue = AES256CBC.encryptCashdoc(resultJSON01.rawString() ?? ""), let jindsValue = AES256CBC.encryptCashdoc(resultJSON02.rawString() ?? "") {
                        let provider = CashdocProvider<TreatmentService>()
                        provider.CDRequest(.postTreatment(treat: treatValue, jinds: jindsValue)) { _ in
                            // notihing
                        }
                    }
                    
                    UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinked건강검진_new.rawValue)
                    CheckUpRealmProxy().append(appendSwifyObj02)
                    CheckUpRealmProxy().mergeToIncome(GlobalDefine.shared.saveCertParam["JUMIN"] ?? "")
                    
                    // 건강검진결과 서버로 전송하기
                    GlobalFunction.FirLog(string: "건강_진료내역_건강검진결과_연동_성공")
                    var makeArray = [[String: String]]()
                    let getIncomes = CheckUpRealmProxy().getIncomeModelList()
                    for getModel in getIncomes {
                        makeArray.append(getModel.toDict())
                    }
                    let makeJSON = JSON(["RESULT": "SUCCESS", "INCOMELIST": makeArray])
                    
                    if let cValue = AES256CBC.encryptCashdoc(makeJSON.rawString() ?? "") {
                        let provider = CashdocProvider<CheckupService>()
                        provider.CDRequest(.postCheckup(value: cValue)) { _  in
                            GlobalFunction.CDPopToRootViewController(animated: false)
                            if self.isCheckUp {
                                if getIncomes.count == 0 {
                                    let getBirth = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpBirth.rawValue) ?? ""
                                    let getGender = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpGender.rawValue) ?? ""
                                    let userName = UserDefaults.standard.string(forKey: UserDefaultKey.kUserName.rawValue) ?? ""
                                    GlobalFunction.pushToWebViewController(title: "건강 검진 결과", url: "\(API.HOME_WEB_URL)health/suggestion?nickname=\(userName)&gender=\(getGender)&year=\(getBirth)", addfooter: false, hiddenbar: true)
                                } else {
                                    HealthNavigator.pushShowCheckupStoryboard(identi: CheckupResultVC.reuseIdentifier)
                                }
                            } else {
                                HealthNavigator.pushShowMedicHistoryStoryboard(identi: MedicMyHistoryVC.reuseIdentifier)
                            }
                        }
                    }
                }
                
                // 글로벌밸류들 초기화
                GlobalDefine.shared.saveCertParam.removeAll()
                GlobalDefine.shared.exitClosure = nil
            }
        })
    }
    
    class func setStartEndDate() {
        let previouse14Month = Calendar.current.date(byAdding: .month, value: -14, to: Date()) ?? Date()
        let previouse2Month = Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        GlobalDefine.shared.saveCertParam.updateValue(dateFormatter.string(from: previouse14Month), forKey: "STARTDATE")
        GlobalDefine.shared.saveCertParam.updateValue(dateFormatter.string(from: previouse2Month), forKey: "ENDDATE")
    }
}
