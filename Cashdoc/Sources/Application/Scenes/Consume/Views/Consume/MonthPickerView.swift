//
//  MonthPickerView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 11/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class MonthPickerView: UIPickerView {
    
    // MARK: - Properties
    
    var months: [Int]!
    var years: [Int]!
    
    var month = Calendar.current.component(.month, from: Date()) {
        didSet {
            selectRow(month - 1, inComponent: 0, animated: false)
        }
    }
    
    var year = Calendar.current.component(.year, from: Date()) {
        didSet {
            selectRow(years.firstIndex(of: year)!, inComponent: 1, animated: true)
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
        
        self.delegate = self
        self.dataSource = self
        
        let currentYear = Calendar(identifier: .gregorian).component(.year, from: Date())
        let currentMonth = Calendar(identifier: .gregorian).component(.month, from: Date())
        print(currentMonth)
        self.selectRow(currentYear - 1900, inComponent: 0, animated: false)
        self.selectRow(currentMonth - 1, inComponent: 1, animated: false)
    }
}

extension MonthPickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return "\(years[row])년"
        case 1:
            return "\(months[row])월"
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    }
}

extension MonthPickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return years.count
        case 1:
            return months.count
        default:
            return 0
        }
    }
    
}
