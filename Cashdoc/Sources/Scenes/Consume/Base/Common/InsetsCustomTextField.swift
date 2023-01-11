//
//  InsetsCustomTextField.swift
//  Cashdoc
//
//  Created by Oh Sangho on 12/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

class InsetsCustomTextField: UITextField {
    
    // MARK: - Properties

    private var padding = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 32)
    
    // MARK: - Overridden: UITextField
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
}
