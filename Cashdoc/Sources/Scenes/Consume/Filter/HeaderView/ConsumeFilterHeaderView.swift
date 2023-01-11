//
//  ConsumeFilterHeaderView.swift
//  Cashdoc
//
//  Created by Taejune Jung on 03/12/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import Lottie
import RxSwift
import RxCocoa

final class ConsumeFilterHeaderView: UIView {
    
    // MARK: - Properties
    
    let disposeBag = DisposeBag()
    private var type: CategoryType!
    
    // MARK: - UI Components
    
    private let titleLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = "수입"
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let priceLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 18)
        $0.text = "0원"
        $0.textColor = .blueCw
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setProperties()
        self.addSubview(titleLabel)
        self.addSubview(priceLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(_ priceAndIndex: (String, String)) {
        switch self.type {
        case .수입:
            priceLabel.text = priceAndIndex.0.convertToDecimal("원")
            titleLabel.text = "수입 " + priceAndIndex.1.convertToDecimal("건")
        case .지출:
            priceLabel.text = "-" + priceAndIndex.0.convertToDecimal("원")
            titleLabel.text = "지출 " + priceAndIndex.1.convertToDecimal("건")
        case .기타:
            priceLabel.text = priceAndIndex.0.convertToDecimal("원")
            titleLabel.text = "기타 " + priceAndIndex.1.convertToDecimal("건")
        default:
            break
        }
    }
    
    func setType(type: CategoryType) {
        self.type = type
    }
    
    // MARK: - Private methods
    private func setProperties() {
        self.backgroundColor = .grayTwoCw
    }
}

extension ConsumeFilterHeaderView {
    private func layout() {
        self.heightAnchor.constraint(equalToConstant: 66).isActive = true
        titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 28).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true

        priceLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        priceLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: 16).isActive = true
        priceLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24).isActive = true
        priceLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
    }
}
