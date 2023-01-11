//
//  Date+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 23/10/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Foundation
import DateToolsSwift

extension Date {
    
    // MARK: - Properties
    
    var lastday: Int {
        let startOfMonth = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Calendar.current.startOfDay(for: self)))!
        let endOfMonth = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        return Calendar.current.component(.day, from: endOfMonth)
    }
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: current)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: current)!
    }
    var current: Date {
        return Calendar.current.date(bySettingHour: currentHour, minute: currentMinute, second: currentSecond, of: self)!
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
    var currentYear: Int {
        return Calendar.current.component(.year, from: self)
    }
    var currentMonth: Int {
        return Calendar.current.component(.month, from: self)
    }
    var currentDay: Int {
        return Calendar.current.component(.day, from: self)
    }
    var currentHour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    var currentMinute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    var currentSecond: Int {
        return Calendar.current.component(.second, from: self)
    }
    var midnight: Date {
        return Calendar.current.startOfDay(for: Date())
    }
    
    // MARK: - Public Static methods
    
    public static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    public static func monthsBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: start, to: end).month ?? 0
    }
    
    public static func yearsBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: start, to: end).year ?? 0
    }
    
    public static func currentHourMin(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let time = dateFormatter.string(from: date)
        return time
    }
    
    public static func hourAndMin(time: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = SERVER_DATE_FORMAT
        let date = dateFormatter.date(from: time)
        
        if let getDate = date {
            dateFormatter.dateFormat = "HH:mm"
            return dateFormatter.string(from: getDate)
        } else {
            return ""
        }
    }
    
    public static func sinceNowKor(date: Date?) -> String {
        
        guard let date = date else {
            return ""
        }
        var sinceNow = date.shortTimeAgoSinceNow
        
        // translate into korean (ref: https://github.com/MatthewYork/DateTools/blob/master/DateToolsSwift/DateTools/Date%2BTimeAgo.swift#L158)
        if sinceNow.contains("y") {
            sinceNow = sinceNow.replacingOccurrences(of: "y", with: "년전")
        } else if sinceNow.contains("M") {
            sinceNow = sinceNow.replacingOccurrences(of: "M", with: "달전")
        } else if sinceNow.contains("w") {
            sinceNow = sinceNow.replacingOccurrences(of: "w", with: "주전")
        } else if sinceNow.contains("d") {
            sinceNow = sinceNow.replacingOccurrences(of: "d", with: "일전")
        } else if sinceNow.contains("h") {
            sinceNow = sinceNow.replacingOccurrences(of: "h", with: "시간전")
        } else if sinceNow.contains("m") {
            sinceNow = sinceNow.replacingOccurrences(of: "m", with: "분전")
        } else if sinceNow.contains("s") {
            if sinceNow.contains("0s") {
                sinceNow = "방금전"
            } else {
                sinceNow = sinceNow.replacingOccurrences(of: "s", with: "초전")
            }
        }
        return sinceNow
    }
    
    // MARK: - Internal methods
    
    func getNextMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: 1, to: self)
    }
    
    func getPreviousMonth() -> Date? {
        return Calendar.current.date(byAdding: .month, value: -1, to: self)
    }
    
    func simpleDateFormat(_ dateFormat: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
    
}
