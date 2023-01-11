//
//  UITextField-Extension.swift
//  Cashdoc
//
//  Created by Taejune Jung on 19/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

extension UITextField {
//    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        return false
//    }
    
    @IBInspectable
    var IBleftPadding: CGFloat {
        get {
            return accessibilityActivationPoint.x
        }
        set {
            // Create a padding view for padding on left
            self.leftView = UIView(frame: CGRect(x: 0, y: 0, width: newValue, height: self.frame.height))
            self.leftViewMode = .always
        }
    }
    
    @IBInspectable
    var maxLength: CGFloat {
        get {
            return self.accessibilityActivationPoint.y
        }
        set {
            self.accessibilityActivationPoint.y = newValue
            self.addTarget(self, action: #selector(custumDidChange(_:)), for: .editingChanged)
        }
    }
    
    @objc func custumDidChange(_ textField: UITextField) {
        guard let text = self.text else { return }
        if text.count > Int(self.accessibilityActivationPoint.y) {
            let range = text.index(text.startIndex, offsetBy: 0)..<text.index(text.startIndex, offsetBy: Int(self.accessibilityActivationPoint.y))
            self.text = String(text[range])
        }
    }
    
    private func getMaxLengthTextCountIndex() -> Int {
        guard let text = self.text else { return 0 }
        
        var textCount: Int = 0
        var strIndex: Int = 0
        for char in text {
            if textCount == Int(self.accessibilityActivationPoint.y) {
                return strIndex
            }
            
            if char != " " {
                textCount += 1
            }
            
            strIndex += 1
        }
        
        return strIndex
    }
    
    func addLeftPadding(width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: frame.height))
        leftView = paddingView
        leftViewMode = .always
    }
}

extension UITextField {
    public func rxText(_ element: String) {
        self.text = element
        self.sendActions(for: .valueChanged)
    }
    
    @IBInspectable var doneAccessory: Bool {
        get {
            return self.doneAccessory
        }
        set (hasDone) {
            if hasDone {
                addDoneButtonOnKeyboard()
            }
        }
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(self.doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        inputAccessoryView = doneToolbar
    }
    
    @objc func doneButtonAction() {
        endEditing(true)
    }
}
