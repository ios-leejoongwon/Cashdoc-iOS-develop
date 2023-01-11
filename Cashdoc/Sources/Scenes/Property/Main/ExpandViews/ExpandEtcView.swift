//
//  ExpandEtcView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 2020/01/08.
//  Copyright © 2020 Cashwalk. All rights reserved.
//

import RealmSwift
import RxSwift
import RxCocoa

final class ExpandEtcView: BaseCardView {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let navigator: PropertyNavigator
    
    private var etcData: EtcPropertyList?
    private var amountLabelTrailing: NSLayoutConstraint!
    
    // MARK: - UI Components
    
    private let etcNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 14)
        $0.textAlignment = .right
        $0.textColor = .blackCw
    }
    private let arrowImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
    }
    
    // MARK: - Con(De)structor
    
    init(navigator: PropertyNavigator) {
        self.navigator = navigator
        super.init(frame: .zero)
        
        setProperties()
        containerView.addSubview(etcNameLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(arrowImage)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(item: EtcPropertyList) {
        
        self.etcData = item
        
        etcNameLabel.text = item.nickName
        amountLabel.text = String(format: "%@원", item.balance.commaValue).isOrEmptyCD
    }
    
    func getEtcId() -> String? {
        return self.etcData?.id
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
    }
    
}

// MARK: - Layout

extension ExpandEtcView {
    
    private func layout() {
        etcNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        etcNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
        etcNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        etcNameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor).isActive = true
        arrowImage.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -4.4).isActive = true
        amountLabel.leadingAnchor.constraint(equalTo: etcNameLabel.trailingAnchor, constant: 16).isActive = true
        amountLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    }
    
}
