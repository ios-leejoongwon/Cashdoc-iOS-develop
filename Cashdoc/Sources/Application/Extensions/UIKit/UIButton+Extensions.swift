//
//  UIButton+Extension.swift
//  Cashdoc
//
//  Created by Taejune Jung on 16/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import UIKit

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        
        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.setBackgroundImage(backgroundImage, for: forState)
    }
    
    @IBInspectable
    var IBselectBGcolor: UIColor {
        get {
            return self.currentTitleColor
        }
        set {
            // 선택되었을때 background color값 변경
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContext(rect.size)
            newValue.setFill()
            UIRectFill(rect)
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: .selected)
        }
    }
        
    @IBInspectable
    var IBdisableColor: UIColor {
        get {
            return self.currentTitleColor
        }
        set {
            // 선택되었을때 background color값 변경
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContext(rect.size)
            newValue.setFill()
            UIRectFill(rect)
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: .disabled)
        }
    }
    
    @IBInspectable
    var IBhightlightColor: UIColor {
        get {
            return self.currentTitleColor
        }
        set {
            // 선택되었을때 background color값 변경
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContext(rect.size)
            newValue.setFill()
            UIRectFill(rect)
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            setBackgroundImage(colorImage, for: .highlighted)
        }
    }
    
    // 타이틀라벨에 언더라인이 필요할때
    func setTitleUnderLine(_ title: String? = nil) {
        var text = ""
        if let title = title {
            text = title
        } else {
            text = self.titleLabel?.text ?? ""
        }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                  NSAttributedString.Key.foregroundColor: (self.titleColor(for: .normal) as Any),
                                  NSAttributedString.Key.font: self.titleLabel?.font ?? UIFont.systemFont(ofSize: 12)
        ]
        let makeAttri = NSMutableAttributedString(string: text, attributes: underlineAttribute)
        self.setAttributedTitle(makeAttri, for: .normal)
    }
}
