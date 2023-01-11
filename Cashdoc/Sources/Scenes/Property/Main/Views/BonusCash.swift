//
//  BonusCash.swift
//  Cashdoc
//
//  Created by Oh Sangho on 24/06/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class BonusCash: UIView {
    
    // MARK: - Properties
    
    private let type: PropertyCardType
    var bonusCash = 0
    
    // MARK: - UI Components
    
    private let cashImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCoinYellow")
    }
    private let cashLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .blackTwoCw
    }
    
    // MARK: - Con(De)structor
    
    init(type: PropertyCardType) {
        self.type = type
        super.init(frame: .zero)
        
        setProperties()
        configure(type: type)
        addSubview(cashImage)
        addSubview(cashLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - private methods
    
    private func configure(type: PropertyCardType) {
        switch type {
        case .계좌:
            cashLabel.text = checkDefault(with: UserDefaultKey.kRewardAccount.rawValue)
        case .카드:
            cashLabel.text = checkDefault(with: UserDefaultKey.kRewardCard.rawValue)
        case .대출:
            cashLabel.text = checkDefault(with: UserDefaultKey.kRewardLoan.rawValue)
        case .신용:
            cashLabel.text = checkDefault(with: UserDefaultKey.kRewardCreditinfo.rawValue)
        case .보험:
            cashLabel.text = checkDefault(with: UserDefaultKey.kRewardInsurance.rawValue)
        default:
            return
        }
    }
    
    private func checkDefault(with defaults: String) -> String {
        guard let point = UserDefaults.standard.object(forKey: defaults) as? Int else {return "-캐시"}
        bonusCash = point
        return String(format: "%@캐시", point.commaValue)
    }
    
    private func setProperties() {
        backgroundColor = .grayTwoCw
        layer.cornerRadius = 11
    }
    
}

// MARK: - Layout

extension BonusCash {
    
    private func layout() {
        cashImage.topAnchor.constraint(equalTo: topAnchor, constant: 3).isActive = true
        cashImage.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3).isActive = true
        cashImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3).isActive = true
        cashImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
        cashImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        cashLabel.centerYAnchor.constraint(equalTo: cashImage.centerYAnchor).isActive = true
        cashLabel.leadingAnchor.constraint(equalTo: cashImage.trailingAnchor, constant: 2).isActive = true
        cashLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5).isActive = true
    }
    
}
