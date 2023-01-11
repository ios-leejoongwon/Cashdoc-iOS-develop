//
//  PropertyCardDetailTableViewHeaderCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 03/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class PropertyCardDetailTableViewHeaderCell: UITableViewCell {
    
    // MARK: - UI Componenets
    
    private let containerView = UIView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .white
    }
    private let topLine = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayTwoCw
    }
    private let bottomLine = UIImageView().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.backgroundColor = .grayCw
    }
    private let dateLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 14)
        $0.textColor = .brownishGrayCw
    }
    private let amountLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToRegular(ofSize: 12)
        $0.textColor = .brownishGrayCw
        $0.textAlignment = .right
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(containerView)
        containerView.addSubview(topLine)
        containerView.addSubview(dateLabel)
        containerView.addSubview(amountLabel)
        containerView.addSubview(bottomLine)
        layout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden: UITableViewCell
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        dateLabel.text = nil
        amountLabel.text = nil
    }
    
    // MARK: - Internal methods
    
    func configure(with item: CardDetailHeaderItem,
                   totalAmt: [String: Int]) {
        
        dateLabel.text = item.date.isOrEmptyCD
        
        if let intAmt = totalAmt[item.date] {
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

extension PropertyCardDetailTableViewHeaderCell {
    
    private func layout() {
        containerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        topLine.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        topLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        topLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        topLine.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        dateLabel.topAnchor.constraint(equalTo: topLine.bottomAnchor, constant: 18).isActive = true
        dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24).isActive = true
        dateLabel.bottomAnchor.constraint(equalTo: bottomLine.topAnchor, constant: -18).isActive = true
        
        amountLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor).isActive = true
        amountLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -26).isActive = true
        
        bottomLine.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
    
}
