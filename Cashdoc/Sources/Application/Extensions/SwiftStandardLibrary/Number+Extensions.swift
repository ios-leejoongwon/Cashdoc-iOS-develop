//
//  Number+Extensions.swift
//  Cashwalk
//
//  Created by DongHeeKang on 2018. 6. 20..
//  Copyright © 2018년 Cashwalk, Inc. All rights reserved.
//

import Foundation

extension Int {
    var commaValue: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
    
    var toDateFormatFromTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd / HH:mm"
        return formatter.string(from: Date(timeIntervalSince1970: TimeInterval(self)))
    }
    
    var toYYYYmmddFormatFromTimeStamp: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        
        if let date = formatter.date(from: String(self)) {
            formatter.dateFormat = "yyyy.MM.dd"
            return formatter.string(from: date)
        } else {
            return "-"
        }
    }
    
    func toMaxValue(max: Int) -> String {
        if self > max {
            return "  \(max)+  "
        } else {
            return "  \(self)  "
        }
    }
}

extension Int64 {
    var commaValue: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}

extension UInt64 {
    var commaValue: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = NumberFormatter.Style.decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? String(self)
    }
}
