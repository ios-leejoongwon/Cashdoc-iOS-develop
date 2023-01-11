//
//  CheckupHeaderView.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/22.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RxSwift
import SwiftyJSON

class CheckupHeaderView: UIView {
    @IBOutlet weak var checkDateBtn: UIButton!
    @IBOutlet weak var hospitalLabel: UILabel!
    @IBOutlet weak var checkBannerLabel: UILabel!
    @IBOutlet weak var checkBannerBtn: UIButton!
    @IBOutlet weak var checkBannerView: UIView!
    @IBOutlet weak var doctorView: UIView!
    @IBOutlet weak var doctorLabel: UILabel!
    @IBOutlet weak var doctorDetailLabel: UILabel!
    @IBOutlet weak var doctorDetailImage: UIImageView!
    @IBOutlet weak var basicHeightLabel: UILabel!
    @IBOutlet weak var basicWeightLabel: UILabel!
    @IBOutlet weak var basicSizeLabel: UILabel!
    @IBOutlet weak var eyeLeftLabel: UILabel!
    @IBOutlet weak var eyeRightLabel: UILabel!
    @IBOutlet weak var hearLeftLabel: UILabel!
    @IBOutlet weak var hearRightLabel: UILabel!
    @IBOutlet weak var hearMarkWidth: NSLayoutConstraint!
    @IBOutlet weak var hearMarkView: CheckupMarkView!
    
    var getCheckupResultVC: CheckupResultVC?
    var disposeBag = DisposeBag()
    var haveCheckValue = false
    
    func drawWithModel(_ model: CheckupIncomeModel) {
        hospitalLabel.text = model.CHECKUPORGAN
        let makeDate = model.CHECKUPDATE.simpleDateFormat("yyyyMMdd")
        checkDateBtn.setTitle(makeDate.simpleDateFormat("   검진일자 : yyyy. MM. dd      "), for: .normal)
        if model.CHECKUPOPINION.isEmpty {
            doctorLabel.text = "작성된 소견이 없습니다."
        } else {
            doctorLabel.text = model.CHECKUPOPINION
        }
        basicHeightLabel.text = model.HEIGHT + "cm"
        basicWeightLabel.text = model.WEIGHT + "kg"
        basicSizeLabel.text = model.WAISTSIZE + "cm"
        let makeSightSplit = model.SIGHT.split(separator: "/")
        eyeLeftLabel.text = "\(makeSightSplit.first ?? "")"
        eyeRightLabel.text = "\(makeSightSplit.last ?? "")"
        let makeHearSplit = model.HEARING.split(separator: "/")
        hearLeftLabel.text = "\(makeHearSplit.first ?? "")"
        hearRightLabel.text = "\(makeHearSplit.last ?? "")"

        self.markHear(left: String(makeHearSplit.first ?? ""), right: String(makeHearSplit.last ?? ""))
    }
    
    func changeCheckBanner(risk: String, highRisk: String, doctorMent: String) {
        disposeBag = DisposeBag()
        
        let makeDummyLabel = UILabel().then {
            $0.text = doctorMent
            $0.font = UIFont.systemFont(ofSize: 14)
            $0.numberOfLines = 0
            $0.frame = CGRect(x: 0, y: 0, width: ScreenSize.WIDTH - 64, height: 1000)
            $0.sizeToFit()
        }
        
        if makeDummyLabel.frame.size.height < 50 {
            doctorDetailLabel.isHidden = true
            doctorDetailImage.isHidden = true
        } else {
            doctorDetailLabel.isHidden = false
            doctorDetailImage.isHidden = false
            doctorView.rx.tapGesture().when(.recognized)
                .bind { [weak self] (_) in
                    if let viewcon = UIStoryboard.init(name: "Checkup", bundle: nil).instantiateViewController(withIdentifier: "CheckupOpnionVC") as? CheckupOpnionVC {
                        guard let self = self else { return }
                        if let getIncome = self.getCheckupResultVC?.checkIncomeModel {
                            viewcon.getModel = getIncome
                        }
                        GlobalFunction.pushVC(viewcon, animated: true)
                    }
            }.disposed(by: disposeBag)
        }
        
        let convertDate = GlobalDefine.shared.checkDateString?.convertDateFormat(beforeFormat: "yyyyMMdd", afterFormat: "yyyy-MM-dd") ?? ""
        
        if risk == "-" {
            checkBannerLabel.text = "\(GlobalFunction.cut4Nickname())님, 무료로\n암 발생 위험도를 분석 받아볼까요?"
            checkBannerBtn.setTitle("   시작하기     ", for: .normal)
            checkBannerView.rx.tapGesture().when(.recognized)
                .bind { (_) in
                    let userName = UserDefaults.standard.string(forKey: UserDefaultKey.kUserName.rawValue) ?? ""
                    GlobalFunction.pushToWebViewController(title: "문진작성", url: "\(API.HOME_WEB_URL)health/question?date=\(convertDate)&nickname=\(userName)", hiddenbar: true)
            }.disposed(by: disposeBag)
        } else {
            checkBannerLabel.text = "분석된 암 발생 위험도를 확인해 보세요\n고위험 \(highRisk)개 / 위험 \(risk)개"
            checkBannerBtn.setTitle("   요약정보 보기     ", for: .normal)
            let convertDate = GlobalDefine.shared.checkDateString?.convertDateFormat(beforeFormat: "yyyyMMdd", afterFormat: "yyyy-MM-dd") ?? ""
            
            checkBannerView.rx.tapGesture().when(.recognized)
                .bind { (_) in
                    let userName = UserDefaults.standard.string(forKey: UserDefaultKey.kUserName.rawValue) ?? ""
                    GlobalFunction.pushToWebViewController(title: "검진 결과 분석", url: "\(API.HOME_WEB_URL)health/result?date=\(convertDate)&nickname=\(userName)")
            }.disposed(by: disposeBag)
        }
    }
    
    private func markHear(left: String, right: String) {
        if left.isEmpty || right.isEmpty {
            hearMarkView.isHidden = true
        } else if left == "이상" || right == "이상" {
            hearMarkView.isHidden = false
            hearMarkView.getType = .질환의심
            hearMarkWidth.constant = 55
        } else {
            hearMarkView.isHidden = false
            hearMarkView.getType = .정상
            hearMarkWidth.constant = 35
        }
    }
    
    @IBAction func changeDateAct() {
        let getIncomes = CheckUpRealmProxy().getIncomeModelList()
        var makeItems = [String]()
        var makeDates = [String]()

        for model in getIncomes {
            makeItems.append("일반 검진")
            makeDates.append(model.CHECKUPDATE)
        }
        
        GlobalFunction.CDActionSheet("검진 결과 선택", items: makeItems, subStrings: makeDates.reversed()) { (_, name) in
            self.getCheckupResultVC?.refreshData(name)
        }
    }
}
