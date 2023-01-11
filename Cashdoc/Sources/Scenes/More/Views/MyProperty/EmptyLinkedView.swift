//
//  EmptyLinkedView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 30/01/2020.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import Foundation
import RxCocoa

class EmptyLinkedView: UIView {
    
    // MARK: - Properties
    
    var addButtonTap: ControlEvent<Void> {
        return addButton.rx.tap
    }
    
    // MARK: - UI Components
    
    private let centerImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgExpenseNone")
    }
    private let descLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textAlignment = .center
        $0.textColor = .blackCw
        $0.text = "연동된 내역이 없습니다."
    }
    private let addButton = UIButton().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4
        $0.backgroundColor = .blackCw
        $0.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        $0.titleLabel?.textAlignment = .center
        $0.setTitleColor(.white, for: .normal)
        $0.setTitle("내 자산 추가하기", for: .normal)
    }
    
    // MARK: - Overridden: UIViewController
    
    init() {
        super.init(frame: .zero)
        
        setProperties()
        self.addSubview(centerImage)
        self.addSubview(descLabel)
        self.addSubview(addButton)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        self.backgroundColor = .grayTwoCw
    }

    // MARK: - Layout
    
    private func layout() {
        centerImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -104.5).isActive = true
        centerImage.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        centerImage.widthAnchor.constraint(equalToConstant: 80).isActive = true
        centerImage.heightAnchor.constraint(equalTo: centerImage.widthAnchor).isActive = true
        
        descLabel.topAnchor.constraint(equalTo: centerImage.bottomAnchor, constant: 16).isActive = true
        descLabel.centerXAnchor.constraint(equalTo: centerImage.centerXAnchor).isActive = true
        descLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        addButton.widthAnchor.constraint(equalToConstant: 136).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 42).isActive = true
        addButton.topAnchor.constraint(equalTo: descLabel.bottomAnchor, constant: 32).isActive = true
        addButton.centerXAnchor.constraint(equalTo: descLabel.centerXAnchor).isActive = true
    }
}
