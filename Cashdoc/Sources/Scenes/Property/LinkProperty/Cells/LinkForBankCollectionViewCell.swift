//
//  LinkForBankCollectionViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

import RxSwift

final class LinkForBankCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    private let disposeBag = DisposeBag()
    private let imagePadding: CGFloat = 41 * widthRatio
    
    // MARK: - UI Components
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 4
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
    }
    private let bankImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.clipsToBounds = true
    }
    private let bankNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .center
    }
    private let checkByLinkStatus = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "icCheckBoxEnabledBlue")
        $0.isHidden = true
    }
    
    // MARK: - Con(De)structor
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(containerView)
        containerView.addSubview(bankImage)
        containerView.addSubview(bankNameLabel)
        containerView.addSubview(checkByLinkStatus)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with bankInfo: BankInfo) {
        guard let fCode = FCode(rawValue: bankInfo.bankName) else { return }
        if let image = fCode.image {
            bankImage.image = UIImage(named: image)
        }
        bankNameLabel.text = fCode.rawValue
        checkedByLinkStatus(isLinked: bankInfo.isLinked)
    }
    
    // MARK: - Private methods
    
    private func checkedByLinkStatus(isLinked: Bool) {
        if isLinked {
            checkByLinkStatus.isHidden = false
            containerView.layer.borderWidth = 3
            containerView.layer.borderColor = UIColor.blueCw.cgColor
        } else {
            checkByLinkStatus.isHidden = true
            containerView.layer.borderWidth = 0.5
            containerView.layer.borderColor = UIColor.grayCw.cgColor
        }
    }
}

// MARK: - Layout

extension LinkForBankCollectionViewCell {
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        containerView.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        
        bankImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -8).isActive = true
        bankImage.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        bankImage.widthAnchor.constraint(equalToConstant: 24).isActive = true
        bankImage.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        bankNameLabel.topAnchor.constraint(equalTo: bankImage.bottomAnchor, constant: 4).isActive = true
        bankNameLabel.centerXAnchor.constraint(equalTo: bankImage.centerXAnchor).isActive = true
        bankNameLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        
        checkByLinkStatus.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6).isActive = true
        checkByLinkStatus.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -6).isActive = true
        checkByLinkStatus.widthAnchor.constraint(equalToConstant: 25).isActive = true
        checkByLinkStatus.heightAnchor.constraint(equalToConstant: 24).isActive = true
    }
}
