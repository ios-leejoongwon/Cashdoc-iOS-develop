//
//  NSMutableAttributedString+Extensions.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension NSMutableAttributedString {
    static func attributedText(text: String,
                               textColor: UIColor? = .blackCw,
                               ofSize: CGFloat,
                               weight: UIFont.Weight,
                               alignment: NSTextAlignment? = .center) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        var size: CGFloat = ofSize
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            size = ofSize * widthRatio
        }
        paragraph.lineSpacing = size / 3
        paragraph.alignment = alignment ?? .center
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: textColor ?? .blackCw,
            .kern: 0.0
            ])
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    static func attributedUnderlineText(text: String,
                                        ofSize: CGFloat,
                                        weight: UIFont.Weight,
                                        color: UIColor? = .blackCw,
                                        alignment: NSTextAlignment) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        var size: CGFloat = ofSize
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            size = ofSize * widthRatio
        }
        paragraph.lineSpacing = size / 3
        paragraph.alignment = alignment
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: size, weight: weight),
            .foregroundColor: color ?? .blackCw,
            .kern: 0.0
            ])
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
    
    static func attributedUnderlineTextWithoutScale(text: String,
                                                    ofSize: CGFloat,
                                                    weight: UIFont.Weight,
                                                    alignment: NSTextAlignment) -> NSMutableAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = (ofSize / 3)
        paragraph.alignment = alignment
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: ofSize, weight: weight),
            .foregroundColor: UIColor.blackCw,
            .kern: 0.0
            ])
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        return attributedString
    }
}
