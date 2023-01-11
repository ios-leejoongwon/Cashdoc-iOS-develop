//
//  YearToDatePickerView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 26/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//
protocol YearToDatePickerViewDelegate: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
}

final class YearToDatePickerView: UIPickerView {
    
    // MARK: - Properties
    
    var months: [Int]!
    var years: [Int]!
    var days: [Int]!
    var hours: [Int]!
    var minutes: [Int]!
    
    var year = Calendar.current.component(.year, from: Date()) {
        didSet {
            selectRow(years.firstIndex(of: year)!, inComponent: 1, animated: true)
        }
    }
    
    var month = Calendar.current.component(.month, from: Date()) {
        didSet {
            selectRow(month - 1, inComponent: 0, animated: false)
        }
    }
    
    var day = Calendar.current.component(.day, from: Date()) {
        didSet {
            selectRow(day - 1, inComponent: 0, animated: false)
        }
    }
    
    var hour = Calendar.current.component(.hour, from: Date()) {
        didSet {
            selectRow(hour, inComponent: 0, animated: false)
        }
    }
    
    var minute = Calendar.current.component(.minute, from: Date()) {
        didSet {
            selectRow(minute, inComponent: 0, animated: false)
        }
    }
    
    var onDateSelected: ((_ month: Int, _ year: Int) -> Void)?
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setup() {
        self.setValue(UIColor.white, forKey: "backgroundColor")
        var years: [Int] = []
        if years.count == 0 {
            for year in 1900...2100 {
                years.append(year)
            }
        }
        self.years = years
        
        var months: [Int] = []
        for month in 1...12 {
            months.append(month)
        }
        self.months = months
        
        var days: [Int] = []
        
        for day in 1...totalDays(year: self.year, month: self.month) {
            days.append(day)
        }
        self.days = days
        
        var hours: [Int] = []
        if hours.count == 0 {
            for hour in 0...23 {
                hours.append(hour)
            }
        }
        self.hours = hours
        
        var minutes: [Int] = []
        for minute in 0...59 {
            minutes.append(minute)
        }
        self.minutes = minutes
        
        self.delegate = self
        self.dataSource = self
        
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())
        let currentMonth = Calendar(identifier: .gregorian).component(.month, from: Date())
        let currentDay = Calendar(identifier: .gregorian).component(.day, from: Date())
        let currentHour = Calendar(identifier: .gregorian).component(.hour, from: Date())
        let currentMinute = Calendar(identifier: .gregorian).component(.minute, from: Date())
        
        self.selectRow(currentYear - 1900, inComponent: 0, animated: false)
        self.selectRow(currentMonth - 1, inComponent: 1, animated: false)
        self.selectRow(currentDay - 1, inComponent: 2, animated: false)
        self.selectRow(currentHour, inComponent: 3, animated: false)
        self.selectRow(currentMinute, inComponent: 4, animated: false)
    }
}

extension YearToDatePickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return String(years[row]) + "년"
        case 1:
            return String(months[row]) + "월"
        case 2:
            return String(days[row]) + "일"
        case 3:
            return String(hours[row]) + "시"
        case 4:
            return String(minutes[row]) + "분"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let view = view as? UILabel { label = view }
        label.setFontToRegular(ofSize: 20)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        switch component {
        case 0:
            label.text = String(years[row]) + "년"
        case 1:
            label.text = String(months[row]) + "월"
        case 2:
            label.text = String(days[row]) + "일"
        case 3:
            label.text = String(hours[row]) + "시"
        case 4:
            label.text = String(minutes[row]) + "분"
        default:
            label.text = nil
        }
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 || component == 1 {
            let y = pickerView.selectedRow(inComponent: 0) + 1900
            let m = pickerView.selectedRow(inComponent: 1) + 1
            self.days.removeAll()
            for day in 1...totalDays(year: y, month: m) {
                self.days.append(day)
            }
            self.reloadComponent(2)
        }
    }
      
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        switch component {
        case 0:
            return 70
        default:
            return 50
        }
    }
    
    func totalDays(year: Int, month: Int) -> Int {
        let cal = Calendar.current
        let y = year
        let m = month
        var comps = DateComponents(calendar: cal, year: y, month: m)
        comps.setValue(m + 1, for: .month)
        comps.setValue(0, for: .day)
        let date = cal.date(from: comps)!
        return cal.component(.day, from: date)
    }
}

extension YearToDatePickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 5
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        case 1:
            return months.count
        case 2:
            return days.count
        case 3:
            return hours.count
        case 4:
            return minutes.count
        default:
            return 0
        }
    }
    
}
