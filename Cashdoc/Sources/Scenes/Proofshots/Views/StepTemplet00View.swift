//
//  StepTemplet00View.swift
//  Cashwalk
//
//  Created by lovelycat on 2021/04/22.
//  Copyright © 2021 Cashwalk, Inc. All rights reserved.
//

import Foundation

final class StepTemplet00View: UIView {
    
    // MARK: - Properties
    
    private var step: Int = 0 {
        didSet {
            stepTemplate1View.stepCountLabel.text = "\(step)"
            stepTemplate2View.stepCountLabel.text = "\(step)"
            stepTemplate3View.stepCountLabel.text = "\(step)"
            stepTemplate4View.stepCountLabel.text = "\(step)걸음"
            stepTemplate5View.stepCountLabel.text = "\(step)걸음"
            stepTemplate6View.stepCountLabel.text = "\(step)걸음"
            stepTemplate7View.stepCountLabel.text = "\(step)steps"
            stepTemplate8View.stepCountLabel.text = "\(step)걸음"
            stepTemplate9View.stepCountLabel.text = "\(step)"
            stepTemplate10View.stepCountLabel.text = "\(step)걸음"
            stepTemplate11View.stepCountLabel.text = "\(step)"
        }
    }
    private var kcal: Int = 0 {
        didSet {
//            stepTemplate1View.kcalCountLabel.text = "\(kcal.stringValue)Kcal"
//            stepTemplate2View.kcalCountLabel.text = "\(kcal.stringValue)Kcal"
//            stepTemplate3View.kcalCountLabel.text = "\(kcal.stringValue)Kcal"
//            stepTemplate4View.kcalCountLabel.text = "\(kcal.stringValue)Kcal"
//            stepTemplate5View.kcalCountLabel.text = "\(kcal.stringValue)Kcal"
//            stepTemplate6View.kcalCountLabel.text = "\(kcal.stringValue)Kcal"
        }
    }
    private var minute: Int = 0 {
        didSet {
            var hoursString = String(format: "%02d", 0)
            var minuteString = String(format: "%02d", minute)
            if minute > 59 {
                let hoursResult = minute / 60
                let minuteResult = minute % 60
                hoursString = String(format: "%02d", hoursResult)
                minuteString = String(format: "%02d", minuteResult)
            }
            stepTemplate1View.minuteCountLabel.text = "\(hoursString):\(minuteString)"
            stepTemplate2View.minuteCountLabel.text = "\(hoursString):\(minuteString)"
            stepTemplate3View.minuteCountLabel.text = "\(hoursString):\(minuteString)"
            stepTemplate4View.minuteCountLabel.text = "\(hoursString):\(minuteString)"
            stepTemplate5View.minuteCountLabel.text = "\(hoursString):\(minuteString)"
            stepTemplate6View.minuteCountLabel.text = "\(hoursString):\(minuteString)"
        }
    }
    private var meter: Double = 0 {
        didSet {
            var distance: String = ""
            var unit: String = ""
//            if meter > 1000 {
//                let meterResult = meter/1000
//                distance = meterResult.fixedFraction(digits: 1)
//                unit = "km"
//            } else {
//                distance = meter.fixedFraction(digits: 1)
//                unit = "m"
//            }
            stepTemplate1View.distanceCountLabel.text = "\(distance)\(unit)"
            stepTemplate2View.distanceCountLabel.text = "\(distance)\(unit)"
            stepTemplate3View.distanceCountLabel.text = "\(distance)\(unit)"
            stepTemplate4View.distanceCountLabel.text = "\(distance)\(unit)"
            stepTemplate5View.distanceCountLabel.text = "\(distance)\(unit)"
            stepTemplate6View.distanceCountLabel.text = "\(distance)\(unit)"
        }
    }
    
    private var templateType: Int = 1
    private var isDarkMode: Bool = false
    // 탬플릿
    private var stepTemplate1View: StepTemplate1View!
    private var stepTemplate2View: StepTemplate2View!
    private var stepTemplate3View: StepTemplate3View!
    private var stepTemplate4View: StepTemplate4View!
    private var stepTemplate5View: StepTemplate5View!
    private var stepTemplate6View: StepTemplate6View!
    private var stepTemplate7View: StepTemplate7View!
    private var stepTemplate8View: StepTemplate8View!
    private var stepTemplate9View: StepTemplate9View!
    private var stepTemplate10View: StepTemplate10View!
    private var stepTemplate11View: StepTemplate11View!
    
    // MARK: - Con(De)structor
    
    convenience init() {
        self.init(frame: .zero)
        
        stepTemplate1View = StepTemplate1View().then {
            self.addSubview($0)
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate2View = StepTemplate2View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate3View = StepTemplate3View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate4View = StepTemplate4View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate5View = StepTemplate5View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate6View = StepTemplate6View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate7View = StepTemplate7View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate8View = StepTemplate8View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate9View = StepTemplate9View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate10View = StepTemplate10View().then {
            self.addSubview($0)
            $0.isHidden = true
            $0.snp.makeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        stepTemplate11View = StepTemplate11View().then {
            self.addSubview($0)
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
        let month = String(format: "%02d", dateData.month)
        let day = String(format: "%02d", dateData.day)
        let stepsDateString = "\(dateData.year)-\(month)-\(day)"
        let stepsDateKor = "\(dateData.year)년 \(month)월 \(day)일"
        stepTemplate1View.stepsDateLabel.text = stepsDateString
        stepTemplate2View.stepsDateLabel.text = stepsDateString
        stepTemplate3View.stepsDateLabel.text = stepsDateString
        stepTemplate4View.stepsDateLabel.text = stepsDateString
        stepTemplate5View.stepsDateLabel.text = stepsDateString
        stepTemplate6View.stepsDateLabel.text = stepsDateString
        stepTemplate7View.stepsDateLabel.text = stepsDateString
        stepTemplate8View.stepsDateLabel.text = stepsDateKor
        stepTemplate9View.stepsDateLabel.text = stepsDateString
        stepTemplate10View.stepsDateLabel.text = stepsDateKor
        stepTemplate11View.stepsDateLabel.text = stepsDateString
    }
    
    func stepProgressRingStartProgress(_ value: CGFloat) {
        stepTemplate1View.stepProgressRing.startProgress(to: CGFloat(value), duration: 0.5)
        stepTemplate11View.stepProgressRing.startProgress(to: CGFloat(value), duration: 0.5)
    }
    
    func setDataStackViewWidth() {
        stepTemplate6View.setDataStackViewWidth()
    }
    
    func startStepUpdates(step: Int) {
        DispatchQueue.main.async {
            self.step = step
            self.updateCalMinDist(step: step)
            self.setDataStackViewWidth()
        }
    }
    
    // MARK: - Private methods
    
    private func updateCalMinDist(step: Int) {
//        let height: Double = Double(UserManager.shared.height ?? 0 > 110 ? UserManager.shared.height ?? 0 : 165)
//        let weight: Double = Double(UserManager.shared.weight ?? 0 > 30 ? UserManager.shared.weight ?? 0 : 35)
        
//        let meter = (Double(step) * (height - 100.0)) / 100.0
//        var calPerMile = 3.7103
//        calPerMile += 0.2678 * weight
//        calPerMile += (0.0359 * weight * 60 * 0.0006213 * 2 * weight)
//        let cal = meter * calPerMile * 0.0006213
//        let minute = meter / 1000 * 14
//        
//        self.kcal = Int(cal)
//        self.minute = Int(minute)
//        self.meter = meter
    }
}
