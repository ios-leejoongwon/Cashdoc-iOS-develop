//
//  ReLinkedView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2019/11/08.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxCocoa
import RxSwift

final class ReLinkedView: UIView {
    
    var reLinkButtonTap: Driver<Void> {
        return reLinkButton.rx.tap.asDriverOnErrorJustNever()
    }
    
    // MARK: - UI Components
    
    private let backgroundView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = UIColor.blackCw.withAlphaComponent(0.9)
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .white
        $0.text = "정보 보호를 위해 자산연동이 해제되어 있습니다."
    }
    private let reLinkButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.setTitleColor(.red, for: .normal)
        let textString = "자동으로 자산 연동 하기"
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let buttonString = NSMutableAttributedString(string: textString, attributes: underlineAttribute)
        buttonString.addAttribute(NSAttributedString.Key.foregroundColor,
                                  value: UIColor.blueCw,
                                  range: (textString as NSString).range(of: textString))
        $0.setAttributedTitle(buttonString, for: .normal)
    }
    
    // MARK: - Con(De)structor
    
    init() {
        super.init(frame: .zero)
        
        addSubview(backgroundView)
        backgroundView.addSubview(descLabel)
        backgroundView.addSubview(reLinkButton)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Layout

extension ReLinkedView {
    private func layout() {
        backgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        
        descLabel.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
        descLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 23).isActive = true
        
        reLinkButton.centerXAnchor.constraint(equalTo: descLabel.centerXAnchor).isActive = true
        reLinkButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 8).isActive = true
        reLinkButton.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -23).isActive = true
    }
}
