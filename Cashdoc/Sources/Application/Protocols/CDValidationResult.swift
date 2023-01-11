//
//  InsuranProtocols.swift
//  Cashdoc
//
//  Created by  주완 김 on 2019/12/10.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift
import RxCocoa

enum CDValidationResult {
    case ok(message: String)
    case empty(message: String)
    case validating(message: String)
    case failed
}

extension CDValidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
    
    var isFailed: Bool {
        switch self {
        case .failed:
            return true
        default:
            return false
        }
    }
}

extension CDValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            return message
        case let .empty(message):
            return message
        case let .validating(message):
            return message
        case .failed:
            return "다시 확인해 주세요."
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .failed:
            return UIColor.fromRGB(255, 47, 74)
        default:
            return UIColor.fromRGB(102, 102, 102)
        }
    }
    
    var placetextColor: UIColor {
        switch self {
        case .failed:
            return UIColor.fromRGB(255, 47, 74)
        default:
            return UIColor.lightGray
        }
    }
    
    var borderColor: UIColor {
        switch self {
        case .failed:
            return UIColor.fromRGB(255, 47, 74)
        default:
            return UIColor.fromRGB(216, 216, 216)
        }
    }
    
    var viewColor: UIColor {
        switch self {
        case .ok:
            return UIColor.fromRGB(255, 210, 0)
        case .empty:
            return UIColor.fromRGB(216, 216, 216)
        case .validating:
            return UIColor.fromRGB(255, 210, 0)
        case .failed:
            return UIColor.fromRGB(255, 47, 74)
        }
    }
}

extension Reactive where Base: UIView {
    var validationResult: Binder<CDValidationResult> {
        return Binder(base) { view, result in
            view.backgroundColor = result.viewColor
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: Binder<CDValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}

extension Reactive where Base: UILabel {
    var validationPWResult: Binder<CDValidationResult> {
        return Binder(base) { label, result in
            label.textColor = result.textColor
        }
    }
}

extension Reactive where Base: kTextFiledPlaceHolder {
    var validationResult: Binder<CDValidationResult> {
        return Binder(base) { field, result in
            field.lblPlaceHolder.textColor = result.placetextColor
        }
    }
}

extension Reactive where Base: UITextField {
    var validationResult: Binder<CDValidationResult> {
        return Binder(base) { field, result in
            field.layer.borderColor = result.borderColor.cgColor
        }
    }
}
