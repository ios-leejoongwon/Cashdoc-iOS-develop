//
//  AIBCertInfo+Extensions.swift
//  Cashdoc
//
//  Created by Oh Sangho on 08/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import SmartAIB

extension AIBCertInfo {
    func getUserName() -> String {
        guard let subject = self.subjectDN,
            let startRange = subject.lowercased().endIndex(of: "cn="),
            let endRange = subject.index(of: "(") else {return "-"}
        
        let tmp = subject.suffix(from: startRange)
        return String(tmp.prefix(upTo: endRange))
    }
    
    func getCAName() -> String {
        guard let subject = self.subjectDN,
            let caName = subject.lowercased().components(separatedBy: "o=")[1].components(separatedBy: ",").first else {return "-"}
        
        return String(format: "%@", caName)
    }
    
    func getPeriodAfter() -> String {
        guard let after = self.notAfter else {return "-"}
        var date = after.prefix(8)
        
        let firstIndex = date.index(date.startIndex, offsetBy: 4)
        let lastIndex = date.index(date.endIndex, offsetBy: -1)
        date.insert(".", at: firstIndex)
        date.insert(".", at: lastIndex)
        
        return String(date)
    }
    
    func getPeriodBefore() -> String {
        guard let before = self.notBefore else {return "-"}
        var date = before.prefix(8)
        
        let firstIndex = date.index(date.startIndex, offsetBy: 4)
        let lastIndex = date.index(date.endIndex, offsetBy: -1)
        date.insert(".", at: firstIndex)
        date.insert(".", at: lastIndex)
        
        return String(date)
    }
    
    func compareAfterDateWithToday() -> Bool {
        guard let after = self.notAfter else {return false}
        let date = after.prefix(12)
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmm"
        
        switch formatter.date(from: String(date))?.compare(Date()).rawValue {
        case -1:
            return false
        default:
            return true
        }
    }
}
