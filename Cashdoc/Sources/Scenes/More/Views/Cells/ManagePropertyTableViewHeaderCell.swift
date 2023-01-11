//
//  ManagePropertyTableViewHeaderCell.swift
//  Cashdoc
//
//  Created by Oh Sangho on 20/09/2019.
//  Copyright © 2019 Cashwalk. All rights reserved.
//

final class ManagePropertyTableViewHeaderCell: UITableViewCell {
    
    // MARK: - UI Components
    
    private let headerLabel = UILabel().then {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setFontToMedium(ofSize: 12)
        $0.textColor = .brownishGrayCw
    }
    
    // MARK: - Con(De)structor
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setProperties()
        contentView.addSubview(headerLabel)
        layout()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Internal methods
    
    func configure(with header: String) {
        headerLabel.text = header
    }
    
    private func setProperties() {
        contentView.backgroundColor = .grayTwoCw
        selectionStyle = .none
    }
    
}

// MARK: - Layout

extension ManagePropertyTableViewHeaderCell {
    private func layout() {
        headerLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 7).isActive = true
        headerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -7).isActive = true
        headerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24).isActive = true
    }
}
