//
//  String-Extensions.swift
//  Cashdoc
//
//  Created by DongHeeKang on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension String {
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
    
    func utf8DecodedString() -> String {
         let data = self.data(using: .utf8)
         if let message = String(data: data!, encoding: .nonLossyASCII) {
                return message
          }
          return ""
    }

    var hexadecimal: Data? {
        var data = Data(capacity: count / 2)
        
        let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex?.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }
        
        guard data.count > 0 else { return nil }
        
        return data
    }
    
    func toWidthSize(font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: fontAttributes).width
    }
    
    func toHeightSize(font: UIFont, width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
}

extension StringProtocol {
    func index(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.lowerBound
    }
    func endIndex(of string: Self, options: String.CompareOptions = []) -> Index? {
        return range(of: string, options: options)?.upperBound
    }
    func indexes(of string: Self, options: String.CompareOptions = []) -> [Index] {
        var result: [Index] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range.lowerBound)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

// MARK: - Range

extension StringProtocol where Index == String.Index {
    func nsRange(from range: Range<Index>) -> NSRange {
        return NSRange(range, in: self)
    }
    
    func nsRange(of string: Self) -> NSRange? {
        guard let range = self.range(of: string, options: [], range: nil, locale: .current) else { return nil }
        return NSRange(range, in: self)
    }
}
    
extension String {
    // 8자리 String 포맷(yyyyMMdd)을 yyyy.MM.dd String 포맷으로 변환.
    var toDateFormatted: String {
        guard !self.isEmpty, self.count == 8 else { return "-" }
        var date = self
        let firstIndex = date.index(date.startIndex, offsetBy: 4)
        let lastIndex = date.index(date.endIndex, offsetBy: -1)
        date.insert(".", at: firstIndex)
        date.insert(".", at: lastIndex)
        return date
    }

    var isOrEmptyCD: String {
        return self.isEmpty ? "-" : self
    }
    
    func subString(to index: Int) -> String {
        guard self.count >= index else { return "-" }
        let subStr = NSString(string: self)
        return subStr.substring(to: index)
    }
    
    func subString(from index: Int) -> String {
        guard self.count > index else { return "-" }
        let subStr = NSString(string: self)
        return subStr.substring(from: index)
    }
    
    func replace(target: String, withString: String) -> String {
        return self.replacingOccurrences(of: target, with: withString, options: .literal, range: nil)
    }
    
    func removeCharacters(characters: String) -> String {
        return self.replace(target: characters, withString: "")
    }
    
    func strikeThrough() -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.blackCw, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    func nonStrikeThrough() -> NSAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributeString.length))
        attributeString.addAttribute(NSAttributedString.Key.strikethroughColor, value: UIColor.clear, range: NSRange(location: 0, length: attributeString.length))
        return attributeString
    }
    
    func convertToDecimal(_ unit: String) -> String {
        guard let num = Int(self) else { return "0" + unit }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        return (formatter.string(from: NSNumber(value: num)) ?? "0") + unit
    }

    subscript(_ i: Int) -> String {
        guard self.count > 0 else { return self }
        let idx1 = index(startIndex, offsetBy: i)
        let idx2 = index(idx1, offsetBy: 1)
        return String(self[idx1..<idx2])
    }

    subscript (r: Range<Int>) -> String {
        guard self.count >= r.upperBound else { return self }
        let start = index(startIndex, offsetBy: r.lowerBound)
        let end = index(startIndex, offsetBy: r.upperBound)
        return String(self[start ..< end])
    }

    subscript (r: CountableClosedRange<Int>) -> String {
        guard self.count >= r.upperBound else { return self }
        let startIndex = self.index(self.startIndex, offsetBy: r.lowerBound)
        let endIndex = self.index(startIndex, offsetBy: r.upperBound - r.lowerBound)
        return String(self[startIndex...endIndex])
    }
    
    // 세자리숫자에 콤마 추가해줌
    var commaValue: String {
        guard let num = Int(self) else { return "0" }
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: num)) ?? "0"
    }
    
    var toInt: Int {
        guard let intSelf = Int(self) else { return 0 }
        return intSelf
    }
    
    var isBackspace: Bool {
        guard let char = self.cString(using: .utf8) else { return false }
        return strcmp(char, "\\b") == -92
    }
    
    mutating func insert(string: String, ind: Int) {
        self.insert(contentsOf: string, at: self.index(self.startIndex, offsetBy: ind))
    }
    
    // String의 Date형식을 바꿔주는 기능
    func convertDateFormat(beforeFormat: String, afterFormat: String) -> String {
        let makeDate = self.simpleDateFormat(beforeFormat)
        return makeDate.simpleDateFormat(afterFormat)
    }
    
    func simpleDateFormat(_ dateFormat: String) -> Date {
        let dateFormatter: DateFormatter = .init()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: self) ?? Date()
    }
}
