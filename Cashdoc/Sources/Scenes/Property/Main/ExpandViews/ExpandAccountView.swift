//
//  ExpandAccountView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 27/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ExpandAccountView: BaseCardView {
    
    // MARK: - Properties
    
    private var typeLabelHeight: NSLayoutConstraint!
    private var titleLabelHeight: NSLayoutConstraint!
    private var numberLabelHeight: NSLayoutConstraint!
    private var arrowImageHeight: NSLayoutConstraint!
    private var amountLabelHeight: NSLayoutConstraint!
    private var identity: String!
    
    // MARK: - UI Components
    
    private let typeLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .blueCw
    }
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
    }
    private let numberLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textAlignment = .right
        $0.textColor = .blackCw
    }
    private let arrowImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icArrow01StyleRightGray")
    }
    private let handwriteLabel = UILabel().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 9
        $0.backgroundColor = .white2
        $0.setFontToRegular(ofSize: 10)
        $0.textAlignment = .center
        $0.textColor = .brownishGrayCw
        $0.text = "수기"
    }
    
    // MARK: - Con(De)structor
    
    init(propertyExpandAccount: PropertyExpandAccount) {
        super.init(frame: .zero)
        
        setProperties()
        containerView.addSubview(typeLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(numberLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(arrowImage)
        containerView.addSubview(handwriteLabel)
        configure(account: propertyExpandAccount)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func getAccountIdentity() -> String {
        guard identity.isNotEmpty else { return .init() }
        return identity
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
    }
    
    private func configure(account: PropertyExpandAccount) {
        identity = account.identity
        
        switch account.type {
        case "1":
            typeLabel.text = "입출금"
        case "2":
            typeLabel.text = "예금"
        case "3":
            typeLabel.text = "적금"
        default:
            typeLabel.text = "기타"
        }
        titleLabel.text = account.title.isOrEmptyCD
        
        if account.isHandWrite {
            handwriteLabel.isHidden = false
            handwriteLabel.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().inset(16)
            }
        } else {
            numberLabel.text = account.number?.isOrEmptyCD
            handwriteLabel.isHidden = true
        }
        
        if let intAmount = Int(account.amount) {
            amountLabel.text = String(format: "%@원", intAmount.commaValue).isOrEmptyCD
        }
    }
    
}

// MARK: - Layout

extension ExpandAccountView {
    
    private func layout() {
        typeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16).isActive = true
        typeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        typeLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        titleLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: typeLabel.leadingAnchor).isActive = true
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        numberLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        numberLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        numberLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor).isActive = true
        
        amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -4.6).isActive = true
        amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16).isActive = true
        
        handwriteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(6)
            make.leading.equalTo(titleLabel)
            make.width.equalTo(33)
            make.height.equalTo(18)
        }
    }
    
}
