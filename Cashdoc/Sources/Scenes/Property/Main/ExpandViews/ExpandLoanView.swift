//
//  ExpandLoanView.swift
//  Cashdoc
//
//  Created by Oh Sangho on 12/07/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ExpandLoanView: BaseCardView {
    
    // MARK: - Properties
    
    private var identity: String?
    
    // MARK: - UI Components
    
    private let nameLabel = UILabel().then {
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
    
    init(propertyExpandLoan: PropertyExpandLoan) {
        super.init(frame: .zero)
        
        setProperties()
        containerView.addSubview(nameLabel)
        containerView.addSubview(numberLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(arrowImage)
        containerView.addSubview(handwriteLabel)
        configure(loan: propertyExpandLoan)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func getIdentity() -> String? {
        guard let id = identity, id.isNotEmpty else { return nil }
        return id
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        backgroundColor = .clear
    }
    
    private func configure(loan: PropertyExpandLoan) {
        identity = loan.identity
        
        nameLabel.text = loan.name?.isOrEmptyCD
        
        guard let amount = loan.amount, let intAmount = Int(amount) else { return }
        amountLabel.text = String(format: "%@원", intAmount.commaValue).isOrEmptyCD
        
        if loan.isHandWrite {
            handwriteLabel.isHidden = false
            handwriteLabel.snp.updateConstraints { (make) in
                make.bottom.equalToSuperview().inset(16)
            }
        } else {
            numberLabel.text = loan.number?.isOrEmptyCD
            handwriteLabel.isHidden = true
        }
    }
    
}

// MARK: - Layout

extension ExpandLoanView {
    
    private func layout() {
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        numberLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 1).isActive = true
        numberLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        numberLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -24).isActive = true
        numberLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        arrowImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        arrowImage.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16).isActive = true
        arrowImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        arrowImage.heightAnchor.constraint(equalTo: arrowImage.widthAnchor).isActive = true
        
        amountLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: -4.6).isActive = true
        amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 16).isActive = true
        amountLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        handwriteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(6)
            make.leading.equalTo(nameLabel)
            make.width.equalTo(33)
            make.height.equalTo(18)
        }
    }
    
}
