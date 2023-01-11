//
//  CertificateTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 08/08/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class CertificateTableViewCell: UITableViewCell {
    
    // MARK: - UI Componenets
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 2
        $0.layer.borderWidth = 0.5
        $0.layer.borderColor = UIColor.grayCw.cgColor
    }
    private let certImage = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.image = UIImage(named: "imgCertification")
    }
    private let userNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 16)
        $0.textColor = .blackCw
    }
    private let caNameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    private let availablePeriodLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(certImage)
        containerView.addSubview(userNameLabel)
        containerView.addSubview(caNameLabel)
        containerView.addSubview(availablePeriodLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        certImage.image = nil
        userNameLabel.text = nil
        caNameLabel.text = nil
        availablePeriodLabel.text = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with certInfo: FindedCertInfo) {
        userNameLabel.text = certInfo.userName
        caNameLabel.text = certInfo.caName
        
        availablePeriodLabel.text = String(format: "%@  |  %@",
                                           certInfo.beforePeriod,
                                           certInfo.afterPeriod)
        
        if certInfo.isAvailable {
            certImage.image = UIImage(named: "imgCertification")
            userNameLabel.textColor = .blackCw
            caNameLabel.textColor = .brownishGrayCw
            availablePeriodLabel.textColor = .brownishGrayCw
            isUserInteractionEnabled = true
        } else {
            certImage.image = UIImage(named: "imgCertificationNone")
            userNameLabel.textColor = .veryLightPinkCw
            caNameLabel.textColor = .veryLightPinkCw
            availablePeriodLabel.textColor = .veryLightPinkCw
            isUserInteractionEnabled = false
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
        backgroundColor = .clear
    }
}

// MARK: - Layout

extension CertificateTableViewCell {

    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6).isActive = true
        
        certImage.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        certImage.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20).isActive = true
        certImage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        certImage.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        userNameLabel.leadingAnchor.constraint(equalTo: certImage.trailingAnchor, constant: 10).isActive = true
        userNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        caNameLabel.leadingAnchor.constraint(equalTo: userNameLabel.leadingAnchor).isActive = true
        caNameLabel.topAnchor.constraint(equalTo: userNameLabel.bottomAnchor).isActive = true
        caNameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        availablePeriodLabel.leadingAnchor.constraint(equalTo: caNameLabel.leadingAnchor).isActive = true
        availablePeriodLabel.topAnchor.constraint(equalTo: caNameLabel.bottomAnchor).isActive = true
        availablePeriodLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -10).isActive = true
        availablePeriodLabel.heightAnchor.constraint(equalTo: caNameLabel.heightAnchor).isActive = true
    }
    
}
