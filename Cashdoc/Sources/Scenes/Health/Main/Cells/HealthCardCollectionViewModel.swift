//
//  HealthCardCollectionViewModel.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/11/28.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation

final class HealthCardCollectionViewModel {
    var titleAttribute = NSMutableAttributedString()
    var rightImage = UIImage()
    var footerAttribute = NSMutableAttributedString()
    var footerLeftString = ""
    var footerLeftImageHidden = true
    var tagString = ""
    
    init(_ getType: HealthCardType) {
        switch getType {
        case .병원찾기:
            titleAttribute = enableTitleLabel("주변에 있는 병원/약국\n빠르게 찾아드려요.", high01: "병원/약국", high02: "찾아드려요.")
            tagString = "#응급실찾기  #야간진료  #일요일약국\n#진료시간  #진료과목찾기"
            rightImage = UIImage(named: "icPlaceBlue") ?? UIImage()
            footerAttribute = enableFooterLabel("병원/약국 찾기")
        case .보험:
            let getInsuRealm = InsuranListRealmProxy().getTotalAndPerson()
            tagString = "#내보험찾아줌  #보험가입내역조회\n#보험비교  #보험료다이어트"
            if getInsuRealm.count == 0 {
                titleAttribute = enableTitleLabel("흩어져 있는 내 보험료\n한 번에 모아드려요.", high01: "보험료", high02: "모아드려요.")
                footerAttribute = enableFooterLabel("내보험 모아보기")
                let rewardValue = UserDefaults.standard.string(forKey: UserDefaultKey.kRewardInsurance.rawValue) ?? "0"
                if rewardValue == "0" || UserManager.shared.pointModel?.insurance ?? 0 > 0 {
                    footerLeftString = ""
                } else {
                    footerLeftString = "        \(rewardValue)캐시   "
                    footerLeftImageHidden = false
                }
            } else {
                titleAttribute = enableTitleLabel("총 \(getInsuRealm.count)개의\n가입된 보험이 있습니다.", high01: "보험", high02: "")
                footerAttribute = NSMutableAttributedString()
                footerLeftString = "   매월 \(getInsuRealm.total.commaValue)원 납부 중   "
            }

            if getInsuRealm.count > 0, !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내보험다나와.rawValue) {
                rightImage = UIImage(named: "icCautionColor") ?? UIImage()
            } else {
                rightImage = UIImage(named: "icSearchBlue") ?? UIImage()
            }
        case .병원비:
            tagString = "#실비보험 #간편청구\n#청구서류준비 #내돈받기"
            if let getModel = GlobalDefine.shared.sendInvoiceModel {
                titleAttribute = enableTitleLabel("총 \(getModel.personCount)명이 병원비\n\(getModel.aTotal.commaValue)원을\n돌려받았습니다.", high01: "돌려받았습니다.", high02: "")
                rightImage = UIImage(named: "icCrossGreen") ?? UIImage()
                if getModel.hTotal > 0 {
                    footerLeftString = "   청구 가능한 내 병원비: \(getModel.hTotal.commaValue)원   "
                } else {
                    footerAttribute = enableFooterLabel("실비보험 청구하기")
                }
            }
        case .건강검진:
            tagString = "#국민건강보험 #검진대상자\n#종합건강검진 #비만도결과 #자가진단"
            let getIncomeRealm = CheckUpRealmProxy().getIncomeModel(nil)
            if getIncomeRealm.GUNYEAR.isNotEmpty {
                titleAttribute = enableTitleLabel("\(getIncomeRealm.GUNYEAR)년\n검진 결과가 확인되었습니다.", high01: getIncomeRealm.GUNYEAR, high02: "")
                if UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked건강검진_new.rawValue) {
                    rightImage = UIImage(named: "icHealthBlue") ?? UIImage()
                } else {
                    rightImage = UIImage(named: "icCautionColor") ?? UIImage()
                }
                footerAttribute = NSMutableAttributedString()
                if getIncomeRealm.CHECKUPORGAN.isEmpty {
                    footerLeftString = "   일반 검진 : -   "
                } else {
                    footerLeftString = "   일반 검진 : \(getIncomeRealm.CHECKUPORGAN)   "
                }
                footerLeftImageHidden = true
            } else {
                titleAttribute = enableTitleLabel("건강검진 결과 분석받고\n암 발생 위험도 알아보세요.", high01: "건강검진 결과", high02: "위험도 알아보세요.")
                rightImage = UIImage(named: "icHealthBlue") ?? UIImage()
                footerAttribute = enableFooterLabel("검진 결과 자세히 보기")
                
                let rewardValue = UserDefaults.standard.string(forKey: UserDefaultKey.kRewardCheckup.rawValue) ?? "0"
                if rewardValue == "0" || UserManager.shared.pointModel?.checkup ?? 0 > 0 {
                    footerLeftString = ""
                } else {
                    footerLeftString = "        \(rewardValue)캐시   "
                    footerLeftImageHidden = false
                }
            }
        case .진료내역:
            tagString = "#내진료기록 #진료비총액\n#투약내역확인 #처방전재발급"
            let getMedicRealm = MedicHistoryRealmProxy().getIneList(nil)
            if getMedicRealm.count == 0 {
                titleAttribute = enableTitleLabel("병원/약국 진료내역\n꼼꼼하게 모아드려요.", high01: "진료내역", high02: "모아드려요.")
                footerAttribute = enableFooterLabel("진료내역 조회하기")
                
                let rewardValue = UserDefaults.standard.string(forKey: UserDefaultKey.kRewardTreatment.rawValue) ?? "0"
                if rewardValue == "0" || UserManager.shared.pointModel?.treatment ?? 0 > 0 {
                    footerLeftString = ""
                } else {
                    footerLeftString = "        \(rewardValue)캐시   "
                    footerLeftImageHidden = false
                }
            } else {
                titleAttribute = enableTitleLabel("총 \(getMedicRealm.count)개의\n진료 내역이 있습니다.", high01: "", high02: "진료 내역")
                footerAttribute = NSMutableAttributedString()
                if let getLast = getMedicRealm.first {
                    let makeSplit = getLast.TREATMEDICALNM.split(separator: "[")
                    footerLeftString = "   최근방문-\(String(makeSplit.first ?? "-"))   "
                }
            }
            
            if getMedicRealm.count > 0, !UserDefaults.standard.bool(forKey: UserDefaultKey.kIsLinked내진료내역_new.rawValue) {
                rightImage = UIImage(named: "icCautionColor") ?? UIImage()
            } else {
                rightImage = UIImage(named: "icDetailBlue") ?? UIImage()
            }
        }
    }
    
    private func enableTitleLabel(_ text: String, high01: String, high02: String) -> NSMutableAttributedString {
        let makeAttribute = NSMutableAttributedString(string: text)
        let range01 = (makeAttribute.string as NSString).range(of: high01)
        let range02 = (makeAttribute.string as NSString).range(of: high02)
        makeAttribute.addAttributes([.foregroundColor: UIColor.blackCw], range: NSRange(location: 0, length: makeAttribute.length))
        makeAttribute.addAttributes([.foregroundColor: UIColor.blueCw], range: range01)
        makeAttribute.addAttributes([.foregroundColor: UIColor.blueCw], range: range02)
        makeAttribute.addAttributes([.font: UIFont.systemFont(ofSize: 18, weight: .medium)], range: range01)
        makeAttribute.addAttributes([.font: UIFont.systemFont(ofSize: 18, weight: .medium)], range: range02)
        return makeAttribute
    }
    
    private func enableFooterLabel(_ text: String ) -> NSMutableAttributedString {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        return NSMutableAttributedString(string: text, attributes: underlineAttribute)
    }
}
