//
//  PropertyCardDetailTableViewCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class PropertyCardDetailTableViewCell: UITableViewCell {
    
    // MARK: - UI Componenets
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let nameLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.numberOfLines = 2
    }
    private let installmentLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownGrayCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .blackCw
        $0.textAlignment = .right
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(installmentLabel)
        containerView.addSubview(amountLabel)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        nameLabel.text = nil
        installmentLabel.text = nil
        amountLabel.text = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with item: CardDetailContentItem) {
        nameLabel.text = item.name.isOrEmptyCD
        installmentLabel.text = item.installment.isOrEmptyCD
        if let intAmt = Int(item.amount) {
            amountLabel.text = String(format: "%@원", intAmt.commaValue).isOrEmptyCD
        }
    }
    
    // MARK: - Private methods
    
    private func setProperties() {
        selectionStyle = .none
        backgroundColor = .clear
    }
}

// MARK: - Layout

extension PropertyCardDetailTableViewCell {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 24).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        
        installmentLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2).isActive = true
        installmentLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        installmentLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor).isActive = true
        
        amountLabel.leadingAnchor.constraint(greaterThanOrEqualTo: nameLabel.trailingAnchor, constant: 16).isActive = true
        amountLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 25).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24).isActive = true
    }
}
