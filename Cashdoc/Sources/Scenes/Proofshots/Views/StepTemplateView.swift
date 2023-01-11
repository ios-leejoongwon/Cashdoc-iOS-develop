//
//  StepTemplateView.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/22.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation

final class StepTemplateView: UIView {
    
    // MARK: - Properties
    
    private var step: Int = 0 {
        didSet {
            stepTemplate1View.changeStep(step: step)
            stepTemplate2View.changeStep(step: step)
            stepTemplate3View.changeStep(step: step)
            stepTemplate4View.changeStep(step: step)
            stepTemplate5View.changeStep(step: step)
            stepTemplate6View.changeStep(step: step)
            stepTemplate7View.changeStep(step: step)
            stepTemplate8View.changeStep(step: step)
            stepTemplate9View.changeStep(step: step)
            stepTemplate10View.changeStep(step: step)
            stepTemplate11View.changeStep(step: step)
        }
    }
    
//    private var minute: Int = 0 {
//        didSet {
//            var hoursString = String(format: "%02d", 0)
//            var minuteString = String(format: "%02d", minute)
//            if minute > 59 {
//                let hoursResult = minute / 60
//                let minuteResult = minute % 60
//                hoursString = String(format: "%02d", hoursResult)
//                minuteString = String(format: "%02d", minuteResult)
//            }
//        }
//    }
  
    private var templateType: Int = 1
    private var isDarkMode: Bool = false
    // 탬플릿
    private var stepTemplate1View: TemplateView!
    private var stepTemplate2View: TemplateView!
    private var stepTemplate3View: TemplateView!
    private var stepTemplate4View: TemplateView!
    private var stepTemplate5View: TemplateView!
    private var stepTemplate6View: TemplateView!
    private var stepTemplate7View: TemplateView!
    private var stepTemplate8View: TemplateView!
    private var stepTemplate9View: TemplateView!
    private var stepTemplate10View: TemplateView!
    private var stepTemplate11View: TemplateView!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        stepTemplate1View = TemplateView(typeNum: 1).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate2View = TemplateView(typeNum: 2).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate3View = TemplateView(typeNum: 3).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate4View = TemplateView(typeNum: 4).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate5View = TemplateView(typeNum: 5).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate6View = TemplateView(typeNum: 6).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate7View = TemplateView(typeNum: 7).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate8View = TemplateView(typeNum: 8).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate9View = TemplateView(typeNum: 9).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate10View = TemplateView(typeNum: 10).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate11View = TemplateView(typeNum: 11).then {
            self.addSubview($0)
            $0.backgroundColor = .clear
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
    }
    
    func changeTemplateType(type: Int) {
        templateType = type
        stepTemplate1View.isHidden = true
        stepTemplate2View.isHidden = true
        stepTemplate3View.isHidden = true
        stepTemplate4View.isHidden = true
        stepTemplate5View.isHidden = true
        stepTemplate6View.isHidden = true
        stepTemplate7View.isHidden = true
        stepTemplate8View.isHidden = true
        stepTemplate9View.isHidden = true
        stepTemplate10View.isHidden = true
        stepTemplate11View.isHidden = true
        switch type {
        case 1:
            stepTemplate1View.isHidden = false
        case 2:
            stepTemplate2View.isHidden = false
        case 3:
            stepTemplate3View.isHidden = false
        case 4:
            stepTemplate4View.isHidden = false
        case 5:
            stepTemplate5View.isHidden = false
        case 6:
            stepTemplate6View.isHidden = false
        case 7:
            stepTemplate7View.isHidden = false
        case 8:
            stepTemplate8View.isHidden = false
        case 9:
            stepTemplate9View.isHidden = false
        case 10:
            stepTemplate10View.isHidden = false
        case 11:
            stepTemplate11View.isHidden = false
        default:
            stepTemplate1View.isHidden = false
        }
    }
    
    func changeDarkMode(_ darkMode: Bool) {
        isDarkMode = darkMode
        stepTemplate1View.changeDarkModeView(isDarkMode)
        stepTemplate2View.changeDarkModeView(isDarkMode)
        stepTemplate3View.changeDarkModeView(isDarkMode)
        stepTemplate4View.changeDarkModeView(isDarkMode)
        stepTemplate5View.changeDarkModeView(isDarkMode)
        stepTemplate6View.changeDarkModeView(isDarkMode)
        stepTemplate7View.changeDarkModeView(isDarkMode)
        stepTemplate8View.changeDarkModeView(isDarkMode)
        stepTemplate9View.changeDarkModeView(isDarkMode)
        stepTemplate10View.changeDarkModeView(isDarkMode)
        stepTemplate11View.changeDarkModeView(isDarkMode)
    }
    
    func setStepsDateLabelText(_ dateData: Date) {
        Log.al("setStepsDateLabelText = \(dateData)")
        stepTemplate1View.changeDate(date: dateData)
        stepTemplate2View.changeDate(date: dateData)
        stepTemplate3View.changeDate(date: dateData)
        stepTemplate4View.changeDate(date: dateData)
        stepTemplate5View.changeDate(date: dateData)
        stepTemplate6View.changeDate(date: dateData)
        stepTemplate7View.changeDate(date: dateData)
        stepTemplate8View.changeDate(date: dateData)
        stepTemplate9View.changeDate(date: dateData)
        stepTemplate10View.changeDate(date: dateData)
        stepTemplate11View.changeDate(date: dateData) 
    }
    
    func startStepUpdates(step: Int) {
        DispatchQueue.main.async {
            self.step = step
        }
    }
}
