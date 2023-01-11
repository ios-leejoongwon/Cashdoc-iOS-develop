//
//  UILabel+Extenssions.swift
//  Cashdoc
//
//  Created by Taejune Jung on 23/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UILabel {
    @IBInspectable
    var IBLineHeight: CGFloat {
        get {
            return accessibilityActivationPoint.y
        }
        set {
            self.setLineHeight(lineHeight: newValue)
        }
    }
   
    static func systemLabel(text: String, ofSize: CGFloat, wight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = (ofSize / 3) * widthRatio
        paragraph.alignment = .center
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: UIFont.systemFont(ofSize: ofSize * widthRatio, weight: wight),
            .foregroundColor: UIColor.blackCw,
            .kern: 0.0
            ])
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        label.numberOfLines = 0
        label.attributedText = attributedString
        return label
    }
    
    func setLineHeightMultiple(lineHeight: CGFloat) {
        guard let text = self.text, let font = self.font else { return }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1.0
        paragraphStyle.lineHeightMultiple = lineHeight
        paragraphStyle.alignment = self.textAlignment

        let attrString = NSMutableAttributedString()
        if self.attributedText != nil {
            attrString.append( self.attributedText!)
        } else {
            attrString.append( NSMutableAttributedString(string: text))
            attrString.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange(location: 0, length: attrString.length))
        }
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attrString.length))
        self.attributedText = attrString
    }
    
    // 제플린의 LineHeight를 적용하기 위함
    func setLineHeight(lineHeight: CGFloat) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.minimumLineHeight = lineHeight
        paragraph.alignment = textAlignment
        
        let attributedString = NSMutableAttributedString(string: text ?? "")
        attributedString.addAttribute(.paragraphStyle, value: paragraph, range: NSRange(location: 0, length: attributedString.length))
        
        self.attributedText = attributedString
    }
    
    func setUnderLine() {
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let makeAttri = NSMutableAttributedString(string: self.text ?? "", attributes: underlineAttribute)
        self.attributedText = makeAttri
    }
    
    func setFontToRegular(ofSize: CGFloat) {
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            font = .systemFont(ofSize: ofSize * widthRatio)
        } else {
            font = .systemFont(ofSize: ofSize)
        }
    }
    
    func setFontToMedium(ofSize: CGFloat) {
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            font = .systemFont(ofSize: ofSize * widthRatio, weight: .medium)
        } else {
            font = .systemFont(ofSize: ofSize, weight: .medium)
        }
    }
    
    func setFontToBold(ofSize: CGFloat) {
        if DeviceType.IS_IPHONE_4_OR_LESS || DeviceType.IS_IPHONE_5 {
            font = .systemFont(ofSize: ofSize * widthRatio, weight: .bold)
        } else {
            font = .boldSystemFont(ofSize: ofSize)
        }
    }
}
