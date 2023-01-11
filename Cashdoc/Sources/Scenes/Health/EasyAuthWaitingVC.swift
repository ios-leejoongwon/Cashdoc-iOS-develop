//
//  EasyAuthWaiting.swift
//  Cashdoc
//
//  Created by 이아림 on 2022/12/15.
//  Copyright © 2022 Cashwalk. All rights reserved.
//

import Foundation
import SnapKit
import RxCocoa
import SwiftyJSON

class EasyAuthWaiting: CashdocViewController {
    
    private var type: AuthType = .none
    private var name = ""
    private var birth = ""
    private var phoneNum = ""
    private var mobileType: MobileType = .none
    private var authPurpose: EasyAuthPurpose = .none
    private var callbackId = ""
    private var errMsg = ""
    
    private var confirmButton: UIButton!
    
    init(authPurpose: EasyAuthPurpose, type: AuthType, name: String, birth: String, phoneNum: String, mobileType: MobileType) {
        super.init(nibName: nil, bundle: nil)
        self.authPurpose = authPurpose
        self.type = type
        self.name = name
        self.birth = birth
        self.phoneNum = phoneNum
        self.mobileType = mobileType
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setProperties()
        bindView()
        requestAuth()
    }
    
    private func setProperties() {
        title = "간편인증 확인"
        view.backgroundColor = .white
        self.navigationController?.navigationBar.backgroundColor = .yellowCw
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    func setupView() {
        
        let navibarHeight = topbarHeight + StatusBarSize.HEIGHT
        
        Log.al("topbarHeight = \(topbarHeight)")
        let titleLabel = UILabel().then {
            $0.textAlignment = .left
            $0.text = "인증을 진행해 주세요."
            $0.numberOfLines = 0
            $0.setFontToMedium(ofSize: 22)
            $0.textColor = UIColor.blackCw
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalToSuperview().offset(navibarHeight + 48)
                m.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        let descLabel = UILabel().then {
            $0.textAlignment = .left
            $0.text = "입력하신 휴대폰번호로 인증요청 메시지 보냈습니다."
            $0.numberOfLines = 0
            $0.setFontToMedium(ofSize: 14)
            $0.textColor = UIColor.brownishGray
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(titleLabel.snp.bottom).offset(8)
                m.leading.trailing.equalToSuperview().inset(16)
            }
        }
        
        let imgPhoneBg = UIImageView().then {
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.image = UIImage(named: "imgPhoneBg")
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.equalTo(300)
                m.centerX.equalToSuperview()
                m.top.equalTo(descLabel.snp.bottom).offset(40)
            }
        }
        
        _ = UIImageView().then {
            $0.backgroundColor = .clear
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
            $0.image = UIImage(named: type.image())
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.width.height.equalTo(60)
                m.top.equalTo(imgPhoneBg.snp.top).offset(83)
                m.centerX.equalToSuperview()
            }
        }
        
        _ = UILabel().then {
            $0.textAlignment = .center
            $0.text = type.authInfoMessage()
            $0.numberOfLines = 0
            $0.setFontToBold(ofSize: 16)
            $0.textColor = UIColor.blackCw
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.top.equalTo(imgPhoneBg.snp.bottom).offset(8)
                m.centerX.equalToSuperview()
            }
        }
        
        confirmButton = UIButton().then {
            $0.setBackgroundColor(.yellowCw, forState: .normal)
            $0.setBackgroundColor(.sunFlowerYellowClick, forState: .highlighted)
            $0.setBackgroundColor(.grayCw, forState: .disabled)
            $0.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
            $0.setTitleColor(.black, for: .normal)
            $0.setTitleColor(.white, for: .disabled)
            $0.setTitle("인증 완료", for: .normal)
            $0.isEnabled = false
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(56)
                m.right.left.equalToSuperview().inset(16)
                m.bottom.equalTo(view.snp.bottomMargin).inset(16)
            }
        }
        
        let vInfo = UIView().then {
            $0.backgroundColor = .grayThreeCw
            $0.IBborderColor = .grayCw
            $0.IBcornerRadius = 4
            $0.IBborderWidth = 0.5
            view.addSubview($0)
            $0.snp.makeConstraints { m in
                m.height.equalTo(93)
                m.bottom.equalTo(confirmButton.snp.top).offset(-16)
                m.right.left.equalToSuperview().inset(16)
            }
        }
        
        let VStack = UIStackView().then {
            $0.distribution = .fill
            $0.axis = .vertical
            $0.spacing = 4
            vInfo.addSubview($0)
            $0.snp.makeConstraints { m in
                m.centerY.equalToSuperview()
                m.left.right.equalToSuperview().inset(16)
            }
        }
        
        _ = UILabel().then {
            $0.text = "인증 요청 메세지가 오지 않을 경우"
            $0.setFontToBold(ofSize: 13)
            $0.textColor = .blackCw
            $0.textAlignment = .left
            VStack.addArrangedSubview($0)
        }
        
        _ = UILabel().then {
            $0.text = type.dontCallInfoMessage()
            $0.numberOfLines = 0
            $0.setFontToRegular(ofSize: 12)
            $0.textColor = .brownishGray
            $0.textAlignment = .left
            VStack.addArrangedSubview($0)
        }
    }
    
    func bindView() {
        confirmButton.rx.tap.subscribe {[weak self] _ in
            guard let self = self else {return}
            // 중복 요청 피하기 위해 잠시 disable
            self.confirmButton.isEnabled = false
            GlobalFunction.FirLog(string: "간편인증3단계_인증완료_클릭_iOS")
            switch self.authPurpose {
            case .건강검진조회, .건강검진한눈에보기조회:
                self.requestCaptchaCheckup(callbackId: self.callbackId)
            case .진료내역조회, .진료내역상세조회:
                self.requestCaptchaTreatment(callbackId: self.callbackId)
            default:
                return
            }
        }.disposed(by: disposeBag)
        
    }
    
    func requestAuth() {
        switch authPurpose {
        case .건강검진조회, .건강검진한눈에보기조회:
            requestCheckup()
        case .진료내역조회, .진료내역상세조회:
            requestMediHis()
        default:
            return
        }
    }
    
    func requestCheckup() {
        GlobalFunction.CDShowLogoLoadingView()
        let provider = CashdocProvider<CheckupService>()
        provider.CDRequest(.postCheckupCert(loginOption: type.number(), birth: self.birth, userName: name, phoneNum: phoneNum, telecomType: mobileType.number())) { (json) in
            Log.al(json)
            GlobalFunction.CDHideLogoLoadingView()
            self.confirmButton.isEnabled = true
            self.callbackId = json["data"]["callbackId"].stringValue
            Log.al("callbackId = \(self.callbackId)")
        }
    }
    
    func requestMediHis() {
        GlobalFunction.CDShowLogoLoadingView()
        let provider = CashdocProvider<TreatmentService>()
        provider.CDRequest(.postTreatmentCert(loginOption: type.number(), birth: self.birth, userName: name, phoneNum: phoneNum, telecomType: mobileType.number())) { (json) in
            
            GlobalFunction.CDHideLogoLoadingView()
            self.confirmButton.isEnabled = true
            Log.al(json)
            self.callbackId = json["data"]["callbackId"].stringValue
            Log.al("callbackId = \(self.callbackId)")
        }
    }
    // 진료내역
    func requestCaptchaTreatment(callbackId: String) {
        GlobalFunction.CDShowLogoLoadingView()
        let provider = CashdocProvider<TreatmentService>()
        provider.CDRequest(.postTreatmentCallback(callbackId: callbackId)) { (makeJSON) in
            
            GlobalFunction.CDHideLogoLoadingView()
            self.confirmButton.isEnabled = true
            Log.al("makeJSON = \(makeJSON)")
            let result = makeJSON["result"].stringValue
            if !result.isEmpty, result != "SUCCESS" {
                var ERRMSG = makeJSON["errMsg"].stringValue
                let errCode = makeJSON["errCode"].stringValue
                if errCode == "4000" || errCode == "0001" {
                    let id = makeJSON["callbackId"].stringValue
                    if !id.isEmpty {
                        self.callbackId = id
                    }
                    let ERRMSG = "간편인증이 완료되지 않았습니다. 앱에서 인증을 완료해주시기 바랍니다."
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    })
                    self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                    return
                }
                
                let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    GlobalFunction.CDPopToRootViewController(animated: true)
                })
                GlobalFunction.FirLog(string: "간편인증3단계_인증실패_iOS")
                
                if ERRMSG.isEmpty {
                    ERRMSG = "잠시후 다시 시도해 주세요."
                }
                self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                return
            }
            
            let resultJSON01 = makeJSON["data"]
            let resultJSON02 = makeJSON["data"]
            var appendSwifyObj = [SwiftyJSONRealmObject]()
            
            for joinList in resultJSON01["JOINLIST"].arrayValue {
                let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicJoinListModel.self, fromJson: joinList["JINLIST"])
                appendSwifyObj.append(contentsOf: makeListModel)
            }
            
            let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: MedicIneListModel.self, fromJson: resultJSON02["MEDICINELIST"])
            appendSwifyObj.append(contentsOf: makeListModel)
            
            MedicHistoryRealmProxy().append(appendSwifyObj)
            MedicHistoryRealmProxy().changePriceQuery()
            Log.al("appendSwifyObj = \(appendSwifyObj)")
            
            self.saveUserInfo()
            // 진료내역 로그인정보저장하기
            GlobalDefine.shared.saveCertParam = [String: String]()
            GlobalDefine.shared.saveCertParam.updateValue(self.birth, forKey: "JUMIN")
            
            // 진료내역 서버로 전송하기
            if let treatValue = AES256CBC.encryptCashdoc(resultJSON01.rawString() ?? ""), let jindsValue = AES256CBC.encryptCashdoc(resultJSON02.rawString() ?? "") {
                Log.al("treatValue = \(treatValue)")
                Log.al("jindsValue = \(jindsValue)")
                let provider = CashdocProvider<TreatmentService>()
                provider.CDRequest(.postTreatment(treat: treatValue, jinds: jindsValue)) { _ in
                    
                }
            }
            
            UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinked내진료내역_new.rawValue)
            GlobalFunction.FirLog(string: "간편인증3단계_인증성공_iOS")
            HealthNavigator.pushShowMedicHistoryStoryboard(identi: MedicMyHistoryVC.reuseIdentifier)
        }
    }
    
    func requestCaptchaCheckup(callbackId: String) {
        GlobalFunction.CDShowLogoLoadingView()
        let provider = CashdocProvider<CheckupService>()
        provider.CDRequest(.postCheckupCallback(callbackId: callbackId)) { (makeJSON) in
            
            GlobalFunction.CDHideLogoLoadingView()
            self.confirmButton.isEnabled = true
            Log.al("makeJSON = \(makeJSON)")
            let result = makeJSON["result"].stringValue
            if !result.isEmpty, result != "SUCCESS" {
                var ERRMSG = makeJSON["errMsg"].stringValue
                let errCode = makeJSON["errCode"].stringValue
                if errCode == "4000" || errCode == "0001" {
                    let id = makeJSON["callbackId"].stringValue
                    if !id.isEmpty {
                        self.callbackId = id
                    }
                    
                    let ERRMSG = "간편인증이 완료되지 않았습니다. 앱에서 인증을 완료해주시기 바랍니다."
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    })
                    self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                    return
                }
                let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    GlobalFunction.CDHideLogoLoadingView()
                })
                GlobalFunction.FirLog(string: "간편인증3단계_인증실패_iOS")
                if ERRMSG.isEmpty {
                    ERRMSG = "잠시후 다시 시도해 주세요."
                }
                self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                return
            }
            
            let data = makeJSON["data"]
            Log.al("data[result] = \(data["result"])")
            Log.al("data[errCode] = \(data["errCode"])")
            
            if data["errCode"].stringValue != "0000" {
                var ERRMSG = data["errMsg"].stringValue
                let errCode = data["errCode"].stringValue
                if errCode == "4000" || errCode == "0001" {
                    let id = data["callbackId"].stringValue
                    if !id.isEmpty {
                        self.callbackId = id
                    }
                    
                    let ERRMSG = "간편인증이 완료되지 않았습니다. 앱에서 인증을 완료해주시기 바랍니다."
                    let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    })
                    self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                    return
                }
                let okAction = UIAlertAction(title: "확인", style: .default, handler: { _ in
                    GlobalFunction.CDHideLogoLoadingView()
                })
                GlobalFunction.FirLog(string: "간편인증3단계_인증실패_iOS")
                
                if ERRMSG.isEmpty {
                    ERRMSG = "잠시후 다시 시도해 주세요."
                }
                self.alert(title: "안내", message: ERRMSG, preferredStyle: .alert, actions: [okAction])
                return
            }
            
            var appendSwifyObj = [SwiftyJSONRealmObject]()
            let makeIncomeModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupIncomeModel.self, fromJson: makeJSON["data"]["INCOMELIST"])
            appendSwifyObj.append(contentsOf: makeIncomeModel)
            
            let makeReferModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupReferceListModel.self, fromJson: makeJSON["data"]["REFERECELIST"])
            appendSwifyObj.append(contentsOf: makeReferModel)
            
            let makeListModel = SwiftyJSONRealmObject.createObjList(ofType: CheckupListModel.self, fromJson: makeJSON["data"]["CHECKUPLIST"])
            appendSwifyObj.append(contentsOf: makeListModel)
            
            self.saveUserInfo()
            // 진료내역 로그인정보저장하기
            GlobalDefine.shared.saveCertParam = [String: String]()
            GlobalDefine.shared.saveCertParam.updateValue(self.birth, forKey: "JUMIN")
            
            Log.al("appendSwifyObj = \(appendSwifyObj)")
            CheckUpRealmProxy().append(appendSwifyObj)
            CheckUpRealmProxy().mergeToIncome(GlobalDefine.shared.saveCertParam["JUMIN"] ?? "")
            
            // 건강검진결과 서버로 전송하기
            var makeArray = [[String: String]]()
            let getIncomes = CheckUpRealmProxy().getIncomeModelList()
            
            for getModel in getIncomes {
                makeArray.append(getModel.toDict())
            }
            
            let makeJSON = JSON(["RESULT": "SUCCESS", "INCOMELIST": makeArray])
            
            if let cValue = AES256CBC.encryptCashdoc(makeJSON.rawString() ?? "") {
                let provider = CashdocProvider<CheckupService>()
                provider.CDRequest(.postCheckup(value: cValue)) { (cValue)  in
                    Log.al("cValue = \(cValue)")
                    
                    GlobalFunction.FirLog(string: "간편인증3단계_인증성공_iOS")
                    GlobalFunction.CDPopToRootViewController(animated: false)
                    UserDefaults.standard.set(true, forKey: UserDefaultKey.kIsLinked건강검진_new.rawValue)
                    if getIncomes.count == 0 {
                        let getBirth = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpBirth.rawValue) ?? "" 
                        GlobalFunction.pushToWebViewController(title: "건강 검진 결과", url: "\(API.HOME_WEB_URL)health/suggestion?nickname=\(self.name)&year=\(getBirth)", addfooter: false, hiddenbar: true)
                    } else {
                        HealthNavigator.pushShowCheckupStoryboard(identi: CheckupResultVC.reuseIdentifier)
                    }
                }
            }
        }
    }
    
    private func saveUserInfo() {
        var makeGender = 1
        if let gender = UserManager.shared.userModel?.gender {
            if gender == "f" {
                makeGender = 2
            }
        }
        UserDefaults.standard.set(self.birth, forKey: UserDefaultKey.kCheckUpBirth.rawValue)
        UserDefaults.standard.set(self.name, forKey: UserDefaultKey.kUserName.rawValue)
        UserDefaults.standard.set(self.phoneNum, forKey: UserDefaultKey.kPhoneNumber.rawValue)
        UserDefaults.standard.set(self.mobileType.rawValue, forKey: UserDefaultKey.kTelecomtype.rawValue)
        UserDefaults.standard.set(makeGender, forKey: UserDefaultKey.kCheckUpGender.rawValue)
    }
}
