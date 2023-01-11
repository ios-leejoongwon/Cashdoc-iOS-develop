//
//  CheckupExpandCell.swift
//  Cashdoc
//
//  Created by  주완 김 on 2020/05/20.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation

class CheckupExpandCell: UITableViewCell {
    enum StackCheckUpCase {
        case 총콜레
        case HDL콜레
        case 중성지방
        case LDL콜레
        case 혈청
        case 신사구
        case AST
        case ALT
        case GTP
    }
    
    @IBOutlet weak var stack01View: UIView!
    @IBOutlet weak var stack01Height: NSLayoutConstraint!
    @IBOutlet weak var cateImageView: UIImageView!
    @IBOutlet weak var cateLabel: UILabel!
    @IBOutlet weak var cateMarkView: CheckupMarkView!
    @IBOutlet weak var value01Label: UILabel!
    @IBOutlet weak var value02Label: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var stack02View: UIView!
    @IBOutlet weak var arrowButton: UIButton!
    @IBOutlet weak var expandStackView: UIStackView!
    
    // swiftlint:disable cyclomatic_complexity
    func drawCell(_ model: CheckupIncomeModel, index: Int) {
        let getGender = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpGender.rawValue) ?? ""
        expandStackView.isHidden = true
        value01Label.isHidden = false
        value02Label.isHidden = false
        stack01Height.constant = 88
        value02Label.textColor = .brownishGrayCw
        
        switch index {
        case 0:
            cateImageView.image = UIImage(named: "icMedicalFat")
            cateLabel.text = "비만"
            cateMarkView.getType = makeMarkType(model.BODYMASS, index: index)
            value01Label.text = "체질량지수"
            value02Label.text = model.BODYMASS
            if model.BODYMASS.isEmpty {
                cateMarkView.isHidden = true
                value02Label.text = "--"
            } else {
                cateMarkView.isHidden = false
            }
            let sizeInt = CGFloat((model.WAISTSIZE as NSString).floatValue)
            if getGender == "1", sizeInt >= 90 {
                descLabel.text = "정상범위 : 18.5~24.9\n허리둘레 \(model.WAISTSIZE)cm 로 복부비만에 해당\n(복부비만 범위 : 남 90cm이상, 여 85cm이상)"
            } else if getGender == "1", sizeInt >= 85 {
                descLabel.text = "정상범위 : 18.5~24.9\n허리둘레 \(model.WAISTSIZE)cm 로 복부비만에 해당\n(복부비만 범위 : 남 90cm이상, 여 85cm이상)"
            } else {
                descLabel.text = "정상범위 : 18.5~24.9\n허리둘레 \(model.WAISTSIZE)cm 로 정상에 해당\n(복부비만 범위 : 남 90cm이상, 여 85cm이상)"
            }
        case 1:
            cateImageView.image = UIImage(named: "icMedicalBloodPressure")
            cateLabel.text = "고혈압"
            cateMarkView.getType = makeMarkType(model.BLOODPRESS, index: index)
            value01Label.text = "혈압"
            value02Label.text = model.BLOODPRESS + " mmHg"
            if model.BLOODPRESS.isEmpty {
                cateMarkView.isHidden = true
                value02Label.text = "--"
            } else {
                cateMarkView.isHidden = false
            }
            descLabel.text = "정상범위 : 수축기 120mmHg미만/이완기 80mmHg 미만"
            if cateMarkView.getType == .주의 {
                descLabel.text = descLabel.text! + "\n\n고혈압 전단계에 해당됩니다. 건강관리에 주의하세요."
            } else if cateMarkView.getType == .위험 {
                descLabel.text = descLabel.text! + "\n\n고혈압이 의심됩니다. 건강 상태를 확인하세요."
            }
        case 2:
            cateImageView.image = UIImage(named: "icMedicalAnemia")
            cateLabel.text = "빈혈"
            cateMarkView.getType = makeMarkType(model.HEMOGLOBIN, index: index)
            value01Label.text = "혈색소"
            value02Label.text = model.HEMOGLOBIN + "g/dL"
            if model.HEMOGLOBIN.isEmpty {
                cateMarkView.isHidden = true
                value02Label.text = "--"
            } else {
                cateMarkView.isHidden = false
            }
            if getGender == "1" {
                descLabel.text = "정상범위 : 14~17.5 g/dL"
            } else {
                descLabel.text = "정상범위 : 12.5~16.5 g/dL"
            }
            if cateMarkView.getType == .주의 {
                descLabel.text = descLabel.text! + "\n\n빈혈을 주의하세요."
            } else if cateMarkView.getType == .위험 {
                descLabel.text = descLabel.text! + "\n\n빈혈이 의심됩니다."
            }
        case 3:
            cateImageView.image = UIImage(named: "icMedicalDiabetes")
            cateLabel.text = "당뇨병"
            cateMarkView.getType = makeMarkType(model.BLOODSUGAR, index: index)
            value01Label.text = "공복혈당"
            value02Label.text = model.BLOODSUGAR + "mg/dL"
            if model.BLOODSUGAR.isEmpty {
                cateMarkView.isHidden = true
                value02Label.text = "--"
            } else {
                cateMarkView.isHidden = false
            }
            descLabel.text = "정상범위 : 100 mg/dL 미만"
            if cateMarkView.getType == .주의 {
                descLabel.text = descLabel.text! + "\n\n공복혈당 장애 및 당뇨병을 주의하세요."
            } else if cateMarkView.getType == .위험 {
                descLabel.text = descLabel.text! + "\n\n빈혈이 의심됩니다."
            }
        case 4:
            cateImageView.image = UIImage(named: "icMedicalOsteoporosis")
            cateLabel.text = "골다공증"
            cateMarkView.getType = makeMarkType(model.OSTEOPOROSIS, index: index)
            value01Label.text = "T-score"
            value02Label.text = model.OSTEOPOROSIS
            if model.OSTEOPOROSIS.isEmpty {
                cateMarkView.isHidden = true
                value02Label.text = "--"
            } else {
                cateMarkView.isHidden = false
            }
            descLabel.text = "정상범위 : -0.9 이상"
            if cateMarkView.getType == .주의 {
                descLabel.text = descLabel.text! + "\n\n골다소증이 의심됩니다."
            } else if cateMarkView.getType == .위험 {
                descLabel.text = descLabel.text! + "\n\n골다공증이 의심됩니다."
            }
        case 5:
            cateImageView.image = UIImage(named: "icMedicalHigh")
            cateLabel.text = "이상지질혈증"
            value01Label.isHidden = true
            value02Label.isHidden = true
            stack01Height.constant = 184
            cateMarkView.isHidden = true
            expandStackView.isHidden = false
            expandStackView.removeAllArrangedSubviews()
            descLabel.text = "정상범위\n- 총 콜레스테롤 : 200 mg/dL 미만\n- HDL 콜레스테롤 : 50 mg/dL 이상\n- 중성지방 : 150 mg/dL 미만\n- LDL 콜레스테롤 : 100 mg/dL 미만"
            
            for i in 0...3 {
                let makeSubview = UIView().then {
                    $0.snp.makeConstraints { (m) in
                        m.height.equalTo(20)
                        m.width.equalTo(210)
                    }
                }
                let makeValueLabel03 = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-16)
                        m.centerY.equalToSuperview()
                    }
                }
                let makeValueLabel02 = UILabel().then {
                    $0.text = "--"
                    $0.textColor = .brownishGray
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-48)
                        m.centerY.equalToSuperview()
                    }
                }
                let makeValueLabel01 = UILabel().then {
                    $0.textColor = .black
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    
                    $0.snp.makeConstraints { (m) in
                        m.left.equalToSuperview()
                        m.centerY.equalToSuperview()
                    }
                }
                switch i {
                case 0:
                    let getValue = model.TOTCHOLESTEROL
                    makeValueLabel01.text = "총 콜레스테롤"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue)mg/dL"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .총콜레, descLabel: descLabel)
                case 1:
                    let getValue = model.HDLCHOLESTEROL
                    makeValueLabel01.text = "HDL 콜레스테롤"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue)mg/dL"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .HDL콜레, descLabel: descLabel)
                case 2:
                    let getValue = model.TRIGLYCERIDE
                    makeValueLabel01.text = "중성지방"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue)mg/dL"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .중성지방, descLabel: descLabel)
                case 3:
                    let getValue = model.LDLCHOLESTEROL
                    makeValueLabel01.text = "LDL 콜레스테롤"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue)mg/dL"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .LDL콜레, descLabel: descLabel)
                default:
                    break
                }
                expandStackView.addArrangedSubview(makeSubview)
            }
        case 6:
            cateImageView.image = UIImage(named: "icMedicalKidneyDisease")
            cateLabel.text = "신장질환"
            value01Label.isHidden = true
            value02Label.isHidden = true
            stack01Height.constant = 120
            cateMarkView.isHidden = true
            expandStackView.isHidden = false
            expandStackView.removeAllArrangedSubviews()
            descLabel.text = "정상범위\n- 혈청크레아닌 : 1.2 mg/dL 이하\n- 신사구여과율 : 60 이상 (mL/min/1.73 m²)"
            var isDanger = false
            
            for i in 0...1 {
                let makeSubview = UIView().then {
                    $0.snp.makeConstraints { (m) in
                        m.height.equalTo(20)
                        m.width.equalTo(262)
                    }
                }
                let makeValueLabel03 = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-16)
                        m.centerY.equalToSuperview()
                    }
                }
                let makeValueLabel02 = UILabel().then {
                    $0.text = "--"
                    $0.textColor = .brownishGray
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-48)
                        m.centerY.equalToSuperview()
                    }
                }
                let makeValueLabel01 = UILabel().then {
                    $0.textColor = .black
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    
                    $0.snp.makeConstraints { (m) in
                        m.left.equalToSuperview()
                        m.centerY.equalToSuperview()
                    }
                }
                switch i {
                case 0:
                    let getValue = model.SERUMCREATININE
                    makeValueLabel01.text = "혈청크레아닌"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue)mg/dL"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .혈청, descLabel: descLabel)
                    if makeValueLabel03.text == "위험" {
                        isDanger = true
                    }
                case 1:
                    let getValue = model.GFR
                    makeValueLabel01.text = "신사구여과율"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue)(mL/min/1.73 m²)"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .신사구, descLabel: descLabel)
                    if makeValueLabel03.text == "위험" {
                        isDanger = true
                    }
                default:
                    break
                }
                expandStackView.addArrangedSubview(makeSubview)
            }
            
            if isDanger {
                descLabel.text = descLabel.text! + "\n\n신장기능 이상이 의심됩니다."
            }
        case 7:
            cateImageView.image = UIImage(named: "icMedicalHeart")
            cateLabel.text = "간장질환"
            value01Label.isHidden = true
            value02Label.isHidden = true
            stack01Height.constant = 152
            cateMarkView.isHidden = true
            expandStackView.isHidden = false
            expandStackView.removeAllArrangedSubviews()
            var makeGTPment = "- 감마지티피(γ-GTP) : 11~73.9 U/L"
            if getGender == "2" {
                makeGTPment = "- 감마지티피(γ-GTP) : 8~37.9 U/L"
            }
            descLabel.text = "정상범위\n- AST(SGOT) : 41 U/L 미만\n- ALT(SGPT) : 41 U/L 미만 영향\n\(makeGTPment)"
            var isDanger = false
            var isWarning = false
            
            for i in 0...2 {
                let makeSubview = UIView().then {
                    $0.snp.makeConstraints { (m) in
                        m.height.equalTo(20)
                        m.width.equalTo(211)
                    }
                }
                let makeValueLabel03 = UILabel().then {
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-16)
                        m.centerY.equalToSuperview()
                    }
                }
                let makeValueLabel02 = UILabel().then {
                    $0.text = "--"
                    $0.textColor = .brownishGray
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    $0.snp.makeConstraints { (m) in
                        m.right.equalToSuperview().offset(-48)
                        m.centerY.equalToSuperview()
                    }
                }
                let makeValueLabel01 = UILabel().then {
                    $0.textColor = .black
                    $0.font = UIFont.systemFont(ofSize: 14)
                    makeSubview.addSubview($0)
                    
                    $0.snp.makeConstraints { (m) in
                        m.left.equalToSuperview()
                        m.centerY.equalToSuperview()
                    }
                }
                switch i {
                case 0:
                    let getValue = model.SGOT
                    makeValueLabel01.text = "AST(SGOT)"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue) U/L"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .AST, descLabel: descLabel)
                case 1:
                    let getValue = model.SGPT
                    makeValueLabel01.text = "ALT(SGPT)"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue) U/L"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .ALT, descLabel: descLabel)
                case 2:
                    let getValue = model.YGPT
                    makeValueLabel01.text = "감마지티피(γ-GTP)"
                    if getValue.isNotEmpty {
                        makeValueLabel02.text = "\(getValue) U/L"
                    }
                    makeStateLabel(makeValueLabel03, value: getValue, type: .GTP, descLabel: descLabel)
                default:
                    break
                }
                
                if makeValueLabel03.text == "주의" {
                    isWarning = true
                } else if makeValueLabel03.text == "위험" {
                    isDanger = true
                }
                expandStackView.addArrangedSubview(makeSubview)
            }
            
            if isDanger {
                descLabel.text = descLabel.text! + "\n\n간기능 이상이 의심됩니다."
            } else if isWarning {
                descLabel.text = descLabel.text! + "\n\n간기능을 관리해주세요."
            }
        case 8:
            cateImageView.image = UIImage(named: "icMedicalUrinalysis")
            cateLabel.text = "요검사"
            cateMarkView.isHidden = true
            value01Label.text = "요단백"
            value02Label.text = model.YODANBAK
            let yodanType = makeMarkType(model.YODANBAK, index: index)
            value02Label.text = yodanType.rawValue

            if model.YODANBAK.isEmpty {
                value02Label.text = "없음"
                value02Label.textColor = .brownishGrayCw
            } else if yodanType == .정상 {
                value02Label.textColor = .blueCw
            } else if yodanType == .위험 {
                value02Label.textColor = .redCw
            } else if yodanType == .주의 {
                value02Label.textColor = UIColor.fromRGB(60, 175, 16)
            } else {
                value02Label.textColor = .brownishGrayCw
            }
            
            if model.YODANBAK.isEmpty {
                descLabel.text = "검진 내역이 없습니다."
            } else if yodanType == .주의 {
                descLabel.text = "단백뇨를 주의해주세요."
            } else if yodanType == .위험 {
                descLabel.text = "단백뇨가 의심됩니다."
            } else {
                descLabel.text = "지금처럼 관리해주세요."
            }
        default:
            break
        }
    }
    
    private func makeMarkType(_ value: String, index: Int) -> MarkCase {
        let makeValueFloat = CGFloat((value as NSString).floatValue)
        
        switch index {
        case 0: // 비만
            switch makeValueFloat {
            case 0...18.4:
                return .주의
            case 18.5...24.9:
                return .정상
            case 25...29.9:
                return .주의
            default:
                return .위험
            }
        case 1: // 혈압
            let getSplit = value.split(separator: "/")
            let makeValueFloat01 = CGFloat(((getSplit.first ?? "") as NSString).floatValue)
            let makeValueFloat02 = CGFloat(((getSplit.last ?? "") as NSString).floatValue)
            var makeState: MarkCase = .정상
            switch makeValueFloat01 {
            case 120...139.9:
                makeState = .주의
            case 140...300:
                makeState = .위험
            default:
                break
            }
            switch makeValueFloat02 {
            case 80...89.9:
                return makeState == .위험 ? .위험 : .주의
            case 90...300:
                return .위험
            default:
                break
            }
            return makeState
        case 2: // 빈혈
            let getGender = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpGender.rawValue) ?? ""
            
            if getGender == "1" {
                switch makeValueFloat {
                case 11...13.9:
                    return .주의
                case 14...17.5:
                    return .정상
                default:
                    return .위험
                }
            } else {
                switch makeValueFloat {
                case 10...12.4:
                    return .주의
                case 12.5...16.5:
                    return .정상
                default:
                    return .위험
                }
            }
        case 3: // 당뇨병
            switch makeValueFloat {
            case 0...99.9:
                return .정상
            case 100...125.9:
                return .주의
            default:
                return .위험
            }
        case 4: // 골다골증
            switch makeValueFloat {
            case (-0.9)...(4.0):
                return .정상
            case (-2.4)...(-1.0):
                return .주의
            default:
                return .위험
            }
        case 8: // 요검사
            switch value {
            case "양성":
                return .위험
            case "음성":
                return .정상
            default:
                return .주의
            }
        default:
            break
        }
        
        return .정상
    }
    
    private func makeStateLabel(_ label: UILabel, value: String, type: StackCheckUpCase, descLabel: UILabel) {
        let makeValueFloat = CGFloat((value as NSString).floatValue)

        // 값이 없을경우에는 그냥 없음으로 표시
        if value.isEmpty {
            label.text = "없음"
        } else {
            switch type {
            case .총콜레:
                switch makeValueFloat {
                case 0...199.9:
                    label.text = "정상"
                case 200...229.9:
                    label.text = "주의"
                    addWarningMent(descLabel, ment: "\n총 콜레스테롤을 관리해주세요.")
                default:
                    label.text = "위험"
                    addWarningMent(descLabel, ment: "\n총 콜레스테롤 질환이 의심됩니다.")
                }
            case .HDL콜레:
                switch makeValueFloat {
                case 0...39:
                    label.text = "위험"
                    addWarningMent(descLabel, ment: "\nHDL 콜레스테롤 관리가 필요합니다.")
                case 40...49:
                    label.text = "주의"
                    addWarningMent(descLabel, ment: "\n고콜레스테롤혈중이 의심됩니다.")
                default:
                    label.text = "정상"
                }
            case .중성지방:
                switch makeValueFloat {
                case 0...149.9:
                    label.text = "정상"
                case 150...199.9:
                    label.text = "주의"
                    addWarningMent(descLabel, ment: "\n고중성지방형증이 의심됩니다.")
                default:
                    label.text = "위험"
                    addWarningMent(descLabel, ment: "\n중성지방 관리가 필요합니다.")
                }
            case .LDL콜레:
                switch makeValueFloat {
                case 0...99.9:
                    label.text = "정상"
                case 100...129.9:
                    label.text = "주의"
                    addWarningMent(descLabel, ment: "\n낮은 HDL콜레스테롤이 의심됩니다.")
                default:
                    label.text = "위험"
                    addWarningMent(descLabel, ment: "\nLDL 콜레스테롤 관리가 필요합니다.")
                }
            case .혈청:
                switch makeValueFloat {
                case 0...1.2:
                    label.text = "정상"
                default:
                    label.text = "위험"
                }
            case .신사구:
                switch makeValueFloat {
                case 0...59.9:
                    label.text = "위험"
                default:
                    label.text = "정상"
                }
            case .AST, .ALT:
                switch makeValueFloat {
                case 0...40.9:
                    label.text = "정상"
                case 41...80.9:
                    label.text = "주의"
                default:
                    label.text = "위험"
                }
            case .GTP:
                let getGender = UserDefaults.standard.string(forKey: UserDefaultKey.kCheckUpGender.rawValue) ?? ""
                
                if getGender == "1" {
                    switch makeValueFloat {
                    case 11...73.9:
                        label.text = "정상"
                    case 74...300.9:
                        label.text = "주의"
                    default:
                        label.text = "위험"
                    }
                } else {
                    switch makeValueFloat {
                    case 8...37.9:
                        label.text = "정상"
                    case 38...150.9:
                        label.text = "주의"
                    default:
                        label.text = "위험"
                    }
                }
            }
        }
        
        if label.text == "정상" {
            label.textColor = .blueCw
        } else if label.text == "위험" {
            label.textColor = .redCw
        } else if label.text == "주의" {
            label.textColor = UIColor.fromRGB(60, 175, 16)
        } else {
            label.textColor = .black
        }
    }
    
    private func addWarningMent(_ label: UILabel, ment: String) {
        if !(descLabel.text?.contains(".") ?? false) {
            descLabel.text = descLabel.text! + "\n"
        }

        descLabel.text = descLabel.text! + ment
    }
}
