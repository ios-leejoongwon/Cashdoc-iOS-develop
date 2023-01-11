//
//  KeyButton.swift
//  SecurityKeyboard
//
//  Created by Sangbeom Han on 25/09/2019.
//  Copyright © 2019 Sangbeom Han. All rights reserved.
//

import UIKit
import RxSwift

class KeyButton: UIButton {
    
    // MARK: - Properties
    
    private var shifted = false
    private var isSpecial = false
    private var subscription: Disposable!
    
    var tappedString = PublishSubject<String>()
    var width = 1.0
    var normalText = ("", "") {
        didSet {
            let attributeTitle = NSMutableAttributedString(string: normalText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            if normalText.1 != "" {
                attributeTitle.append(NSAttributedString(string: "\n\(normalText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            }
            self.titleLabel?.numberOfLines = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.normalText.0)
            })
        }
    }
    var shiftedText = ("", "") {
        didSet {
            let attributeTitle = NSMutableAttributedString(string: shiftedText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            if shiftedText.1 != "" {
                attributeTitle.append(NSAttributedString(string: "\n\(shiftedText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            }
            self.titleLabel?.numberOfLines = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.normalText.0)
            })
        }
    }
    var specialText = ("", "") {
        didSet {
            let attributeTitle = NSMutableAttributedString(string: specialText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            if specialText.1 != "" {
                attributeTitle.append(NSAttributedString(string: "\n\(specialText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            }
            self.titleLabel?.numberOfLines = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.normalText.0)
            })
        }
    }
    
    // MARK: - Override UIButton
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        var insets = self.titleEdgeInsets
        insets.top += 8
        self.titleEdgeInsets = insets

        subscription = self.rx.tap.subscribe(onNext: {
        })
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        var insets = self.titleEdgeInsets
        insets.top += 8
        self.titleEdgeInsets = insets
        subscription = self.rx.tap.subscribe(onNext: {
        })
    }
    
    override open var intrinsicContentSize: CGSize {
        return CGSize(width: width, height: 1.0)
    }
    
    // MARK: - Public Methods
    
    func showShiftedText() {
        shifted = !shifted
        isSpecial = false
        
        if shifted {
            let attributeTitle = NSMutableAttributedString(string: shiftedText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            attributeTitle.append(NSAttributedString(string: "\n\(shiftedText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            self.titleLabel?.numberOfLines = 2
            self.width = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.shiftedText.0)
            })
        } else {
            let attributeTitle = NSMutableAttributedString(string: normalText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            if normalText.1 != "" {
                attributeTitle.append(NSAttributedString(string: "\n\(normalText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            }
            self.titleLabel?.numberOfLines = 2
            self.width = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.normalText.0)
            })
        }
    }
    
    func showSpecialText() {
        isSpecial = !isSpecial
        shifted = false
        
        if isSpecial {
            let attributeTitle = NSMutableAttributedString(string: specialText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            if specialText.1 != "" {
                attributeTitle.append(NSAttributedString(string: "\n\(specialText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            }
            self.titleLabel?.numberOfLines = 2
            self.width = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.specialText.0)
            })
        } else {
            let attributeTitle = NSMutableAttributedString(string: normalText.0, attributes: [.font: UIFont.systemFont(ofSize: 22, weight: .medium), .foregroundColor: UIColor.white])
            if normalText.1 != "" {
                attributeTitle.append(NSAttributedString(string: "\n\(normalText.1)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .thin), .foregroundColor: UIColor.gray]))
            }
            self.titleLabel?.numberOfLines = 2
            self.width = 2
            self.setAttributedTitle(attributeTitle, for: .normal)
            self.setAttributedTitle(attributeTitle, for: .highlighted)
            
            subscription.dispose()
            subscription = self.rx.tap.subscribe(onNext: {
                self.tappedString.onNext(self.normalText.0)
            })
        }
    }
    
}
